const Database = require('better-sqlite3');
import { PrismaClient } from '@prisma/client';

const sqliteDb = new Database('/mnt/storage/Projects/supershop/original_medicine_db.sqlite3');
const prisma = new PrismaClient();

async function importData() {
  console.log('Starting import...');

  // Truncate tables first
  console.log('Truncating tables...');
  await prisma.medicineDosageForm.deleteMany();
  await prisma.medicineDrugClass.deleteMany();
  await prisma.medicineIndication.deleteMany();
  await prisma.medicineManufacturer.deleteMany();
  await prisma.medicineGeneric.deleteMany();
  await prisma.medicine.deleteMany();

  // Create maps for foreign keys
  console.log('Creating id maps...');
  const dosageFormMap = new Map<number, string>();
  const drugClassMap = new Map<number, string>();
  const indicationMap = new Map<number, string>();
  const manufacturerMap = new Map<number, string>();
  const genericMap = new Map<number, string>();

  const dosageForms = sqliteDb.prepare('SELECT * FROM crawler_dosageform').all() as any[];
  for (const df of dosageForms) {
    const created = await prisma.medicineDosageForm.create({
      data: {
        dosageFormId: df.dosage_form_id,
        dosageFormName: df.dosage_form_name,
        slug: df.slug,
        brandNamesCount: df.brand_names_count,
      },
    });
    dosageFormMap.set(df.dosage_form_id, created.id);
  }

  const drugClasses = sqliteDb.prepare('SELECT * FROM crawler_drugclass').all() as any[];
  for (const dc of drugClasses) {
    const created = await prisma.medicineDrugClass.create({
      data: {
        drugClassId: dc.drug_class_id,
        drugClassName: dc.drug_class_name,
        slug: dc.slug,
        genericsCount: dc.generics_count,
      },
    });
    drugClassMap.set(dc.drug_class_id, created.id);
  }

  const indications = sqliteDb.prepare('SELECT * FROM crawler_indication').all() as any[];
  for (const ind of indications) {
    const created = await prisma.medicineIndication.create({
      data: {
        indicationId: ind.indication_id,
        indicationName: ind.indication_name,
        slug: ind.slug,
        genericsCount: ind.generics_count,
      },
    });
    indicationMap.set(ind.indication_id, created.id);
  }

  const manufacturers = sqliteDb.prepare('SELECT * FROM crawler_manufacturer').all() as any[];
  for (const mf of manufacturers) {
    const created = await prisma.medicineManufacturer.create({
      data: {
        manufacturerId: mf.manufacturer_id,
        manufacturerName: mf.manufacturer_name,
        slug: mf.slug,
        genericsCount: mf.generics_count,
        brandNamesCount: mf.brand_names_count,
      },
    });
    manufacturerMap.set(mf.manufacturer_id, created.id);
  }

  // Import MedicineGeneric
  console.log('Importing generics...');
  const generics = sqliteDb.prepare('SELECT * FROM crawler_generic').all() as any[];
  await prisma.medicineGeneric.createMany({
    data: generics.map(gen => ({
      genericId: gen.generic_id,
      genericName: gen.generic_name,
      slug: gen.slug,
      monographLink: gen.monograph_link,
      indicationDescription: gen.indication_description,
      therapeuticClassDescription: gen.therapeutic_class_description,
      pharmacologyDescription: gen.pharmacology_description,
      dosageDescription: gen.dosage_description,
      administrationDescription: gen.administration_description,
      interactionDescription: gen.interaction_description,
      contraindicationsDescription: gen.contraindications_description,
      sideEffectsDescription: gen.side_effects_description,
      pregnancyAndLactationDescription: gen.pregnancy_and_lactation_description,
      precautionsDescription: gen.precautions_description,
      pediatricUsageDescription: gen.pediatric_usage_description,
      overdoseEffectsDescription: gen.overdose_effects_description,
      durationOfTreatmentDescription: gen.duration_of_treatment_description,
      reconstitutionDescription: gen.reconstitution_description,
      storageConditionsDescription: gen.storage_conditions_description,
      descriptionsCount: gen.descriptions_count,
      drugClassId: gen.drug_class_id ? drugClassMap.get(gen.drug_class_id) : null,
      indicationId: gen.indication_id ? indicationMap.get(gen.indication_id) : null,
    })),
    skipDuplicates: true,
  });

  // Create generic map
  for (const gen of generics) {
    const created = await prisma.medicineGeneric.findUnique({
      where: { genericId: gen.generic_id },
    });
    if (created) genericMap.set(gen.generic_id, created.id);
  }

  // Import Medicine
  console.log('Importing medicines...');
  const medicines = sqliteDb.prepare('SELECT * FROM crawler_medicine').all() as any[];
  const batchSize = 1000;
  for (let i = 0; i < medicines.length; i += batchSize) {
    const batch = medicines.slice(i, i + batchSize);
    const medicineData = batch.map(med => ({
      brandId: med.brand_id,
      brandName: med.brand_name,
      type: med.type,
      slug: med.slug,
      dosageForm: med.dosage_form,
      strength: med.strength,
      packageContainer: med.package_container,
      packSizeInfo: med.pack_size_info,
      genericId: med.generic_id ? genericMap.get(med.generic_id) : null,
      manufacturerId: med.manufacturer_id ? manufacturerMap.get(med.manufacturer_id) : null,
    }));

    await prisma.medicine.createMany({
      data: medicineData,
      skipDuplicates: true,
    });
    console.log(`Inserted batch ${Math.floor(i / batchSize) + 1} of ${Math.ceil(medicines.length / batchSize)}`);
  }

  console.log('Import completed!');
}

importData()
  .catch(console.error)
  .finally(() => {
    sqliteDb.close();
    prisma.$disconnect();
  });