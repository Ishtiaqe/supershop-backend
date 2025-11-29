import { PrismaClient } from '@prisma/client';
import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const prisma = new PrismaClient();

async function main() {
    const email = 'owner@shop1.com';
    const user = await prisma.user.findUnique({
        where: { email },
        include: { tenant: true }
    });

    if (user) {
        console.log(`User: ${user.email}`);
        console.log(`Tenant ID: ${user.tenantId}`);
        console.log(`Tenant Name: ${user.tenant?.name}`);
    } else {
        console.log('User not found');
    }
}

main()
    .catch(e => console.error(e))
    .finally(async () => await prisma.$disconnect());
