import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function migrateAdHocInventoryToCatalog() {
  console.log('Starting migration of ad-hoc inventory items to catalog...');

  // Find all inventory items without variantId (ad-hoc items)
  const adHocItems = await prisma.inventoryItem.findMany({
    where: {
      variantId: null,
      itemName: {
        not: null
      }
    },
    select: {
      id: true,
      itemName: true,
      retailPrice: true,
      tenantId: true
    }
  });

  console.log(`Found ${adHocItems.length} ad-hoc inventory items`);

  // Group by itemName to avoid duplicates
  const groupedItems = adHocItems.reduce((acc, item) => {
    const key = item.itemName!;
    if (!acc[key]) {
      acc[key] = [];
    }
    acc[key].push(item);
    return acc;
  }, {} as Record<string, typeof adHocItems>);

  console.log(`Grouped into ${Object.keys(groupedItems).length} unique product names`);

  let migratedCount = 0;

  for (const [itemName, items] of Object.entries(groupedItems)) {
    try {
      // Check if product already exists (in case of partial migration)
      let existingProduct = await prisma.product.findFirst({
        where: { name: itemName },
        include: { variants: true }
      });

      let variantId: string;

      if (existingProduct) {
        // Use existing product and its first variant
        variantId = existingProduct.variants[0].id;
        console.log(`Using existing product: ${itemName}`);
      } else {
        // Create new product and variant
        const product = await prisma.product.create({
          data: {
            name: itemName,
            productType: 'GENERAL'
          }
        });

        // Use retail price from the first item, or a default
        const retailPrice = items[0].retailPrice || 0;

        // Generate SKU - simple approach: lowercase name with spaces replaced
        const sku = itemName.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');

        const variant = await prisma.productVariant.create({
          data: {
            productId: product.id,
            variantName: 'Standard',
            sku: sku,
            retailPrice: retailPrice
          }
        });

        variantId = variant.id;
        console.log(`Created new product: ${itemName} with SKU: ${sku}`);
      }

      // Update all inventory items with this itemName to use the variantId
      const itemIds = items.map(item => item.id);
      await prisma.inventoryItem.updateMany({
        where: {
          id: { in: itemIds }
        },
        data: {
          variantId: variantId
        }
      });

      migratedCount += items.length;
      console.log(`Updated ${items.length} inventory items for: ${itemName}`);

    } catch (error) {
      console.error(`Error migrating ${itemName}:`, error);
    }
  }

  console.log(`Migration completed. Total items migrated: ${migratedCount}`);
}

migrateAdHocInventoryToCatalog()
  .catch((e) => {
    console.error('Migration failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });