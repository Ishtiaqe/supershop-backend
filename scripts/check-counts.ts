import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function checkCounts() {
  const counts = await Promise.all([
    prisma.medicine.count(),
    prisma.medicineGeneric.count(),
    prisma.medicineManufacturer.count(),
    prisma.medicineDrugClass.count(),
    prisma.medicineIndication.count(),
    prisma.medicineDosageForm.count(),
  ]);

  console.log('medicines:', counts[0]);
  console.log('medicine_generics:', counts[1]);
  console.log('medicine_manufacturers:', counts[2]);
  console.log('medicine_drug_classes:', counts[3]);
  console.log('medicine_indications:', counts[4]);
  console.log('medicine_dosage_forms:', counts[5]);

  await prisma.$disconnect();
}

checkCounts();