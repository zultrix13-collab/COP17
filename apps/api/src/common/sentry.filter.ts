import * as Sentry from '@sentry/node';
import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';

/**
 * Global filter that forwards 5xx and unknown errors to Sentry while keeping
 * client-facing error shape untouched. 4xx validation/authz errors stay out
 * of the error bucket because they're user mistakes, not bugs.
 */
@Catch()
export class SentryExceptionFilter implements ExceptionFilter {
  private readonly log = new Logger('ExceptionFilter');

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse();
    const req = ctx.getRequest();

    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    if (status >= 500) {
      Sentry.withScope((scope) => {
        scope.setTag('url', req.url);
        scope.setTag('method', req.method);
        if (req.userId) scope.setUser({ id: req.userId });
        Sentry.captureException(exception);
      });
      this.log.error(exception instanceof Error ? exception.stack : String(exception));
    }

    const body = exception instanceof HttpException
      ? exception.getResponse()
      : { statusCode: status, message: 'Internal server error' };
    res.status(status).json(body);
  }
}
