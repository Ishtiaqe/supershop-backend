import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const prisma = new PrismaClient();

async function main() {
    const variantId = "ea96c45b-b58c-4fc5-8a79-aad666a28b55";

    const variant = await prisma.productVariant.findUnique({
        where: { id: variantId },
        include: { product: true }
    });

    if (variant) {
        console.log(`Current Product Name: "${variant.product.name}"`);
        if (variant.product.name === "Microporous Surgical Tape 1\" (UI Edit)") {
            console.log("✅ VERIFIED: Name updated successfully via UI.");
        } else {
            console.log("⚠️ MISMATCH: Name is not what was expected from UI edit.");
        }
    } else {
        console.log("❌ Variant not found.");
    }
}

main()
    .catch(e => console.error(e))
    .finally(async () => await prisma.$disconnect());
