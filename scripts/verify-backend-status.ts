import { PrismaClient } from '@prisma/client';
import * as jwt from 'jsonwebtoken';
import * as dotenv from 'dotenv';
import * as fs from 'fs';
import * as path from 'path';

// Load env from .env file
const envPath = path.resolve(__dirname, '../.env');
if (fs.existsSync(envPath)) {
    dotenv.config({ path: envPath });
}

const prisma = new PrismaClient();

async function main() {
    // 1. Find Owner
    const user = await prisma.user.findFirst({
        where: { role: 'OWNER' },
    });

    if (!user) {
        console.error('No OWNER user found');
        process.exit(1);
    }

    // 2. Generate Token
    const secret = process.env.JWT_SECRET;
    if (!secret) {
        console.error('JWT_SECRET not found in .env');
        process.exit(1);
    }

    const token = jwt.sign({ sub: user.id }, secret, { expiresIn: '15m' });

    // 3. Define Target and Payload
    const variantId = "ea96c45b-b58c-4fc5-8a79-aad666a28b55";
    const url = `http://localhost:8000/api/v1/catalog/${variantId}`;

    // Reverting name to original
    const newName = "Microporous Surgical Tape 1\"";

    const payload = {
        "productName": newName,
        "variantName": "Standard",
        "sku": "SKU-1764420873526",
        "retailPrice": 60,
        "description": null,
        "productType": "GENERAL"
    };

    console.log(`Sending PUT request to: ${url}`);

    try {
        const response = await fetch(url, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify(payload)
        });

        const data = await response.json();

        if (response.status === 200 && data.productName === newName) {
            console.log("✅ SUCCESS: Backend API is working and updated the name.");
        } else {
            console.log("❌ FAILED: Backend API returned status " + response.status);
        }

    } catch (error) {
        console.error('Fetch error:', error);
    }
}

main()
    .catch(e => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
