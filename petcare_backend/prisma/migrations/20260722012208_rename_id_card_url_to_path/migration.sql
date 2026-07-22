/*
  Warnings:

  - You are about to drop the column `idCardBackUrl` on the `ServiceProvider` table. All the data in the column will be lost.
  - You are about to drop the column `idCardFrontUrl` on the `ServiceProvider` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "ServiceProvider" DROP COLUMN "idCardBackUrl",
DROP COLUMN "idCardFrontUrl",
ADD COLUMN     "idCardBackPath" TEXT,
ADD COLUMN     "idCardFrontPath" TEXT;
