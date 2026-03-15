import { Injectable, Logger, BadRequestException } from "@nestjs/common";
import { PrismaService } from "../../common/prisma/prisma.service";
import * as fs from "fs";
import * as path from "path";
import * as child_process from "child_process";
import * as util from "util";

const exec = util.promisify(child_process.exec);

@Injectable()
export class BackupService {
  private readonly logger = new Logger(BackupService.name);
  private readonly backupDir = path.join(process.cwd(), "backups");

  constructor(private readonly prisma: PrismaService) {
    // Ensure backups directory exists
    if (!fs.existsSync(this.backupDir)) {
      fs.mkdirSync(this.backupDir, { recursive: true });
    }
  }

  async exportBackup(): Promise<Buffer> {
    try {
      this.logger.log("Starting database backup export...");

      // Get database credentials from environment
      const dbUrl = process.env.DATABASE_URL;
      if (!dbUrl) {
        throw new Error("DATABASE_URL not configured");
      }

      // Parse PostgreSQL connection URL
      const url = new URL(dbUrl);
      const host = url.hostname;
      const port = url.port || "5432";
      const database = url.pathname.substring(1);
      const username = url.username;
      const password = url.password;

      // Generate timestamp for backup file
      const timestamp = new Date()
        .toISOString()
        .replace(/[:.]/g, "-")
        .split("T")[0];
      const backupFile = path.join(this.backupDir, `backup_${timestamp}.sql`);

      // Execute pg_dump
      const pgDumpCommand = `PGPASSWORD="${password}" pg_dump -h ${host} -p ${port} -U ${username} -d ${database} --no-password`;

      this.logger.log(
        `Executing pg_dump command for database: ${database}`
      );

      const { stdout } = await exec(pgDumpCommand);

      // Save to file
      fs.writeFileSync(backupFile, stdout);
      this.logger.log(`Backup saved to: ${backupFile}`);

      // Convert to buffer
      const buffer = Buffer.from(stdout);
      this.logger.log(
        `Backup export completed. Size: ${(buffer.length / 1024 / 1024).toFixed(2)}MB`
      );

      return buffer;
    } catch (error) {
      this.logger.error("Backup export failed:", error);
      throw new BadRequestException(
        `Failed to export backup: ${error.message}`
      );
    }
  }

  /**
   * Export tenant-specific backup including all inventory, sales, and related data
   */
  async exportTenantBackup(tenantId: string): Promise<Buffer> {
    try {
      this.logger.log(`Starting tenant backup export for tenantId: ${tenantId}`);

      const backupData: any = {
        metadata: {
          exportDate: new Date().toISOString(),
          tenantId,
          version: "1.0",
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
      ] = await Promise.all([
        this.prisma.tenant.findUnique({ where: { id: tenantId } }),
        this.prisma.user.findMany({ where: { tenantId } }),
        this.prisma.product.findMany({ where: { tenantId } }),
        this.prisma.productVariant.findMany({
          where: { tenantId },
          include: { product: true },
        }),
        this.prisma.inventoryItem.findMany({
          where: { tenantId },
          include: { variant: { include: { product: true } } },
        }),
        this.prisma.sale.findMany({
          where: { tenantId },
          include: { items: { include: { inventory: true } }, employee: true },
        }),
        this.prisma.saleItem.findMany({
          where: { inventory: { tenantId } },
          include: { inventory: true },
        }),
        this.prisma.shortList.findMany({
          where: { tenantId },
          include: { inventory: { include: { variant: true } } },
        }),
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
      };

      const jsonString = JSON.stringify(backupData, null, 2);
      const buffer = Buffer.from(jsonString, "utf-8");

      this.logger.log(
        `Tenant backup export completed. Size: ${(buffer.length / 1024 / 1024).toFixed(2)}MB`
      );

      return buffer;
    } catch (error) {
      this.logger.error("Tenant backup export failed:", error);
      throw new BadRequestException(
        `Failed to export tenant backup: ${error.message}`
      );
    }
  }

  async importBackup(fileBuffer: Buffer): Promise<{ success: boolean }> {
    try {
      this.logger.log("Starting database backup restore...");

      // Get database credentials from environment
      const dbUrl = process.env.DATABASE_URL;
      if (!dbUrl) {
        throw new Error("DATABASE_URL not configured");
      }

      // Parse PostgreSQL connection URL
      const url = new URL(dbUrl);
      const host = url.hostname;
      const port = url.port || "5432";
      const database = url.pathname.substring(1);
      const username = url.username;
      const password = url.password;

      // Create temporary file for backup
      const tempFile = path.join(
        this.backupDir,
        `restore_temp_${Date.now()}.sql`
      );
      fs.writeFileSync(tempFile, fileBuffer);

      this.logger.log(
        `Temporary backup file created at: ${tempFile}`
      );

      // Execute pg_restore or psql
      // For .sql files, we use psql
      const psqlCommand = `PGPASSWORD="${password}" psql -h ${host} -p ${port} -U ${username} -d ${database} -f "${tempFile}"`;

      this.logger.log(
        `Executing psql command to restore database: ${database}`
      );

      await exec(psqlCommand, { maxBuffer: 50 * 1024 * 1024 }); // 50MB buffer

      this.logger.log("Database restore completed successfully");

      // Clean up temporary file
      fs.unlinkSync(tempFile);

      return { success: true };
    } catch (error) {
      this.logger.error("Backup restore failed:", error);
      throw new BadRequestException(
        `Failed to restore backup: ${error.message}`
      );
    }
  }

  async getBackupStatus(): Promise<{
    lastBackup: Date | null;
    backupSize: number | null;
  }> {
    try {
      const files = fs.readdirSync(this.backupDir);
      const sqlFiles = files
        .filter((f) => f.startsWith("backup_") && f.endsWith(".sql"))
        .sort()
        .reverse();

      if (sqlFiles.length === 0) {
        return { lastBackup: null, backupSize: null };
      }

      const latestFile = sqlFiles[0];
      const filePath = path.join(this.backupDir, latestFile);
      const stats = fs.statSync(filePath);

      return {
        lastBackup: stats.mtime,
        backupSize: stats.size,
      };
    } catch (error) {
      this.logger.error("Failed to get backup status:", error);
      return { lastBackup: null, backupSize: null };
    }
  }

  async exportUserData(userId: string): Promise<Buffer> {
    try {
      this.logger.log(`Starting user data export for userId: ${userId}`);

      // Fetch user first to get tenantId
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
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
          where: { employeeId: userId },
          include: {
            items: true,
          },
        }),
        this.prisma.shortList.findMany({
          where: { tenantId: user.tenantId },
          include: {
            inventory: true,
          },
        }),
        this.prisma.inventoryItem.findMany({
          where: { tenantId: user.tenantId },
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
          totalRevenue: sales.reduce((sum, sale) => sum + (sale.totalAmount || 0), 0),
          shortListCount: shortListItems.length,
          inventoryItemsCount: inventoryItems.length,
        },
      };

      const jsonBuffer = Buffer.from(JSON.stringify(exportData, null, 2), 'utf-8');

      this.logger.log(
        `User data export completed for userId: ${userId}. Size: ${(jsonBuffer.length / 1024).toFixed(2)}KB`
      );

      return jsonBuffer;
    } catch (error) {
      this.logger.error("User data export failed:", error);
      throw new BadRequestException(
        `Failed to export user data: ${error.message}`
      );
    }
  }
}
