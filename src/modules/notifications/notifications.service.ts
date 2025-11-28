import {Injectable, Logger} from '@nestjs/common';
import {Cron, CronExpression} from '@nestjs/schedule';
import * as webPush from 'web-push';
import {PrismaService} from '../../common/prisma/prisma.service';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(private prisma: PrismaService) {
    // VAPID keys should be in env vars, but for demo we'll generate/use hardcoded or env
    // In production, generate these once: npx web-push generate-vapid-keys
    const publicVapidKey =
      process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY || 'BBMc...';
    const privateVapidKey = process.env.VAPID_PRIVATE_KEY || '...';

    if (
      process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY &&
      process.env.VAPID_PRIVATE_KEY
    ) {
      webPush.setVapidDetails(
        'mailto:admin@supershop.com',
        process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY,
        process.env.VAPID_PRIVATE_KEY
      );
    }
  }

  async subscribe(userId: string, subscription: any) {
    return this.prisma.pushSubscription.create({
      data: {
        userId,
        endpoint: subscription.endpoint,
        keys: subscription.keys,
      },
    });
  }

  async sendNotification(userId: string, payload: any) {
    const subscriptions = await this.prisma.pushSubscription.findMany({
      where: {userId},
    });

    for (const sub of subscriptions) {
      try {
        await webPush.sendNotification(
          {
            endpoint: sub.endpoint,
            keys: sub.keys as any,
          },
          JSON.stringify(payload)
        );
      } catch (error) {
        this.logger.error(`Error sending notification to ${userId}`, error);
        if (error.statusCode === 410) {
          // Subscription expired/invalid
          await this.prisma.pushSubscription.delete({where: {id: sub.id}});
        }
      }
    }
  }

  // Check for low stock every hour
  @Cron(CronExpression.EVERY_HOUR)
  async checkLowStock() {
    this.logger.log('Checking low stock...');
    const tenants = await this.prisma.tenant.findMany();

    for (const tenant of tenants) {
      const threshold = (tenant.preferences as any)?.lowStockThreshold || 10;
      const lowStockItems = await this.prisma.inventoryItem.findMany({
        where: {
          tenantId: tenant.id,
          quantity: {lte: threshold},
        },
        include: {variant: {include: {product: true}}},
      });

      if (lowStockItems.length > 0) {
        // Notify tenant owner/employees
        const users = await this.prisma.user.findMany({
          where: {tenantId: tenant.id},
        });

        for (const user of users) {
          await this.sendNotification(user.id, {
            title: 'Low Stock Alert',
            body: `${lowStockItems.length} items are running low on stock.`,
            url: '/dashboard/inventory?filter=low-stock',
          });
        }
      }
    }
  }

  // Check for expiring items daily at 9 AM
  @Cron('0 9 * * *')
  async checkExpiringItems() {
    this.logger.log('Checking expiring items...');
    const tenants = await this.prisma.tenant.findMany();
    const daysThreshold = 30; // Alert 30 days before

    for (const tenant of tenants) {
      const futureDate = new Date();
      futureDate.setDate(futureDate.getDate() + daysThreshold);

      const expiringItems = await this.prisma.inventoryItem.findMany({
        where: {
          tenantId: tenant.id,
          expiryDate: {
            lte: futureDate,
            gte: new Date(),
          },
        },
        include: {variant: {include: {product: true}}},
      });

      if (expiringItems.length > 0) {
        const users = await this.prisma.user.findMany({
          where: {tenantId: tenant.id},
        });

        for (const user of users) {
          await this.sendNotification(user.id, {
            title: 'Expiry Alert',
            body: `${expiringItems.length} items are expiring within ${daysThreshold} days.`,
            url: '/dashboard/inventory?filter=expiring',
          });
        }
      }
    }
  }
}
