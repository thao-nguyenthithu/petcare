-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "AddressLabel" AS ENUM ('HOME', 'WORK', 'OTHER');

-- CreateEnum
CREATE TYPE "PetKind" AS ENUM ('DOG', 'CAT', 'BOTH');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('OWNER', 'PROVIDER', 'ADMIN');

-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- CreateEnum
CREATE TYPE "SitterStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ServiceType" AS ENUM ('WALKING', 'BOARDING', 'GROOMING');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'AWAITING_OWNER_APPROVAL', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'DISPUTED', 'RESOLVED');

-- CreateEnum
CREATE TYPE "PhotoPhase" AS ENUM ('CHECK_IN', 'IN_PROGRESS', 'CHECK_OUT');

-- CreateEnum
CREATE TYPE "ReportStatus" AS ENUM ('OPEN', 'REVIEWING', 'RESOLVED');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "passwordHash" TEXT,
    "firebaseUid" TEXT,
    "role" "UserRole" NOT NULL DEFAULT 'OWNER',
    "avatarUrl" TEXT,
    "isVerified" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Address" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "label" "AddressLabel" NOT NULL DEFAULT 'HOME',
    "customLabel" TEXT,
    "province" TEXT NOT NULL,
    "ward" TEXT NOT NULL,
    "street" TEXT NOT NULL,
    "note" TEXT,
    "lat" DOUBLE PRECISION NOT NULL,
    "lng" DOUBLE PRECISION NOT NULL,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Address_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Sitter" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "bio" TEXT,
    "ratingAvg" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "totalReviews" INTEGER NOT NULL DEFAULT 0,
    "backgroundChecked" BOOLEAN NOT NULL DEFAULT false,
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "SitterStatus" NOT NULL DEFAULT 'PENDING',
    "legalName" TEXT,
    "gender" "Gender",
    "dateOfBirth" TIMESTAMP(3),
    "nationalId" TEXT,
    "idIssuedPlace" TEXT,
    "idIssuedDate" TIMESTAMP(3),
    "province" TEXT,
    "addressDetail" TEXT,
    "cccdFrontPath" TEXT,
    "cccdBackPath" TEXT,
    "submittedAt" TIMESTAMP(3),
    "serviceAddress" TEXT,
    "serviceAddressNote" TEXT,
    "serviceRadiusKm" INTEGER,

    CONSTRAINT "Sitter_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterPhoto" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SitterPhoto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterDayOff" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "date" DATE NOT NULL,

    CONSTRAINT "SitterDayOff_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterService" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "type" "ServiceType" NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "petKind" "PetKind" NOT NULL DEFAULT 'BOTH',
    "pricing" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SitterService_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Pet" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "species" TEXT NOT NULL,
    "breed" TEXT,
    "ageMonths" INTEGER,
    "weight" DOUBLE PRECISION,
    "notes" TEXT,
    "avatarUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Pet_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Service" (
    "id" TEXT NOT NULL,
    "type" "ServiceType" NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "basePricePerHour" DOUBLE PRECISION NOT NULL,
    "durationMinutes" INTEGER,

    CONSTRAINT "Service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Booking" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "serviceId" TEXT NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'PENDING',
    "scheduledAt" TIMESTAMP(3) NOT NULL,
    "startedAt" TIMESTAMP(3),
    "endedAt" TIMESTAMP(3),
    "totalPrice" DOUBLE PRECISION,
    "specialNotes" TEXT,
    "cancellationFee" DOUBLE PRECISION,
    "cancelledBy" TEXT,
    "cancellationReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Booking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingPet" (
    "bookingId" TEXT NOT NULL,
    "petId" TEXT NOT NULL,

    CONSTRAINT "BookingPet_pkey" PRIMARY KEY ("bookingId","petId")
);

-- CreateTable
CREATE TABLE "SessionPhoto" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "photoUrl" TEXT NOT NULL,
    "phase" "PhotoPhase" NOT NULL,
    "photoLat" DOUBLE PRECISION,
    "photoLng" DOUBLE PRECISION,
    "aiRawResponse" JSONB,
    "aiProvider" TEXT,
    "aiConfidenceScore" DOUBLE PRECISION,
    "aiPassed" BOOLEAN,
    "aiFailCount" INTEGER,
    "ownerOverrideAt" TIMESTAMP(3),
    "ownerOverrideNote" TEXT,
    "ownerRejectedAt" TIMESTAMP(3),
    "overrideTimeoutAt" TIMESTAMP(3),
    "takenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SessionPhoto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LocationTrack" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "clientTs" TIMESTAMP(3) NOT NULL,
    "serverTs" TIMESTAMP(3) NOT NULL,
    "driftMs" INTEGER,
    "batchSeq" INTEGER,
    "isNoise" BOOLEAN NOT NULL DEFAULT false,
    "recordedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LocationTrack_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingGpsReport" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "totalWaypoints" INTEGER NOT NULL,
    "totalDistanceM" DOUBLE PRECISION NOT NULL,
    "durationMinutes" INTEGER NOT NULL,
    "avgSpeedKmh" DOUBLE PRECISION NOT NULL,
    "suspicionScore" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "flaggedForReview" BOOLEAN NOT NULL DEFAULT false,
    "suspicionNote" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BookingGpsReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Review" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "reviewerId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Review_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ViolationReport" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "reporterId" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "evidenceUrls" JSONB,
    "status" "ReportStatus" NOT NULL DEFAULT 'OPEN',
    "adminNote" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ViolationReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Message" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Message_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_phone_key" ON "User"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "User_firebaseUid_key" ON "User"("firebaseUid");

-- CreateIndex
CREATE INDEX "Address_userId_idx" ON "Address"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Sitter_userId_key" ON "Sitter"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Sitter_nationalId_key" ON "Sitter"("nationalId");

-- CreateIndex
CREATE INDEX "SitterPhoto_sitterId_idx" ON "SitterPhoto"("sitterId");

-- CreateIndex
CREATE INDEX "SitterDayOff_sitterId_idx" ON "SitterDayOff"("sitterId");

-- CreateIndex
CREATE UNIQUE INDEX "SitterDayOff_sitterId_date_key" ON "SitterDayOff"("sitterId", "date");

-- CreateIndex
CREATE INDEX "SitterService_sitterId_idx" ON "SitterService"("sitterId");

-- CreateIndex
CREATE UNIQUE INDEX "SitterService_sitterId_type_key" ON "SitterService"("sitterId", "type");

-- CreateIndex
CREATE INDEX "BookingPet_petId_idx" ON "BookingPet"("petId");

-- CreateIndex
CREATE INDEX "LocationTrack_bookingId_clientTs_idx" ON "LocationTrack"("bookingId", "clientTs");

-- CreateIndex
CREATE INDEX "LocationTrack_bookingId_serverTs_idx" ON "LocationTrack"("bookingId", "serverTs");

-- CreateIndex
CREATE INDEX "LocationTrack_bookingId_isNoise_idx" ON "LocationTrack"("bookingId", "isNoise");

-- CreateIndex
CREATE UNIQUE INDEX "BookingGpsReport_bookingId_key" ON "BookingGpsReport"("bookingId");

-- CreateIndex
CREATE INDEX "BookingGpsReport_flaggedForReview_idx" ON "BookingGpsReport"("flaggedForReview");

-- CreateIndex
CREATE INDEX "BookingGpsReport_suspicionScore_idx" ON "BookingGpsReport"("suspicionScore");

-- CreateIndex
CREATE UNIQUE INDEX "Review_bookingId_key" ON "Review"("bookingId");

-- CreateIndex
CREATE INDEX "Message_bookingId_createdAt_idx" ON "Message"("bookingId", "createdAt");

-- AddForeignKey
ALTER TABLE "Address" ADD CONSTRAINT "Address_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Sitter" ADD CONSTRAINT "Sitter_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterPhoto" ADD CONSTRAINT "SitterPhoto_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterDayOff" ADD CONSTRAINT "SitterDayOff_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterService" ADD CONSTRAINT "SitterService_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Pet" ADD CONSTRAINT "Pet_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingPet" ADD CONSTRAINT "BookingPet_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingPet" ADD CONSTRAINT "BookingPet_petId_fkey" FOREIGN KEY ("petId") REFERENCES "Pet"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SessionPhoto" ADD CONSTRAINT "SessionPhoto_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LocationTrack" ADD CONSTRAINT "LocationTrack_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingGpsReport" ADD CONSTRAINT "BookingGpsReport_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Review" ADD CONSTRAINT "Review_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Review" ADD CONSTRAINT "Review_reviewerId_fkey" FOREIGN KEY ("reviewerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ViolationReport" ADD CONSTRAINT "ViolationReport_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ViolationReport" ADD CONSTRAINT "ViolationReport_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE INDEX IF NOT EXISTS "idx_sitter_location" ON "Sitter" USING GIST (ST_SetSRID(ST_MakePoint(lng, lat), 4326));
CREATE INDEX IF NOT EXISTS "idx_address_location" ON "Address" USING GIST (ST_SetSRID(ST_MakePoint(lng, lat), 4326));
