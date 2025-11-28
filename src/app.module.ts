import {Module} from '@nestjs/common';
import {ServeStaticModule} from '@nestjs/serve-static';
import {join} from 'path';
import {ConfigModule} from '@nestjs/config';
import {ThrottlerModule} from '@nestjs/throttler';
import {PrismaModule} from './common/prisma/prisma.module';
import {HealthModule} from './common/health/health.module';
import {AuthModule} from './modules/auth/auth.module';
import {UsersModule} from './modules/users/users.module';
import {TenantsModule} from './modules/tenants/tenants.module';
import {CatalogModule} from './modules/catalog/catalog.module';
import {InventoryModule} from './modules/inventory/inventory.module';
import {ScheduleModule} from '@nestjs/schedule';
import {NotificationsModule} from './modules/notifications/notifications.module';
import {SalesModule} from './modules/sales/sales.module';
import {MedicineModule} from './modules/medicine/medicine.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '.env.production'],
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60000,
        limit: 10,
      },
    ]),
    PrismaModule,
    HealthModule,
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'img'),
      serveRoot: '/img',
      serveStaticOptions: {
        setHeaders: (res, path, stat) => {
          res.set('Cache-Control', 'public, max-age=31536000, immutable');
        },
      },
    }),
    // CacheModule removed — we rely on frontend sessionStorage for typeahead caching
    AuthModule,
    UsersModule,
    TenantsModule,
    CatalogModule,
    InventoryModule,
    SalesModule,
    NotificationsModule,
    MedicineModule,
    ScheduleModule.forRoot(),
  ],
})
export class AppModule {}
