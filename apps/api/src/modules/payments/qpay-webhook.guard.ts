import {
  CanActivate,
  ExecutionContext,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { createHmac, timingSafeEqual } from 'node:crypto';

/**
 * QPay webhook signature verification.
 * - In prod, set `QPAY_WEBHOOK_SECRET` and have QPay sign the raw body.
 * - In dev, we allow through with a warning so the stub flow still works.
 *
 * Assumes QPay sends `X-QPay-Signature: sha256=<hex>` header computed over
 * the raw JSON body (standard HMAC-SHA256 convention).
 */
@Injectable()
export class QPayWebhookGuard implements CanActivate {
  private readonly log = new Logger(QPayWebhookGuard.name);

  canActivate(ctx: ExecutionContext): boolean {
    const req = ctx.switchToHttp().getRequest();
    const secret = process.env.QPAY_WEBHOOK_SECRET;
    if (!secret) {
      if (process.env.NODE_ENV === 'production') {
        throw new Error('QPAY_WEBHOOK_SECRET must be set in production');
      }
      this.log.warn('QPAY_WEBHOOK_SECRET not set — accepting webhook without verification (DEV)');
      return true;
    }

    const header: string | undefined = req.headers['x-qpay-signature'];
    const sig = header?.replace(/^sha256=/, '');
    if (!sig) throw new UnauthorizedException('Missing signature');

    const rawBody: Buffer | undefined = req.rawBody;
    if (!rawBody) throw new UnauthorizedException('Missing raw body');

    const expected = createHmac('sha256', secret).update(rawBody).digest('hex');
    const a = Buffer.from(sig);
    const b = Buffer.from(expected);
    if (a.length !== b.length || !timingSafeEqual(a, b)) {
      throw new UnauthorizedException('Bad signature');
    }
    return true;
  }
}
