import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function createBrandsFromProducts() {
  console.log('Creating brands from existing products...');

  // Get all products without brands
  const productsWithoutBrands = await prisma.product.findMany({
    where: {
      brandId: null
    },
    select: {
      id: true,
      name: true
    }
  });

  console.log(`Found ${productsWithoutBrands.length} products without brands`);

  // Group products by potential brand name (first word)
  const brandGroups: Record<string, { productIds: string[], name: string }> = {};

  for (const product of productsWithoutBrands) {
    // Extract first word as potential brand name
    const firstWord = product.name.split(' ')[0];

    // Clean up the brand name (capitalize first letter)
    const brandName = firstWord.charAt(0).toUpperCase() + firstWord.slice(1).toLowerCase();

    if (!brandGroups[brandName]) {
      brandGroups[brandName] = {
        productIds: [],
        name: brandName
      };
    }

    brandGroups[brandName].productIds.push(product.id);
  }

  console.log(`Grouped into ${Object.keys(brandGroups).length} potential brands`);

  let createdBrands = 0;
  let updatedProducts = 0;

  for (const [brandName, group] of Object.entries(brandGroups)) {
    try {
      // Check if brand already exists
      let brand = await prisma.brand.findFirst({
        where: { name: brandName }
      });

      if (!brand) {
        brand = await prisma.brand.create({
          data: { name: brandName }
        });
        console.log(`Created brand: ${brandName}`);
        createdBrands++;
      }

      // Update all products in this group to use this brand
      await prisma.product.updateMany({
        where: {
          id: { in: group.productIds }
        },
        data: {
          brandId: brand.id
        }
      });

      updatedProducts += group.productIds.length;
      console.log(`Updated ${group.productIds.length} products for brand: ${brandName}`);

    } catch (error) {
      console.error(`Error processing brand ${brandName}:`, error);
    }
  }

  console.log(`\nSummary:`);
  console.log(`- Created ${createdBrands} new brands`);
  console.log(`- Updated ${updatedProducts} products with brand associations`);
}

createBrandsFromProducts()
  .catch((e) => {
    console.error('Script failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });