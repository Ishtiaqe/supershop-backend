import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function getUser() {
  const userId = process.argv[2];
  if (!userId) {
    console.log('Usage: npx ts-node get-user.ts <userId>');
    return;
  }

  try {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        password: true,
        fullName: true,
        role: true,
        tenantId: true
      }
    });

    if (!user) {
      console.log('User not found');
      return;
    }

    console.log('User details:');
    console.log(JSON.stringify(user, null, 2));

  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

getUser();