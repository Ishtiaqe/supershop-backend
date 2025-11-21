import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function migrateBrandsToTenantSpecific() {
  console.log('Migrating brands to be tenant-specific...');

  // Get all existing brands
  const brands = await prisma.brand.findMany({
    include: {
      products: {
        include: {
          variants: {
            include: {
              inventoryItems: {
                select: {
                  tenantId: true,
                  quantity: true
                }
              }
            }
          }
        }
      }
    }
  });

  console.log(`Found ${brands.length} brands to migrate`);

  for (const brand of brands) {
    // Calculate which tenant has the most inventory for this brand's products
    const tenantInventory: Record<string, number> = {};

    for (const product of brand.products) {
      for (const variant of product.variants) {
        for (const inventoryItem of variant.inventoryItems) {
          const tenantId = inventoryItem.tenantId;
          tenantInventory[tenantId] = (tenantInventory[tenantId] || 0) + inventoryItem.quantity;
        }
      }
    }

    // Find the tenant with the most inventory
    let maxTenantId: string | null = null;
    let maxQuantity = 0;

    for (const [tenantId, quantity] of Object.entries(tenantInventory)) {
      if (quantity > maxQuantity) {
        maxQuantity = quantity;
        maxTenantId = tenantId;
      }
    }

    if (maxTenantId) {
      // Update the brand to belong to this tenant
      await prisma.brand.update({
        where: { id: brand.id },
        data: { tenantId: maxTenantId }
      });
      console.log(`Assigned brand "${brand.name}" to tenant ${maxTenantId} (inventory: ${maxQuantity})`);
    } else {
      // If no inventory found, assign to the first tenant as fallback
      const firstTenant = await prisma.tenant.findFirst();
      if (firstTenant) {
        await prisma.brand.update({
          where: { id: brand.id },
          data: { tenantId: firstTenant.id }
        });
        console.log(`Assigned brand "${brand.name}" to first tenant ${firstTenant.id} (no inventory found)`);
      }
    }
  }

  console.log('Brand migration completed');
}

migrateBrandsToTenantSpecific()
  .catch((e) => {
    console.error('Migration failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });