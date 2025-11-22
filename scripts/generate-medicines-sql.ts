import * as Database from 'better-sqlite3';
import * as fs from 'fs';
import * as path from 'path';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const sqliteDbPath = path.join(__dirname, '..', '..', 'original_medicine_db.sqlite3');
const outputSqlPath = path.join(__dirname, 'medicines-insert.sql');

const sqliteDb = new Database(sqliteDbPath);

async function generateSql() {
  console.log('Fetching id mappings...');

  const genericMap = new Map<number, string>();
  const manufacturerMap = new Map<number, string>();

  const generics = await prisma.medicineGeneric.findMany({ select: { genericId: true, id: true } });
  generics.forEach(g => genericMap.set(g.genericId!, g.id));

  const manufacturers = await prisma.medicineManufacturer.findMany({ select: { manufacturerId: true, id: true } });
  manufacturers.forEach(m => manufacturerMap.set(m.manufacturerId!, m.id));

  console.log('Generating SQL for medicines...');

  const medicines = sqliteDb.prepare('SELECT * FROM crawler_medicine').all() as any[];

  let sql = 'INSERT INTO "medicines" ("id", "brandId", "brandName", "type", "slug", "dosageForm", "strength", "packageContainer", "packSizeInfo", "createdAt", "updatedAt", "genericId", "manufacturerId") VALUES\n';

  const values = medicines.map((med, index) => {
    const id = `'${crypto.randomUUID()}'`; // generate uuid
    const brandId = med.brand_id;
    const brandName = `'${med.brand_name.replace(/'/g, "''")}'`;
    const type = `'${med.type.replace(/'/g, "''")}'`;
    const slug = med.slug ? `'${med.slug.replace(/'/g, "''")}'` : 'NULL';
    const dosageForm = med.dosage_form ? `'${med.dosage_form.replace(/'/g, "''")}'` : 'NULL';
    const strength = med.strength ? `'${med.strength.replace(/'/g, "''")}'` : 'NULL';
    const packageContainer = med.package_container ? `'${med.package_container.replace(/'/g, "''")}'` : 'NULL';
    const packSizeInfo = med.pack_size_info ? `'${med.pack_size_info.replace(/'/g, "''")}'` : 'NULL';
    const createdAt = 'NOW()';
    const updatedAt = 'NOW()';
    const genericId = med.generic_id && genericMap.has(med.generic_id) ? `'${genericMap.get(med.generic_id)}'` : 'NULL';
    const manufacturerId = med.manufacturer_id && manufacturerMap.has(med.manufacturer_id) ? `'${manufacturerMap.get(med.manufacturer_id)}'` : 'NULL';

    return `(${id}, ${brandId}, ${brandName}, ${type}, ${slug}, ${dosageForm}, ${strength}, ${packageContainer}, ${packSizeInfo}, ${createdAt}, ${updatedAt}, ${genericId}, ${manufacturerId})`;
  });

  sql += values.join(',\n') + ';';

  fs.writeFileSync(outputSqlPath, sql);

  console.log(`SQL file generated at ${outputSqlPath}`);

  await prisma.$disconnect();
  sqliteDb.close();
}

generateSql().catch(console.error);