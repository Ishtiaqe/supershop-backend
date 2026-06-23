import {NestFactory} from '@nestjs/core';
import {ValidationPipe} from '@nestjs/common';
import {ConfigService} from '@nestjs/config';
import {SwaggerModule, DocumentBuilder} from '@nestjs/swagger';
import {AppModule} from './app.module';
import * as cookieParser from 'cookie-parser';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Cookie parser middleware
  app.use(cookieParser());

  // Global prefix
  const apiPrefix = configService.get('API_PREFIX') || 'api';
  const apiVersion = configService.get('API_VERSION') || 'v1';
  app.setGlobalPrefix(`${apiPrefix}/${apiVersion}`);

  // CORS
  let corsOrigins = configService.get('CORS_ORIGIN')?.split(',') || [
    'http://localhost:3000',
  ];

  // In development, ensure localhost origins are allowed (useful for local testing and Playwright)
  if (
    (process.env.NODE_ENV || configService.get('NODE_ENV')) === 'development'
  ) {
    const devOrigins = [
      'http://localhost:3000',
      'http://127.0.0.1:3000',
      'http://localhost',
    ];
    corsOrigins = Array.from(new Set([...corsOrigins, ...devOrigins]));
  }
  // For development, allow any localhost origin on any port for convenience (e.g. 3000/3001).
  // In production, only allow exact origins listed in CORS_ORIGIN.
  if (
    (process.env.NODE_ENV || configService.get('NODE_ENV')) === 'development'
  ) {
    app.enableCors({
      origin: (origin, callback) => {
        if (!origin) return callback(null, true); // allow server-to-server requests or curl
        const localhostMatch = /^https?:\/\/localhost(:\d+)?$/i;
        const allowed =
          localhostMatch.test(origin) || corsOrigins.includes(origin);
        callback(null, allowed);
      },
      credentials: true,
    });
  } else {
    app.enableCors({
      origin: corsOrigins,
      credentials: true,
    });
  }

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    })
  );

  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('SuperShop API')
    .setDescription('Multi-tenant Shop Management System API')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  // Prefer the platform provided PORT environment variable (Cloud Run/Heroku) and
  // fall back to configuration or a sensible default. Ensure value is a number.
  const envPort = process.env.PORT ? Number(process.env.PORT) : undefined;
  const configPort = configService.get('PORT')
    ? Number(configService.get('PORT'))
    : undefined;
  const port = envPort || configPort || 8080;
  console.log(
    `📦 Bootstrapping: effective env PORT=${process.env.PORT ?? '<not set>'}`
  );
  await app.listen(port, '0.0.0.0');

  console.log(`🚀 Application is running on: http://0.0.0.0:${port}`);
  console.log(
    `🔎 Effective PORT env: ${process.env.PORT ?? '<not set>'}, config PORT: ${
      configService.get('PORT') ?? '<not set>'
    }`
  );
  console.log(`📚 API Documentation: http://localhost:${port}/api/docs`);
}

bootstrap();
