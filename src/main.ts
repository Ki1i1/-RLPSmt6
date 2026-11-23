import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import type { NextFunction, Request, Response } from 'express';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const requestLogger = new Logger('HTTP');
  const allowedOrigins = process.env.CORS_ORIGINS?.split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  app.use((request: Request, response: Response, next: NextFunction) => {
    const { method, path } = request;
    const start = Date.now();
    response.once('finish', () => {
      requestLogger.log(
        `${method} ${path} ${response.statusCode} ${Date.now() - start}ms`,
      );
    });
    next();
  });

  app.enableCors({
    origin: allowedOrigins?.length
      ? allowedOrigins
      : process.env.NODE_ENV !== 'production' && '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    allowedHeaders: 'Content-Type, Authorization',
  });

  await app.listen(process.env.PORT ?? 3000);
}
void bootstrap();
