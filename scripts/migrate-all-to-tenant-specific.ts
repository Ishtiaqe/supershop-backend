import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function migrateAllToTenantSpecific() {
  console.log('Starting comprehensive tenant-specific migration...');

  // Get all tenants
  const tenants = await prisma.tenant.findMany({
    select: { id: true, name: true }
  });

  if (tenants.length === 0) {
    throw new Error('No tenants found');
  }

  console.log(`Found ${tenants.length} tenants`);

  // 1. Migrate Categories - assign to first tenant for now
  console.log('Migrating categories...');
  const categories = await prisma.category.findMany();
  for (const category of categories) {
    await prisma.category.update({
      where: { id: category.id },
      data: { tenantId: tenants[0].id }
    });
  }
  console.log(`Migrated ${categories.length} categories to tenant: ${tenants[0].name}`);

  // 2. Migrate Suppliers - assign based on restock receipts
  console.log('Migrating suppliers...');
  const suppliers = await prisma.supplier.findMany({
    include: {
      restockReceipts: {
        select: { tenantId: true }
      }
    }
  });

  for (const supplier of suppliers) {
    let tenantId = tenants[0].id; // default

    if (supplier.restockReceipts.length > 0) {
      // Use the tenant from the first restock receipt
      tenantId = supplier.restockReceipts[0].tenantId;
    }

    await prisma.supplier.update({
      where: { id: supplier.id },
      data: { tenantId }
    });
  }
  console.log(`Migrated ${suppliers.length} suppliers`);

  // 3. Migrate Products - assign based on inventory or variants
  console.log('Migrating products...');
  const products = await prisma.product.findMany({
    include: {
      variants: {
        include: {
          inventoryItems: {
            select: { tenantId: true, quantity: true }
          }
        }
      }
    }
  });

  for (const product of products) {
    let tenantId = tenants[0].id; // default

    // Calculate which tenant has the most inventory for this product
    const tenantInventory: Record<string, number> = {};
    for (const variant of product.variants) {
      for (const inventoryItem of variant.inventoryItems) {
        tenantInventory[inventoryItem.tenantId] = (tenantInventory[inventoryItem.tenantId] || 0) + inventoryItem.quantity;
      }
    }

    // Find tenant with most inventory
    let maxQuantity = 0;
    for (const [tid, quantity] of Object.entries(tenantInventory)) {
      if (quantity > maxQuantity) {
        maxQuantity = quantity;
        tenantId = tid;
      }
    }

    await prisma.product.update({
      where: { id: product.id },
      data: { tenantId }
    });

    // Also update all variants for this product
    for (const variant of product.variants) {
      await prisma.productVariant.update({
        where: { id: variant.id },
        data: { tenantId }
      });
    }
  }
  console.log(`Migrated ${products.length} products and their variants`);

  console.log('Migration completed successfully!');
  console.log('All catalog data is now tenant-specific.');
}

migrateAllToTenantSpecific()
  .catch((e) => {
    console.error('Migration failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });