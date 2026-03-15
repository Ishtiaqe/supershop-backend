import { PrismaClient } from '@prisma/client';

declare global {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  var __global_prisma__: PrismaClient | undefined;
}

const prisma = global.__global_prisma__ || new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  global.__global_prisma__ = prisma;
}

export default prisma;
