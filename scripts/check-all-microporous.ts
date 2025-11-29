import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const prisma = new PrismaClient();

async function main() {
    const variants = await prisma.productVariant.findMany({
        where: {
            product: {
                name: { contains: 'Microporous' }
            }
        },
        include: { product: true }
    });

    console.log(`Found ${variants.length} variants matching 'Microporous':`);
    variants.forEach(v => {
        console.log(`- ID: ${v.id}`);
        console.log(`  Name: "${v.product.name}"`);
        console.log(`  Variant: "${v.variantName}"`);
        console.log(`  Tenant: ${v.tenantId}`);
        console.log('---');
    });
}

main()
    .catch(e => console.error(e))
    .finally(async () => await prisma.$disconnect());
