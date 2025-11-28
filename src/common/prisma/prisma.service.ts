import {Injectable, OnModuleInit, OnModuleDestroy} from '@nestjs/common';
import {PrismaClient} from '@prisma/client';

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  async onModuleInit() {
    // If running locally and you want to skip DB (for fast smoke tests), set
    // DISABLE_DB=true in the environment. This avoids failing startup when a
    // DB is not available during local development.
    if (process.env.DISABLE_DB === 'true') {
      console.log(
        'PrismaService: DISABLE_DB=true, skipping database connection.'
      );
      return;
    }

    try {
      await this.$connect();
    } catch (error) {
      // Log connection failure. Cloud Run startup will fail if DB isn't available,
      // but this log makes debugging logs easier in the Cloud console.
      // Re-throw to let the platform know startup failed.
      console.error('PrismaService: failed to connect to the database:', error);
      // If the environment explicitly asks to ignore DB connection errors,
      // don't fail the startup — useful for smoke-testing the API.
      if (process.env.IGNORE_DB_CONNECT_ERRORS === 'true') {
        console.warn(
          'PrismaService: ignoring DB connection failure due to IGNORE_DB_CONNECT_ERRORS=true'
        );
        return;
      }

      throw error;
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
