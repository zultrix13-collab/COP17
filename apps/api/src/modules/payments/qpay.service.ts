import { Inject, Injectable, Logger } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { randomUUID } from 'node:crypto';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';
import { WalletService } from '../wallet/wallet.service';

export interface QPayInvoice {
  id: string;
  qpayInvoiceId: string;
  qrText: string;
  deepLink: string;
  amount: number;
  expiresAt: string;
  status: 'pending' | 'paid' | 'expired' | 'failed';
}

/**
 * QPay integration. Real HTTP calls to https://merchant.qpay.mn are
 * stubbed here — replace `createAtQpay` + `pollAtQpay` once credentials
 * land. Logic around our DB + wallet credit is fully wired.
 */
@Injectable()
export class QPayService {
  private readonly log = new Logger(QPayService.name);

  constructor(
    @Inject(SUPABASE_ADMIN) private readonly sb: SupabaseClient,
    private readonly wallet: WalletService,
  ) {}

  async createTopUp(userId: string, amount: number): Promise<QPayInvoice> {
    const expires = new Date(Date.now() + 30 * 60 * 1000);
    const qpay = await this.createAtQpay(amount);

    const { data, error } = await this.sb
      .from('qpay_invoices')
      .insert({
        user_id: userId,
        amount,
        qpay_invoice_id: qpay.id,
        qr_text: qpay.qrText,
        deep_link: qpay.deepLink,
        expires_at: expires.toISOString(),
      })
      .select('id')
      .single();
    if (error) throw error;

    return {
      id: data.id as string,
      qpayInvoiceId: qpay.id,
      qrText: qpay.qrText,
      deepLink: qpay.deepLink,
      amount,
      expiresAt: expires.toISOString(),
      status: 'pending',
    };
  }

  async status(invoiceId: string): Promise<'pending' | 'paid' | 'expired' | 'failed'> {
    const { data, error } = await this.sb
      .from('qpay_invoices')
      .select('status, qpay_invoice_id, user_id, amount')
      .eq('id', invoiceId)
      .single();
    if (error) throw error;
    if (data.status !== 'pending') return data.status;

    const remote = await this.pollAtQpay(data.qpay_invoice_id);
    if (remote === 'paid') {
      await this.markPaid(invoiceId, data.user_id, data.amount, data.qpay_invoice_id);
      return 'paid';
    }
    return remote;
  }

  /**
   * QPay webhook → POST /payments/qpay/webhook. Must be idempotent:
   * same invoice may fire twice if QPay retries.
   */
  async handleWebhook(qpayInvoiceId: string): Promise<void> {
    const { data, error } = await this.sb
      .from('qpay_invoices')
      .select('id, status, user_id, amount')
      .eq('qpay_invoice_id', qpayInvoiceId)
      .maybeSingle();
    if (error) throw error;
    if (!data || data.status === 'paid') return;
    await this.markPaid(data.id, data.user_id, data.amount, qpayInvoiceId);
  }

  private async markPaid(
    invoiceId: string,
    userId: string,
    amount: number,
    ref: string,
  ): Promise<void> {
    // Double-check+mark paid first; wallet credit second.
    const { data: updated, error } = await this.sb
      .from('qpay_invoices')
      .update({ status: 'paid', paid_at: new Date().toISOString() })
      .eq('id', invoiceId)
      .eq('status', 'pending')
      .select('id');
    if (error) throw error;
    if (!updated || updated.length === 0) return; // already paid → no double credit
    await this.wallet.credit(userId, amount, `qpay:${ref}`, 'qpay');
    this.log.log(`[QPay] credited ${userId} amount=${amount}`);
  }

  // ─── Stubs to be replaced with real QPay HTTP calls ─────────────
  private async createAtQpay(amount: number) {
    const id = `STUB-${randomUUID()}`;
    return {
      id,
      qrText: `qpay:stub?id=${id}&amt=${amount}`,
      deepLink: `qpay://pay?invoice=${id}`,
    };
  }

  private async pollAtQpay(_qpayInvoiceId: string): Promise<'pending' | 'paid' | 'expired'> {
    return 'pending';
  }
}
