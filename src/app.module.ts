import {Module} from '@nestjs/common';
import {ServeStaticModule} from '@nestjs/serve-static';
import {join} from 'path';
import {ConfigModule} from '@nestjs/config';
import {ThrottlerModule} from '@nestjs/throttler';
import {PrismaModule} from './common/prisma/prisma.module';
import {AuthModule} from './modules/auth/auth.module';
import {UsersModule} from './modules/users/users.module';
import {TenantsModule} from './modules/tenants/tenants.module';
import {CatalogModule} from './modules/catalog/catalog.module';
import {InventoryModule} from './modules/inventory/inventory.module';
import {ScheduleModule} from '@nestjs/schedule';
import {NotificationsModule} from './modules/notifications/notifications.module';
import {SalesModule} from './modules/sales/sales.module';
import {MedicineModule} from './modules/medicine/medicine.module';
import {ShortListModule} from './modules/shortlist/shortlist.module';
import {PdfExportModule} from './modules/pdf-export/pdf-export.module';
import {BackupModule} from './modules/backup/backup.module';
import {ExpensesModule} from './modules/expenses/expenses.module';
import {CashBoxModule} from './modules/cash-box/cash-box.module';
import {CreditsModule} from './modules/credits/credits.module';

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
    ShortListModule,
    PdfExportModule,
    BackupModule,
    ScheduleModule.forRoot(),
    ExpensesModule,
    CashBoxModule,
    CreditsModule,
  ],
})
export class AppModule {}
