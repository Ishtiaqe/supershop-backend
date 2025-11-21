import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function createSampleData() {
  try {
    console.log('Creating sample catalog data for Safe Pharma tenant...');

    // Get the Safe Pharma tenant
    const tenant = await prisma.tenant.findFirst({
      where: { name: 'Safe Pharma' }
    });

    if (!tenant) {
      console.log('Safe Pharma tenant not found');
      return;
    }

    console.log('Found tenant:', tenant.name, 'ID:', tenant.id);

    // Create some basic categories
    const categories = [
      'Medicines',
      'Supplements',
      'Personal Care',
      'Baby Care',
      'Household'
    ];

    for (const catName of categories) {
      const existing = await prisma.category.findFirst({
        where: { name: catName, tenantId: tenant.id }
      });

      if (!existing) {
        await prisma.category.create({
          data: {
            name: catName,
            tenantId: tenant.id
          }
        });
        console.log('Created category:', catName);
      }
    }

    // Create some brands
    const brands = [
      'PharmaCorp',
      'HealthPlus',
      'MediCare',
      'Wellness Labs'
    ];

    for (const brandName of brands) {
      const existing = await prisma.brand.findFirst({
        where: { name: brandName, tenantId: tenant.id }
      });

      if (!existing) {
        await prisma.brand.create({
          data: {
            name: brandName,
            tenantId: tenant.id
          }
        });
        console.log('Created brand:', brandName);
      }
    }

    // Create some sample products
    const sampleProducts = [
      {
        name: 'Paracetamol 500mg',
        productType: 'MEDICINE' as const,
        categoryName: 'Medicines',
        brandName: 'PharmaCorp',
        variants: [
          { name: 'Strip of 10', sku: 'PARA-500-10', price: 2.50 },
          { name: 'Bottle of 100', sku: 'PARA-500-100', price: 15.00 }
        ]
      },
      {
        name: 'Vitamin C 1000mg',
        productType: 'GENERAL' as const,
        categoryName: 'Supplements',
        brandName: 'HealthPlus',
        variants: [
          { name: 'Bottle of 60', sku: 'VITC-1000-60', price: 12.99 }
        ]
      },
      {
        name: 'Baby Shampoo',
        productType: 'GENERAL' as const,
        categoryName: 'Baby Care',
        brandName: 'MediCare',
        variants: [
          { name: '200ml', sku: 'BABY-SHAM-200', price: 8.50 }
        ]
      }
    ];

    for (const prodData of sampleProducts) {
      // Get category and brand
      const category = await prisma.category.findFirst({
        where: { name: prodData.categoryName, tenantId: tenant.id }
      });

      const brand = await prisma.brand.findFirst({
        where: { name: prodData.brandName, tenantId: tenant.id }
      });

      if (!category || !brand) {
        console.log('Missing category or brand for:', prodData.name);
        continue;
      }

      // Create product
      const product = await prisma.product.create({
        data: {
          name: prodData.name,
          productType: prodData.productType,
          tenantId: tenant.id,
          categoryId: category.id,
          brandId: brand.id
        }
      });

      // Create variants
      for (const variant of prodData.variants) {
        await prisma.productVariant.create({
          data: {
            productId: product.id,
            tenantId: tenant.id,
            variantName: variant.name,
            sku: variant.sku,
            retailPrice: variant.price
          }
        });
      }

      console.log('Created product:', prodData.name, 'with', prodData.variants.length, 'variants');
    }

    console.log('\n✅ Sample data creation complete!');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

createSampleData();