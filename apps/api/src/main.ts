import * as Sentry from '@sentry/node';
import helmet from 'helmet';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { SentryExceptionFilter } from './common/sentry.filter';

if (process.env.SENTRY_DSN) {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV ?? 'development',
    tracesSampleRate: 0.1,
    integrations: [Sentry.httpIntegration()],
  });
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    bodyParser: true,
    rawBody: true, // QPay webhook HMAC verification reads req.rawBody.
    cors: {
      // Strict origin allowlist — no `*` once we go to prod.
      origin: (process.env.CORS_ORIGINS ?? 'http://localhost:5173,http://localhost:3000').split(','),
      credentials: true,
    },
  });

  app.use(helmet({
    // Swagger /docs needs inline scripts; allow only there by loosening CSP.
    contentSecurityPolicy: process.env.NODE_ENV === 'production' ? undefined : false,
    crossOriginEmbedderPolicy: false,
  }));

  app.useGlobalFilters(new SentryExceptionFilter());
  app.setGlobalPrefix('v1');
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    transformOptions: { enableImplicitConversion: false },
  }));

  if (process.env.NODE_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('COP17 API')
      .setDescription('UNCCD COP17 Ulaanbaatar 2026 — mobile + admin API')
      .setVersion('0.1.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('docs', app, document);
  }

  const port = Number(process.env.API_PORT ?? 3000);
  await app.listen(port);
  console.log(`API listening on :${port}`);
}
bootstrap();
