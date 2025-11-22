import { PrismaClient } from '@prisma/client';
import * as child_process from 'child_process';
import * as util from 'util';

const exec = util.promisify(child_process.exec);

// Configuration
const LOCAL_DB_URL = "postgresql://postgres:postgres@localhost:5432/supershop_db_backup?schema=public";
// Prod DB via Proxy on port 5433 (we will start proxy there)
const PROD_DB_URL = "postgresql://supershop_user:MUJAHIDrumel123@123@127.0.0.1:5433/supershop?schema=public";

// Tables to sync in dependency order
const TABLES_TO_SYNC = [
    'Tenant',
    'User',
    'Brand',
    'Category',
    'Supplier',
    'Product',
    'ProductVariant',
    'InventoryItem',
    'Sale',
    'SaleItem'
];

async function main() {
    console.log('=== Syncing Missing Rows from Local to Production ===');

    // 1. Initialize Prisma Clients
    const localPrisma = new PrismaClient({
        datasources: { db: { url: LOCAL_DB_URL } },
    });

    const prodPrisma = new PrismaClient({
        datasources: { db: { url: PROD_DB_URL } },
    });

    try {
        // Verify connections
        await localPrisma.$connect();
        console.log('✅ Connected to Local DB');
        await prodPrisma.$connect();
        console.log('✅ Connected to Production DB');

        for (const modelName of TABLES_TO_SYNC) {
            console.log(`\n--- Processing Table: ${modelName} ---`);

            // @ts-ignore - Dynamic access to models
            const localModel = localPrisma[modelName.toLowerCase()]; // Prisma client properties are lowercase usually? No, usually camelCase of model name.
            // Actually, for model 'User', it is prisma.user. For 'ProductVariant', it is prisma.productVariant.
            const prismaModelName = modelName.charAt(0).toLowerCase() + modelName.slice(1);

            // @ts-ignore
            const localDelegate = localPrisma[prismaModelName];
            // @ts-ignore
            const prodDelegate = prodPrisma[prismaModelName];

            if (!localDelegate || !prodDelegate) {
                console.error(`❌ Could not find delegate for model ${modelName}`);
                continue;
            }

            // Fetch all IDs
            let localItems;
            let prodItems;
            try {
                localItems = await localDelegate.findMany();
                prodItems = await prodDelegate.findMany({ select: { id: true } });
            } catch (e: any) {
                console.error(`⚠️  Skipping ${modelName} due to error (likely schema mismatch): ${e.message.split('\n')[0]}`);
                continue;
            }

            const prodIds = new Set(prodItems.map((item: any) => item.id));

            const missingItems = localItems.filter((item: any) => !prodIds.has(item.id));

            if (missingItems.length === 0) {
                console.log(`No missing items for ${modelName}.`);
                continue;
            }

            console.log(`Found ${missingItems.length} missing items in ${modelName}. Inserting...`);

            let successCount = 0;
            let failCount = 0;

            for (const item of missingItems) {
                try {
                    await prodDelegate.create({ data: item });
                    process.stdout.write('.');
                    successCount++;
                } catch (error: any) {
                    // process.stdout.write('x');
                    // console.error(`\nFailed to insert ${modelName} ${item.id}: ${error.message}`);
                    failCount++;
                }
            }
            console.log(`\nFinished ${modelName}: ${successCount} inserted, ${failCount} failed.`);
        }

    } catch (error) {
        console.error('Fatal Error:', error);
    } finally {
        await localPrisma.$disconnect();
        await prodPrisma.$disconnect();
    }
}

main();
