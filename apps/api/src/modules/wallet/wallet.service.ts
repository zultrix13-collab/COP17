import { BadRequestException, ForbiddenException, Inject, Injectable } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE_ADMIN } from '../../supabase/supabase.module';

export interface CartItem {
  productId: string;
  quantity: number;
}

@Injectable()
export class WalletService {
  constructor(@Inject(SUPABASE_ADMIN) private readonly sb: SupabaseClient) {}

  async balance(userId: string): Promise<number> {
    const { data, error } = await this.sb
      .from('wallets')
      .select('balance')
      .eq('user_id', userId)
      .maybeSingle();
    if (error) throw error;
    return (data?.balance as number) ?? 0;
  }

  async debit(userId: string, amount: number, reference: string): Promise<number> {
    const { data, error } = await this.sb.rpc('rpc_wallet_debit', {
      p_user_id: userId,
      p_amount: amount,
      p_reference: reference,
    });
    if (error) {
      if (error.message.includes('insufficient funds')) {
        throw new BadRequestException('Insufficient wallet balance');
      }
      throw error;
    }
    return data as number;
  }

  async credit(
    userId: string,
    amount: number,
    reference: string,
    provider?: string,
  ): Promise<number> {
    const { data, error } = await this.sb.rpc('rpc_wallet_credit', {
      p_user_id: userId,
      p_amount: amount,
      p_reference: reference,
      p_provider: provider ?? null,
    });
    if (error) throw error;
    return data as number;
  }

  /**
   * Atomic purchase: look up products, build order, debit wallet, mark paid.
   * Uses `rpc_wallet_debit` for balance safety; the order insert + item insert
   * happen before debit so a failed debit rolls nothing back — acceptable
   * because `pending` orders are cleaned up by an out-of-band job.
   */
  async purchase(userId: string, items: CartItem[]) {
    if (items.length === 0) throw new BadRequestException('Empty cart');

    const productIds = items.map((i) => i.productId);
    const { data: products, error: pErr } = await this.sb
      .from('products')
      .select('id, price, name_mn, active, stock')
      .in('id', productIds);
    if (pErr) throw pErr;
    if (!products || products.length !== productIds.length) {
      throw new BadRequestException('Some products not found');
    }
    for (const p of products) {
      if (!p.active) throw new BadRequestException(`Product ${p.id} is inactive`);
    }

    const total = items.reduce((sum, i) => {
      const p = products.find((x) => x.id === i.productId)!;
      return sum + (p.price as number) * i.quantity;
    }, 0);

    // 1. Create pending order.
    const { data: order, error: oErr } = await this.sb
      .from('orders')
      .insert({ user_id: userId, total, status: 'pending' })
      .select('id')
      .single();
    if (oErr) throw oErr;

    // 2. Insert items (name_snap for receipt immutability).
    const rows = items.map((i) => {
      const p = products.find((x) => x.id === i.productId)!;
      return {
        order_id: order.id,
        product_id: p.id,
        quantity: i.quantity,
        unit_price: p.price,
        name_snap: p.name_mn,
      };
    });
    const { error: iErr } = await this.sb.from('order_items').insert(rows);
    if (iErr) throw iErr;

    // 3. Debit wallet (may throw insufficient funds).
    const newBalance = await this.debit(userId, total, `order:${order.id}`);

    // 4. Mark paid.
    const { error: uErr } = await this.sb
      .from('orders')
      .update({ status: 'paid', paid_at: new Date().toISOString() })
      .eq('id', order.id);
    if (uErr) throw uErr;

    return { orderId: order.id, total, balance: newBalance };
  }

  /** For unauthorized "spend someone else's wallet" protection at the HTTP layer. */
  assertSelf(requestedId: string, callerId: string) {
    if (requestedId !== callerId) throw new ForbiddenException();
  }
}
