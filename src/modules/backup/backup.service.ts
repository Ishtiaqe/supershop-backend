import {Injectable, Logger, BadRequestException} from '@nestjs/common';
import {Prisma} from '@prisma/client';
import {PrismaService} from '../../common/prisma/prisma.service';

@Injectable()
export class BackupService {
  private readonly logger = new Logger(BackupService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Export tenant-specific backup including all inventory, sales, and related data
   */
  async exportTenantBackup(tenantId: string): Promise<Buffer> {
    try {
      this.logger.log(
        `Starting tenant backup export for tenantId: ${tenantId}`
      );

      const backupData: any = {
        metadata: {
          exportDate: new Date().toISOString(),
          tenantId,
          version: '1.0',
        },
        data: {},
      };

      // Export all tenant-related data
      const [
        tenant,
        users,
        products,
        variants,
        inventory,
        sales,
        saleItems,
        shortList,
        expenseCategories,
        expenses,
        cashBoxEntries,
        creditPayments,
      ] = await Promise.all([
        this.prisma.tenant.findUnique({where: {id: tenantId}}),
        this.prisma.user.findMany({where: {tenantId}}),
        this.prisma.product.findMany({where: {tenantId}}),
        this.prisma.productVariant.findMany({
          where: {tenantId},
          include: {product: true},
        }),
        this.prisma.inventoryItem.findMany({
          where: {tenantId},
          include: {variant: {include: {product: true}}},
        }),
        this.prisma.sale.findMany({
          where: {tenantId},
          include: {items: {include: {inventory: true}}, employee: true},
        }),
        this.prisma.saleItem.findMany({
          where: {inventory: {tenantId}},
          include: {inventory: true},
        }),
        this.prisma.shortList.findMany({
          where: {tenantId},
          include: {inventory: {include: {variant: true}}},
        }),
        this.prisma.expenseCategory.findMany({where: {tenantId}}),
        this.prisma.expense.findMany({where: {tenantId}}),
        this.prisma.cashBoxEntry.findMany({where: {tenantId}}),
        this.prisma.creditPayment.findMany({where: {tenantId}}),
      ]);

      backupData.data = {
        tenant,
        users,
        products,
        variants,
        inventory,
        sales,
        saleItems,
        shortList,
        expenseCategories,
        expenses,
        cashBoxEntries,
        creditPayments,
      };

      const jsonString = JSON.stringify(backupData, null, 2);
      const buffer = Buffer.from(jsonString, 'utf-8');

      this.logger.log(
        `Tenant backup export completed. Size: ${(
          buffer.length /
          1024 /
          1024
        ).toFixed(2)}MB`
      );

      return buffer;
    } catch (error) {
      this.logger.error('Tenant backup export failed:', error);
      throw new BadRequestException(
        `Failed to export tenant backup: ${error.message}`
      );
    }
  }

  /**
   * Restore a tenant's catalog/inventory/sales data from a backup produced by
   * exportTenantBackup. Scoped entirely to the calling tenant: the backup's
   * tenantId must match, and only that tenant's products, variants, inventory,
   * sales, sale items, and short-list entries are replaced. User accounts and
   * shop settings are never touched, so the restoring owner can't lock
   * themselves out.
   */
  async importTenantBackup(
    tenantId: string,
    requestingUserId: string,
    fileBuffer: Buffer
  ): Promise<{success: boolean; restored: Record<string, number>}> {
    let backup: any;
    try {
      backup = JSON.parse(fileBuffer.toString('utf-8'));
    } catch {
      throw new BadRequestException('Invalid backup file: not valid JSON');
    }

    if (!backup?.metadata?.tenantId || !backup?.data) {
      throw new BadRequestException(
        'Invalid backup file: missing metadata or data'
      );
    }

    if (backup.metadata.tenantId !== tenantId) {
      throw new BadRequestException(
        'This backup belongs to a different shop and cannot be restored here'
      );
    }

    const data = backup.data ?? {};
    const products: any[] = Array.isArray(data.products) ? data.products : [];
    const variants: any[] = Array.isArray(data.variants) ? data.variants : [];
    const inventory: any[] = Array.isArray(data.inventory)
      ? data.inventory
      : [];
    const sales: any[] = Array.isArray(data.sales) ? data.sales : [];
    const saleItems: any[] = Array.isArray(data.saleItems)
      ? data.saleItems
      : [];
    const shortList: any[] = Array.isArray(data.shortList)
      ? data.shortList
      : [];
    const expenseCategories: any[] = Array.isArray(data.expenseCategories)
      ? data.expenseCategories
      : [];
    const expenses: any[] = Array.isArray(data.expenses) ? data.expenses : [];
    const cashBoxEntries: any[] = Array.isArray(data.cashBoxEntries)
      ? data.cashBoxEntries
      : [];
    const creditPayments: any[] = Array.isArray(data.creditPayments)
      ? data.creditPayments
      : [];

    const tenantUsers = await this.prisma.user.findMany({
      where: {tenantId},
      select: {id: true},
    });
    const tenantUserIds = new Set(tenantUsers.map((u) => u.id));

    const productIds = new Set<string>();
    const cleanProducts = products.map((p) => {
      const {brand, category, variants: _variants, tenant, ...rest} = p;
      productIds.add(rest.id);
      return {...rest, tenantId};
    });

    const variantIds = new Set<string>();
    const cleanVariants = variants
      .filter((v) => productIds.has(v.productId))
      .map((v) => {
        const {product, inventoryItems, tenant, ...rest} = v;
        variantIds.add(rest.id);
        return {...rest, tenantId};
      });

    const inventoryIds = new Set<string>();
    const cleanInventory = inventory.map((i) => {
      const {
        variant,
        saleItems: _saleItems,
        shortListEntry,
        tenant,
        ...rest
      } = i;
      inventoryIds.add(rest.id);
      return {
        ...rest,
        tenantId,
        variantId:
          rest.variantId && variantIds.has(rest.variantId)
            ? rest.variantId
            : null,
      };
    });

    const saleIds = new Set<string>();
    const cleanSales = sales.map((s) => {
      const {items, employee, tenant, ...rest} = s;
      saleIds.add(rest.id);
      return {
        ...rest,
        tenantId,
        employeeId: tenantUserIds.has(rest.employeeId)
          ? rest.employeeId
          : requestingUserId,
      };
    });

    const cleanSaleItems = saleItems
      .filter(
        (si) => saleIds.has(si.saleId) && inventoryIds.has(si.inventoryId)
      )
      .map((si) => {
        const {inventory: _inventory, sale, ...rest} = si;
        return rest;
      });

    const cleanShortList = shortList
      .filter((sl) => inventoryIds.has(sl.inventoryId))
      .map((sl) => {
        const {inventory: _inventory, tenant, ...rest} = sl;
        return {...rest, tenantId};
      });

    const cleanExpenseCategories = expenseCategories.map((ec) => {
      const {tenant, expenses: _expenses, ...rest} = ec;
      return {...rest, tenantId};
    });

    const expenseCategoryIds = new Set(
      cleanExpenseCategories.map((ec) => ec.id)
    );
    const cleanExpenses = expenses
      .filter((e) => expenseCategoryIds.has(e.categoryId))
      .map((e) => {
        const {tenant, employee, category, ...rest} = e;
        return {
          ...rest,
          tenantId,
          employeeId: tenantUserIds.has(rest.employeeId)
            ? rest.employeeId
            : requestingUserId,
        };
      });

    const cleanCashBoxEntries = cashBoxEntries.map((cb) => {
      const {tenant, createdBy, ...rest} = cb;
      return {
        ...rest,
        tenantId,
        createdById: tenantUserIds.has(rest.createdById)
          ? rest.createdById
          : requestingUserId,
      };
    });

    const cleanCreditPayments = creditPayments
      .filter((cp) => saleIds.has(cp.saleId))
      .map((cp) => {
        const {tenant, sale, createdBy, ...rest} = cp;
        return {
          ...rest,
          tenantId,
          createdById: tenantUserIds.has(rest.createdById)
            ? rest.createdById
            : requestingUserId,
        };
      });

    this.logger.log(
      `Restoring tenant ${tenantId}: ${cleanProducts.length} products, ${cleanVariants.length} variants, ` +
        `${cleanInventory.length} inventory items, ${cleanSales.length} sales, ${cleanSaleItems.length} sale items, ` +
        `${cleanShortList.length} short-list entries, ${cleanExpenseCategories.length} expense categories, ` +
        `${cleanExpenses.length} expenses, ${cleanCashBoxEntries.length} cash box entries, ` +
        `${cleanCreditPayments.length} credit payments`
    );

    try {
      const restored = await this.prisma.$transaction(
        async (tx) => {
          // Delete existing tenant data, children before parents
          await this.deleteTenantDataInTransaction(tx, tenantId);

          // Recreate, parents before children
          if (cleanProducts.length) {
            await tx.product.createMany({data: cleanProducts});
          }
          if (cleanVariants.length) {
            await tx.productVariant.createMany({data: cleanVariants});
          }
          if (cleanInventory.length) {
            await tx.inventoryItem.createMany({data: cleanInventory});
          }
          if (cleanSales.length) {
            await tx.sale.createMany({data: cleanSales});
          }
          if (cleanSaleItems.length) {
            await tx.saleItem.createMany({data: cleanSaleItems});
          }
          if (cleanShortList.length) {
            await tx.shortList.createMany({data: cleanShortList});
          }
          if (cleanExpenseCategories.length) {
            await tx.expenseCategory.createMany({
              data: cleanExpenseCategories,
              skipDuplicates: true,
            });
          }
          if (cleanExpenses.length) {
            await tx.expense.createMany({data: cleanExpenses});
          }
          if (cleanCashBoxEntries.length) {
            await tx.cashBoxEntry.createMany({data: cleanCashBoxEntries});
          }
          if (cleanCreditPayments.length) {
            await tx.creditPayment.createMany({data: cleanCreditPayments});
          }

          return {
            products: cleanProducts.length,
            variants: cleanVariants.length,
            inventory: cleanInventory.length,
            sales: cleanSales.length,
            saleItems: cleanSaleItems.length,
            shortList: cleanShortList.length,
            expenseCategories: cleanExpenseCategories.length,
            expenses: cleanExpenses.length,
            cashBoxEntries: cleanCashBoxEntries.length,
            creditPayments: cleanCreditPayments.length,
          };
        },
        {timeout: 60000, maxWait: 10000}
      );

      this.logger.log(`Tenant ${tenantId} restore completed successfully`);
      return {success: true, restored};
    } catch (error) {
      this.logger.error(`Tenant ${tenantId} restore failed:`, error);
      throw new BadRequestException(
        `Failed to restore backup: ${error.message}`
      );
    }
  }

  /**
   * Delete a tenant's catalog/inventory/sales data. Children are removed
   * before parents to satisfy FK constraints. User accounts and shop
   * settings are never touched.
   */
  private async deleteTenantDataInTransaction(
    tx: Prisma.TransactionClient,
    tenantId: string
  ): Promise<void> {
    // Delete most-dependent children first
    await tx.creditPayment.deleteMany({where: {tenantId}});
    await tx.shortList.deleteMany({where: {tenantId}});
    await tx.saleItem.deleteMany({where: {sale: {tenantId}}});
    await tx.sale.deleteMany({where: {tenantId}});
    await tx.cashBoxEntry.deleteMany({where: {tenantId}});
    await tx.expense.deleteMany({where: {tenantId}});
    await tx.inventoryItem.deleteMany({where: {tenantId}});
    await tx.productVariant.deleteMany({where: {tenantId}});
    await tx.product.deleteMany({where: {tenantId}});
    await tx.expenseCategory.deleteMany({where: {tenantId}});
  }

  /**
   * Permanently delete all of a tenant's products, variants, inventory,
   * sales, sale items, and short-list entries. Intended to be used together
   * with exportTenantBackup/importTenantBackup for a clean restore.
   */
  async deleteTenantData(tenantId: string): Promise<{
    success: boolean;
    deleted: Record<string, number>;
  }> {
    const before = await this.getBackupStatus(tenantId);
    const [shortListCount, saleItemCount] = await Promise.all([
      this.prisma.shortList.count({where: {tenantId}}),
      this.prisma.saleItem.count({where: {sale: {tenantId}}}),
    ]);

    try {
      await this.prisma.$transaction(
        async (tx) => {
          await this.deleteTenantDataInTransaction(tx, tenantId);
        },
        {timeout: 60000, maxWait: 10000}
      );

      this.logger.log(`Tenant ${tenantId} data deleted successfully`);
      return {
        success: true,
        deleted: {
          products: before.productCount,
          variants: before.variantCount,
          inventory: before.inventoryCount,
          sales: before.saleCount,
          saleItems: saleItemCount,
          shortList: shortListCount,
        },
      };
    } catch (error) {
      this.logger.error(`Tenant ${tenantId} data deletion failed:`, error);
      throw new BadRequestException(`Failed to delete data: ${error.message}`);
    }
  }

  /**
   * Summary of what a backup for this tenant would currently contain.
   */
  async getBackupStatus(tenantId: string): Promise<{
    productCount: number;
    variantCount: number;
    inventoryCount: number;
    saleCount: number;
  }> {
    const [productCount, variantCount, inventoryCount, saleCount] =
      await Promise.all([
        this.prisma.product.count({where: {tenantId}}),
        this.prisma.productVariant.count({where: {tenantId}}),
        this.prisma.inventoryItem.count({where: {tenantId}}),
        this.prisma.sale.count({where: {tenantId}}),
      ]);

    return {productCount, variantCount, inventoryCount, saleCount};
  }

  async exportUserData(userId: string): Promise<Buffer> {
    try {
      this.logger.log(`Starting user data export for userId: ${userId}`);

      // Fetch user first to get tenantId
      const user = await this.prisma.user.findUnique({
        where: {id: userId},
        include: {
          tenant: {
            select: {
              id: true,
              name: true,
            },
          },
        },
      });

      if (!user) {
        throw new BadRequestException(`User with ID ${userId} not found`);
      }

      // Fetch all user-related data from all tables
      const [sales, shortListItems, inventoryItems] = await Promise.all([
        this.prisma.sale.findMany({
          where: {employeeId: userId},
          include: {
            items: true,
          },
        }),
        this.prisma.shortList.findMany({
          where: {tenantId: user.tenantId},
          include: {
            inventory: true,
          },
        }),
        this.prisma.inventoryItem.findMany({
          where: {tenantId: user.tenantId},
          take: 100, // Limit to prevent huge exports
        }),
      ]);

      const exportData = {
        exportDate: new Date().toISOString(),
        userId,
        user: {
          id: user?.id,
          email: user?.email,
          fullName: user?.fullName,
          role: user?.role,
          createdAt: user?.createdAt,
          tenant: user?.tenant,
        },
        data: {
          salesTransactions: sales,
          shortListItems: shortListItems,
          inventoryOverview: {
            totalItems: inventoryItems.length,
            items: inventoryItems,
          },
        },
        summary: {
          totalSales: sales.length,
          totalRevenue: sales.reduce(
            (sum, sale) => sum + (sale.totalAmount || 0),
            0
          ),
          shortListCount: shortListItems.length,
          inventoryItemsCount: inventoryItems.length,
        },
      };

      const jsonBuffer = Buffer.from(
        JSON.stringify(exportData, null, 2),
        'utf-8'
      );

      this.logger.log(
        `User data export completed for userId: ${userId}. Size: ${(
          jsonBuffer.length / 1024
        ).toFixed(2)}KB`
      );

      return jsonBuffer;
    } catch (error) {
      this.logger.error('User data export failed:', error);
      throw new BadRequestException(
        `Failed to export user data: ${error.message}`
      );
    }
  }
}
