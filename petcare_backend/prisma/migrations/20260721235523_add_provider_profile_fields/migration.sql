/*
  Warnings:

  - A unique constraint covering the columns `[nationalId]` on the table `ServiceProvider` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- CreateEnum
CREATE TYPE "ProviderStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- AlterTable
ALTER TABLE "ServiceProvider" ADD COLUMN     "addressDetail" TEXT,
ADD COLUMN     "dateOfBirth" TIMESTAMP(3),
ADD COLUMN     "gender" "Gender",
ADD COLUMN     "idCardBackUrl" TEXT,
ADD COLUMN     "idCardFrontUrl" TEXT,
ADD COLUMN     "idIssuedDate" TIMESTAMP(3),
ADD COLUMN     "idIssuedPlace" TEXT,
ADD COLUMN     "legalName" TEXT,
ADD COLUMN     "nationalId" TEXT,
ADD COLUMN     "province" TEXT,
ADD COLUMN     "status" "ProviderStatus" NOT NULL DEFAULT 'PENDING',
ADD COLUMN     "submittedAt" TIMESTAMP(3);

-- CreateIndex
CREATE UNIQUE INDEX "ServiceProvider_nationalId_key" ON "ServiceProvider"("nationalId");
