#!/usr/bin/env ts-node
import fs from 'fs';
import path from 'path';
import { PrismaClient } from '@prisma/client';

// This script exports all Prisma models to JSON files in a timestamped folder.
// Usage:
//   ts-node scripts/export-prisma.ts

const prisma = new PrismaClient();

function camelCase(s: string) {
  return s.charAt(0).toLowerCase() + s.slice(1);
}

async function main() {
  // Read prisma schema to find model names
  const schemaPath = path.resolve(__dirname, '..', 'prisma', 'schema.prisma');
  if (!fs.existsSync(schemaPath)) {
    console.error('prisma/schema.prisma not found at', schemaPath);
    process.exit(1);
  }

  const schema = fs.readFileSync(schemaPath, 'utf8');
  const modelNames = Array.from(schema.matchAll(/^model\s+(\w+)\s+{/gmi)).map(m => m[1]);
  if (modelNames.length === 0) {
    console.warn('No models found in prisma/schema.prisma');
    process.exit(0);
  }

  const ts = new Date().toISOString().replace(/[:.]/g, '-');
  const outDir = path.resolve(__dirname, '..', 'backups', 'prisma-json-' + ts);
  fs.mkdirSync(outDir, { recursive: true });

  for (const model of modelNames) {
    const clientKey = camelCase(model);
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore - dynamic access to client
    const modelClient = (prisma as any)[clientKey];
    if (!modelClient || typeof modelClient.findMany !== 'function') {
      console.warn(`Skipping ${model}: no Prisma client mapping found for ${clientKey}`);
      continue;
    }

    console.log(`Exporting model ${model} -> ${clientKey}`);
    try {
      const rows = await modelClient.findMany({});
      const filePath = path.join(outDir, `${model}.json`);
      fs.writeFileSync(filePath, JSON.stringify(rows, null, 2));
      console.log(`  Wrote ${filePath} (${rows.length} rows)`);
    } catch (err) {
      console.error(`  Failed to export ${model}:`, err);
    }
  }

  await prisma.$disconnect();
  console.log('Prisma JSON export completed:', outDir);
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});
