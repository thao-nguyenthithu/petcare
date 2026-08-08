CREATE EXTENSION IF NOT EXISTS postgis;

-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "AddressLabel" AS ENUM ('HOME', 'WORK', 'OTHER');

-- CreateEnum
CREATE TYPE "PenaltyKind" AS ENUM ('CANCEL_RATE', 'WARNING', 'HIDE');

-- CreateEnum
CREATE TYPE "PenaltyStatus" AS ENUM ('ACTIVE', 'PENDING_REVIEW', 'WAIVED');

-- CreateEnum
CREATE TYPE "SitterDayMode" AS ENUM ('DEFAULT', 'CUSTOM_HOURS', 'OFF');

-- CreateEnum
CREATE TYPE "PetSpecies" AS ENUM ('DOG', 'CAT');

-- CreateEnum
CREATE TYPE "PetGender" AS ENUM ('MALE', 'FEMALE');

-- CreateEnum
CREATE TYPE "PreventionForm" AS ENUM ('VACCINE', 'ORAL', 'SPOT_ON', 'OTHER');

-- CreateEnum
CREATE TYPE "CycleUnit" AS ENUM ('DAY', 'WEEK', 'MONTH');

-- CreateEnum
CREATE TYPE "PetKind" AS ENUM ('DOG', 'CAT', 'BOTH');

-- CreateEnum
CREATE TYPE "WalletTxKind" AS ENUM ('TIEN_VAO', 'RUT_RA', 'DIEU_CHINH');

-- CreateEnum
CREATE TYPE "WithdrawalStatus" AS ENUM ('PENDING', 'SENT', 'DONE', 'REJECTED');

-- CreateEnum
CREATE TYPE "MessageKind" AS ENUM ('TEXT', 'IMAGE', 'LOCATION', 'SYSTEM');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('OWNER', 'PROVIDER', 'ADMIN');

-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- CreateEnum
CREATE TYPE "SitterStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ServiceType" AS ENUM ('WALKING', 'BOARDING', 'GROOMING');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('AWAITING_PAYMENT', 'PENDING', 'CONFIRMED', 'IN_PROGRESS', 'AWAITING_OWNER_CONFIRM', 'COMPLETED', 'CANCELLED_BY_OWNER', 'CANCELLED_BY_SITTER', 'CANCELLED_EXPIRED', 'CANCELLED_UNPAID', 'CANCELLED_NO_SHOW', 'CANCELLED_BY_ADMIN', 'DISPUTED', 'RESOLVED');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PENDING', 'HELD', 'FAILED', 'EXPIRED', 'RELEASED', 'REFUNDING', 'REFUNDED');

-- CreateEnum
CREATE TYPE "PhotoPhase" AS ENUM ('CHECK_IN', 'IN_PROGRESS', 'CHECK_OUT');

-- CreateEnum
CREATE TYPE "ReportStatus" AS ENUM ('OPEN', 'REVIEWING', 'RESOLVED');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('DON_HANG', 'DON_HUY', 'DON_MOI', 'BANG_CHUNG', 'NHAC_LICH', 'HO_SO', 'DANH_GIA', 'TIN_NHAN', 'NOI_DUNG', 'TIEN_VI', 'PHONG_BENH', 'KHIEU_NAI');

-- CreateEnum
CREATE TYPE "NotificationRole" AS ENUM ('CHU_NUOI', 'NGUOI_CHAM');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "passwordHash" TEXT,
    "dateOfBirth" DATE,
    "firebaseUid" TEXT,
    "passwordChangedAt" TIMESTAMPTZ(3),
    "role" "UserRole" NOT NULL DEFAULT 'OWNER',
    "avatarUrl" TEXT,
    "isVerified" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SearchHistory" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "keyword" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SearchHistory_pkey" PRIMARY KEY ("id")
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
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Address_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Sitter" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "bio" TEXT,
    "ratingAvg" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "totalReviews" INTEGER NOT NULL DEFAULT 0,
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "SitterStatus" NOT NULL DEFAULT 'PENDING',
    "legalName" TEXT,
    "gender" "Gender",
    "dateOfBirth" DATE,
    "nationalId" TEXT,
    "idIssuedPlace" TEXT,
    "idIssuedDate" DATE,
    "province" TEXT,
    "addressDetail" TEXT,
    "cccdFrontPath" TEXT,
    "cccdBackPath" TEXT,
    "submittedAt" TIMESTAMPTZ(3),
    "serviceAddress" TEXT,
    "serviceAddressNote" TEXT,
    "serviceRadiusKm" INTEGER,
    "onboardedAt" TIMESTAMPTZ(3),
    "workStart" TEXT NOT NULL DEFAULT '07:00',
    "workEnd" TEXT NOT NULL DEFAULT '20:00',
    "workDays" INTEGER[] DEFAULT ARRAY[1, 2, 3, 4, 5, 6]::INTEGER[],
    "hiddenUntil" TIMESTAMPTZ(3),
    "hiddenCount" INTEGER NOT NULL DEFAULT 0,
    "bannedAt" TIMESTAMPTZ(3),
    "lastHiddenAt" TIMESTAMPTZ(3),
    "staticScore" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "trustedBadge" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Sitter_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterPenalty" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "bookingId" TEXT,
    "kind" "PenaltyKind" NOT NULL,
    "status" "PenaltyStatus" NOT NULL DEFAULT 'ACTIVE',
    "reason" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewedAt" TIMESTAMPTZ(3),

    CONSTRAINT "SitterPenalty_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BoardingUpdate" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "message" TEXT,
    "conditions" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "photoUrls" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BoardingUpdate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterPhoto" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SitterPhoto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterDaySetting" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "mode" "SitterDayMode" NOT NULL DEFAULT 'DEFAULT',
    "startTime" TEXT,
    "endTime" TEXT,
    "boardingSlots" INTEGER,
    "reason" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "SitterDaySetting_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SitterService" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "type" "ServiceType" NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT false,
    "petKind" "PetKind" NOT NULL DEFAULT 'BOTH',
    "pricing" JSONB NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "SitterService_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Pet" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "species" "PetSpecies" NOT NULL,
    "breed" TEXT NOT NULL,
    "gender" "PetGender" NOT NULL,
    "birthDate" DATE,
    "weightKg" DOUBLE PRECISION NOT NULL,
    "isNeutered" BOOLEAN NOT NULL DEFAULT false,
    "underTreatment" BOOLEAN NOT NULL DEFAULT false,
    "chronicDisease" TEXT,
    "medication" TEXT,
    "careNote" TEXT,
    "avatarUrl" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Pet_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PetPhoto" (
    "id" TEXT NOT NULL,
    "petId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PetPhoto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PreventionRecord" (
    "id" TEXT NOT NULL,
    "petId" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "customName" TEXT,
    "form" "PreventionForm" NOT NULL,
    "isPeriodic" BOOLEAN NOT NULL DEFAULT false,
    "suggestedCycleValue" INTEGER,
    "suggestedCycleUnit" "CycleUnit",
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "PreventionRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PreventionDose" (
    "id" TEXT NOT NULL,
    "recordId" TEXT NOT NULL,
    "doneAt" DATE NOT NULL,
    "cycleValue" INTEGER,
    "cycleUnit" "CycleUnit",
    "place" TEXT,
    "nextDueAt" DATE,
    "remindedDays" INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PreventionDose_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PreventionDosePhoto" (
    "id" TEXT NOT NULL,
    "doseId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PreventionDosePhoto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Service" (
    "id" TEXT NOT NULL,
    "type" "ServiceType" NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "basePricePerHour" INTEGER NOT NULL,
    "durationMinutes" INTEGER,

    CONSTRAINT "Service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Booking" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "serviceId" TEXT NOT NULL,
    "status" "BookingStatus" NOT NULL DEFAULT 'PENDING',
    "scheduledAt" TIMESTAMPTZ(3) NOT NULL,
    "scheduledEndAt" TIMESTAMPTZ(3),
    "acceptedAt" TIMESTAMPTZ(3),
    "paidAt" TIMESTAMPTZ(3),
    "departedAt" TIMESTAMPTZ(3),
    "ownerDepartedAt" TIMESTAMPTZ(3),
    "ownerReturnDepartedAt" TIMESTAMPTZ(3),
    "arriveRemindedAt" TIMESTAMPTZ(3),
    "arrivedAt" TIMESTAMPTZ(3),
    "startedAt" TIMESTAMPTZ(3),
    "endedAt" TIMESTAMPTZ(3),
    "completedAt" TIMESTAMPTZ(3),
    "totalPrice" INTEGER,
    "specialNotes" TEXT,
    "cancellationFee" INTEGER,
    "cancelledAt" TIMESTAMPTZ(3),
    "cancellationReason" TEXT,
    "cancellationNote" TEXT,
    "sitterPayout" INTEGER,
    "lateMinutes" INTEGER,
    "etaAt" TIMESTAMPTZ(3),
    "lateReportedAt" TIMESTAMPTZ(3),
    "gearReportedAt" TIMESTAMPTZ(3),
    "ownerArrivedAt" TIMESTAMPTZ(3),
    "arriveDistanceM" INTEGER,
    "noShowProofUrls" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "sitterNote" TEXT,
    "handoverNote" TEXT,
    "distanceKm" DOUBLE PRECISION,
    "pickupDistanceKm" DOUBLE PRECISION,
    "durationMinutes" INTEGER,
    "platformFee" INTEGER,
    "platformFeePercent" INTEGER,
    "cancelFeePercent" INTEGER,
    "escrowReleaseAt" TIMESTAMPTZ(3),
    "priceBreakdown" JSONB,
    "gearCommittedAt" TIMESTAMPTZ(3),
    "addressId" TEXT,
    "addressText" TEXT,
    "addressLat" DOUBLE PRECISION,
    "addressLng" DOUBLE PRECISION,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Booking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingPet" (
    "bookingId" TEXT NOT NULL,
    "petId" TEXT NOT NULL,
    "packageCode" TEXT,
    "durationMinutes" INTEGER,
    "price" INTEGER,

    CONSTRAINT "BookingPet_pkey" PRIMARY KEY ("bookingId","petId")
);

-- CreateTable
CREATE TABLE "SystemSetting" (
    "key" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "updatedBy" TEXT,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "SystemSetting_pkey" PRIMARY KEY ("key")
);

-- CreateTable
CREATE TABLE "Payment" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "txnRef" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "status" "PaymentStatus" NOT NULL DEFAULT 'PENDING',
    "gateway" TEXT NOT NULL,
    "gatewayTxnNo" TEXT,
    "gatewayPayDate" TEXT,
    "bankCode" TEXT,
    "cardType" TEXT,
    "responseCode" TEXT,
    "paidAt" TIMESTAMPTZ(3),
    "releasedAt" TIMESTAMPTZ(3),
    "expiresAt" TIMESTAMPTZ(3) NOT NULL,
    "rawReturn" JSONB,
    "refundReference" TEXT,
    "refundNote" TEXT,
    "refundedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CheckinScanBatch" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "trangThai" TEXT NOT NULL DEFAULT 'PROCESSING',
    "anhCaDanUrl" TEXT,
    "taoLuc" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "xongLuc" TIMESTAMPTZ(3),

    CONSTRAINT "CheckinScanBatch_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PetSafetyScan" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "batchId" TEXT NOT NULL,
    "slotIndex" INTEGER NOT NULL,
    "soLan" INTEGER NOT NULL,
    "photoUrl" TEXT NOT NULL,
    "canhDaiPx" INTEGER,
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "chupLuc" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "trangThai" TEXT,
    "code" TEXT,
    "confidence" DOUBLE PRECISION,
    "provider" TEXT NOT NULL,
    "tinhLuot" BOOLEAN NOT NULL DEFAULT false,
    "rawResponse" JSONB,
    "ketLuanLuc" TIMESTAMPTZ(3),

    CONSTRAINT "PetSafetyScan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CheckinSlotXacNhan" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "slotIndex" INTEGER NOT NULL,
    "boiUserId" TEXT NOT NULL,
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "luc" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CheckinSlotXacNhan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SessionPhoto" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "photoUrl" TEXT NOT NULL,
    "phase" "PhotoPhase" NOT NULL,
    "slotIndex" INTEGER,
    "anhVanXa" BOOLEAN NOT NULL DEFAULT false,
    "anhDoDung" BOOLEAN NOT NULL DEFAULT false,
    "photoLat" DOUBLE PRECISION,
    "photoLng" DOUBLE PRECISION,
    "aiProvider" TEXT,
    "aiConfidenceScore" DOUBLE PRECISION,
    "aiPassed" BOOLEAN,
    "takenAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SessionPhoto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LocationTrack" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "clientTs" TIMESTAMPTZ(3) NOT NULL,
    "serverTs" TIMESTAMPTZ(3) NOT NULL,
    "driftMs" INTEGER,
    "batchSeq" INTEGER,
    "isNoise" BOOLEAN NOT NULL DEFAULT false,
    "isMocked" BOOLEAN NOT NULL DEFAULT false,

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
    "suspicionScore" DOUBLE PRECISION,
    "flaggedForReview" BOOLEAN NOT NULL DEFAULT false,
    "suspicionNote" TEXT,
    "mockedCount" INTEGER NOT NULL DEFAULT 0,
    "speedFlag" BOOLEAN NOT NULL DEFAULT false,
    "reviewedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BookingGpsReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Review" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "reviewerId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "photos" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "praiseTags" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "reply" TEXT,
    "replyAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Review_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ViolationReport" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "reporterId" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "reasonCode" TEXT,
    "evidenceUrls" JSONB,
    "status" "ReportStatus" NOT NULL DEFAULT 'OPEN',
    "sitterReply" TEXT,
    "sitterReplyAt" TIMESTAMPTZ(3),
    "sitterReplyPhotos" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "replyDeadline" TIMESTAMPTZ(3),
    "resolution" TEXT,
    "resolutionReason" TEXT,
    "refundAmount" INTEGER,
    "resolvedAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ViolationReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Wallet" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "balance" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Wallet_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WalletTransaction" (
    "id" TEXT NOT NULL,
    "walletId" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "kind" "WalletTxKind" NOT NULL,
    "title" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "balanceAfter" INTEGER NOT NULL,
    "bookingId" TEXT,
    "withdrawalId" TEXT,
    "disputeCode" TEXT,
    "reference" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WalletTransaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BankAccount" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "bankName" TEXT NOT NULL,
    "accountNumber" TEXT NOT NULL,
    "accountHolder" TEXT NOT NULL,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "BankAccount_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Withdrawal" (
    "id" TEXT NOT NULL,
    "sitterId" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "fee" INTEGER NOT NULL DEFAULT 0,
    "status" "WithdrawalStatus" NOT NULL DEFAULT 'PENDING',
    "bankName" TEXT NOT NULL,
    "accountNumber" TEXT NOT NULL,
    "accountHolder" TEXT NOT NULL,
    "reference" TEXT,
    "rejectReason" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" TIMESTAMPTZ(3),
    "doneAt" TIMESTAMPTZ(3),

    CONSTRAINT "Withdrawal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Conversation" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "lastMessage" TEXT NOT NULL DEFAULT '',
    "lastMessageAt" TIMESTAMPTZ(3),
    "unreadOwner" INTEGER NOT NULL DEFAULT 0,
    "unreadSitter" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "Conversation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Message" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "conversationId" TEXT NOT NULL,
    "senderId" TEXT,
    "role" TEXT NOT NULL,
    "kind" "MessageKind" NOT NULL DEFAULT 'TEXT',
    "text" TEXT NOT NULL,
    "textSitter" TEXT,
    "actionLabel" TEXT,
    "actionLabelSitter" TEXT,
    "canGap" BOOLEAN NOT NULL DEFAULT false,
    "masked" BOOLEAN NOT NULL DEFAULT false,
    "images" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "soAnhThem" INTEGER,
    "caption" TEXT,
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Message_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "NotificationType" NOT NULL,
    "role" "NotificationRole" NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "urgent" BOOLEAN NOT NULL DEFAULT false,
    "targetId" TEXT,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "campaignId" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DeviceToken" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "DeviceToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "NotificationCampaign" (
    "id" TEXT NOT NULL,
    "adminId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "role" "NotificationRole" NOT NULL,
    "audienceKind" TEXT NOT NULL,
    "audienceValue" TEXT,
    "urgent" BOOLEAN NOT NULL DEFAULT false,
    "recipientCount" INTEGER NOT NULL DEFAULT 0,
    "sentAt" TIMESTAMPTZ(3),
    "scheduledAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "NotificationCampaign_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AdminAuditLog" (
    "id" TEXT NOT NULL,
    "adminId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "targetType" TEXT NOT NULL,
    "targetId" TEXT,
    "targetCode" TEXT,
    "reason" TEXT,
    "oldValue" TEXT,
    "newValue" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AdminAuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_phone_key" ON "User"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "User_firebaseUid_key" ON "User"("firebaseUid");

-- CreateIndex
CREATE INDEX "User_role_createdAt_idx" ON "User"("role", "createdAt");

-- CreateIndex
CREATE INDEX "User_createdAt_idx" ON "User"("createdAt");

-- CreateIndex
CREATE INDEX "SearchHistory_userId_createdAt_idx" ON "SearchHistory"("userId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "SearchHistory_userId_keyword_key" ON "SearchHistory"("userId", "keyword");

-- CreateIndex
CREATE INDEX "Address_userId_idx" ON "Address"("userId");

-- CreateIndex
CREATE INDEX "Address_isDefault_province_idx" ON "Address"("isDefault", "province");

-- CreateIndex
CREATE UNIQUE INDEX "Sitter_userId_key" ON "Sitter"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Sitter_nationalId_key" ON "Sitter"("nationalId");

-- CreateIndex
CREATE INDEX "Sitter_staticScore_idx" ON "Sitter"("staticScore");

-- CreateIndex
CREATE INDEX "Sitter_status_createdAt_idx" ON "Sitter"("status", "createdAt");

-- CreateIndex
CREATE INDEX "Sitter_hiddenUntil_idx" ON "Sitter"("hiddenUntil");

-- CreateIndex
CREATE INDEX "Sitter_bannedAt_idx" ON "Sitter"("bannedAt");

-- CreateIndex
CREATE INDEX "SitterPenalty_sitterId_createdAt_idx" ON "SitterPenalty"("sitterId", "createdAt");

-- CreateIndex
CREATE INDEX "SitterPenalty_sitterId_kind_status_idx" ON "SitterPenalty"("sitterId", "kind", "status");

-- CreateIndex
CREATE INDEX "SitterPenalty_status_createdAt_idx" ON "SitterPenalty"("status", "createdAt");

-- CreateIndex
CREATE INDEX "BoardingUpdate_bookingId_createdAt_idx" ON "BoardingUpdate"("bookingId", "createdAt");

-- CreateIndex
CREATE INDEX "SitterPhoto_sitterId_idx" ON "SitterPhoto"("sitterId");

-- CreateIndex
CREATE UNIQUE INDEX "SitterDaySetting_sitterId_date_key" ON "SitterDaySetting"("sitterId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "SitterService_sitterId_type_key" ON "SitterService"("sitterId", "type");

-- CreateIndex
CREATE INDEX "Pet_ownerId_idx" ON "Pet"("ownerId");

-- CreateIndex
CREATE INDEX "PetPhoto_petId_idx" ON "PetPhoto"("petId");

-- CreateIndex
CREATE INDEX "PreventionRecord_petId_idx" ON "PreventionRecord"("petId");

-- CreateIndex
CREATE INDEX "PreventionDose_recordId_idx" ON "PreventionDose"("recordId");

-- CreateIndex
CREATE INDEX "PreventionDose_nextDueAt_idx" ON "PreventionDose"("nextDueAt");

-- CreateIndex
CREATE INDEX "PreventionDosePhoto_doseId_idx" ON "PreventionDosePhoto"("doseId");

-- CreateIndex
CREATE UNIQUE INDEX "Service_type_key" ON "Service"("type");

-- CreateIndex
CREATE UNIQUE INDEX "Booking_code_key" ON "Booking"("code");

-- CreateIndex
CREATE INDEX "Booking_sitterId_scheduledAt_idx" ON "Booking"("sitterId", "scheduledAt");

-- CreateIndex
CREATE INDEX "Booking_ownerId_scheduledAt_idx" ON "Booking"("ownerId", "scheduledAt");

-- CreateIndex
CREATE INDEX "Booking_ownerId_createdAt_idx" ON "Booking"("ownerId", "createdAt");

-- CreateIndex
CREATE INDEX "Booking_status_createdAt_idx" ON "Booking"("status", "createdAt");

-- CreateIndex
CREATE INDEX "Booking_scheduledAt_idx" ON "Booking"("scheduledAt");

-- CreateIndex
CREATE INDEX "Booking_createdAt_idx" ON "Booking"("createdAt");

-- CreateIndex
CREATE INDEX "BookingPet_petId_idx" ON "BookingPet"("petId");

-- CreateIndex
CREATE UNIQUE INDEX "Payment_txnRef_key" ON "Payment"("txnRef");

-- CreateIndex
CREATE INDEX "Payment_bookingId_createdAt_idx" ON "Payment"("bookingId", "createdAt");

-- CreateIndex
CREATE INDEX "Payment_status_idx" ON "Payment"("status");

-- CreateIndex
CREATE INDEX "CheckinScanBatch_bookingId_idx" ON "CheckinScanBatch"("bookingId");

-- CreateIndex
CREATE INDEX "PetSafetyScan_batchId_idx" ON "PetSafetyScan"("batchId");

-- CreateIndex
CREATE UNIQUE INDEX "PetSafetyScan_bookingId_slotIndex_soLan_key" ON "PetSafetyScan"("bookingId", "slotIndex", "soLan");

-- CreateIndex
CREATE UNIQUE INDEX "CheckinSlotXacNhan_bookingId_slotIndex_key" ON "CheckinSlotXacNhan"("bookingId", "slotIndex");

-- CreateIndex
CREATE INDEX "SessionPhoto_bookingId_takenAt_idx" ON "SessionPhoto"("bookingId", "takenAt");

-- CreateIndex
CREATE INDEX "SessionPhoto_takenAt_id_idx" ON "SessionPhoto"("takenAt" DESC, "id");

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
CREATE INDEX "BookingGpsReport_reviewedAt_idx" ON "BookingGpsReport"("reviewedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Review_bookingId_key" ON "Review"("bookingId");

-- CreateIndex
CREATE INDEX "Review_createdAt_idx" ON "Review"("createdAt");

-- CreateIndex
CREATE INDEX "Review_reviewerId_idx" ON "Review"("reviewerId");

-- CreateIndex
CREATE UNIQUE INDEX "ViolationReport_code_key" ON "ViolationReport"("code");

-- CreateIndex
CREATE INDEX "ViolationReport_bookingId_idx" ON "ViolationReport"("bookingId");

-- CreateIndex
CREATE INDEX "ViolationReport_reporterId_createdAt_idx" ON "ViolationReport"("reporterId", "createdAt");

-- CreateIndex
CREATE INDEX "ViolationReport_reasonCode_idx" ON "ViolationReport"("reasonCode");

-- CreateIndex
CREATE UNIQUE INDEX "Wallet_sitterId_key" ON "Wallet"("sitterId");

-- CreateIndex
CREATE UNIQUE INDEX "WalletTransaction_code_key" ON "WalletTransaction"("code");

-- CreateIndex
CREATE INDEX "WalletTransaction_walletId_createdAt_idx" ON "WalletTransaction"("walletId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "BankAccount_sitterId_key" ON "BankAccount"("sitterId");

-- CreateIndex
CREATE INDEX "Withdrawal_sitterId_createdAt_idx" ON "Withdrawal"("sitterId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Conversation_bookingId_key" ON "Conversation"("bookingId");

-- CreateIndex
CREATE INDEX "Conversation_lastMessageAt_idx" ON "Conversation"("lastMessageAt");

-- CreateIndex
CREATE INDEX "Message_bookingId_createdAt_idx" ON "Message"("bookingId", "createdAt");

-- CreateIndex
CREATE INDEX "Message_conversationId_createdAt_idx" ON "Message"("conversationId", "createdAt");

-- CreateIndex
CREATE INDEX "Notification_userId_createdAt_idx" ON "Notification"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "Notification_userId_isRead_idx" ON "Notification"("userId", "isRead");

-- CreateIndex
CREATE INDEX "Notification_campaignId_idx" ON "Notification"("campaignId");

-- CreateIndex
CREATE UNIQUE INDEX "DeviceToken_token_key" ON "DeviceToken"("token");

-- CreateIndex
CREATE INDEX "DeviceToken_userId_idx" ON "DeviceToken"("userId");

-- CreateIndex
CREATE INDEX "NotificationCampaign_createdAt_idx" ON "NotificationCampaign"("createdAt");

-- CreateIndex
CREATE INDEX "AdminAuditLog_createdAt_idx" ON "AdminAuditLog"("createdAt");

-- CreateIndex
CREATE INDEX "AdminAuditLog_targetType_targetId_idx" ON "AdminAuditLog"("targetType", "targetId");

-- AddForeignKey
ALTER TABLE "SearchHistory" ADD CONSTRAINT "SearchHistory_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Address" ADD CONSTRAINT "Address_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Sitter" ADD CONSTRAINT "Sitter_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterPenalty" ADD CONSTRAINT "SitterPenalty_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterPenalty" ADD CONSTRAINT "SitterPenalty_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BoardingUpdate" ADD CONSTRAINT "BoardingUpdate_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterPhoto" ADD CONSTRAINT "SitterPhoto_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterDaySetting" ADD CONSTRAINT "SitterDaySetting_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SitterService" ADD CONSTRAINT "SitterService_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Pet" ADD CONSTRAINT "Pet_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PetPhoto" ADD CONSTRAINT "PetPhoto_petId_fkey" FOREIGN KEY ("petId") REFERENCES "Pet"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PreventionRecord" ADD CONSTRAINT "PreventionRecord_petId_fkey" FOREIGN KEY ("petId") REFERENCES "Pet"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PreventionDose" ADD CONSTRAINT "PreventionDose_recordId_fkey" FOREIGN KEY ("recordId") REFERENCES "PreventionRecord"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PreventionDosePhoto" ADD CONSTRAINT "PreventionDosePhoto_doseId_fkey" FOREIGN KEY ("doseId") REFERENCES "PreventionDose"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_serviceId_fkey" FOREIGN KEY ("serviceId") REFERENCES "Service"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_addressId_fkey" FOREIGN KEY ("addressId") REFERENCES "Address"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingPet" ADD CONSTRAINT "BookingPet_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingPet" ADD CONSTRAINT "BookingPet_petId_fkey" FOREIGN KEY ("petId") REFERENCES "Pet"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Payment" ADD CONSTRAINT "Payment_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CheckinScanBatch" ADD CONSTRAINT "CheckinScanBatch_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PetSafetyScan" ADD CONSTRAINT "PetSafetyScan_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PetSafetyScan" ADD CONSTRAINT "PetSafetyScan_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "CheckinScanBatch"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CheckinSlotXacNhan" ADD CONSTRAINT "CheckinSlotXacNhan_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

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
ALTER TABLE "Wallet" ADD CONSTRAINT "Wallet_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "WalletTransaction" ADD CONSTRAINT "WalletTransaction_walletId_fkey" FOREIGN KEY ("walletId") REFERENCES "Wallet"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BankAccount" ADD CONSTRAINT "BankAccount_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Withdrawal" ADD CONSTRAINT "Withdrawal_sitterId_fkey" FOREIGN KEY ("sitterId") REFERENCES "Sitter"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Conversation" ADD CONSTRAINT "Conversation_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_conversationId_fkey" FOREIGN KEY ("conversationId") REFERENCES "Conversation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_senderId_fkey" FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "NotificationCampaign"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DeviceToken" ADD CONSTRAINT "DeviceToken_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NotificationCampaign" ADD CONSTRAINT "NotificationCampaign_adminId_fkey" FOREIGN KEY ("adminId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AdminAuditLog" ADD CONSTRAINT "AdminAuditLog_adminId_fkey" FOREIGN KEY ("adminId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE INDEX IF NOT EXISTS "idx_sitter_location" ON "Sitter" USING GIST (ST_SetSRID(ST_MakePoint(lng, lat), 4326));
CREATE INDEX IF NOT EXISTS "idx_address_location" ON "Address" USING GIST (ST_SetSRID(ST_MakePoint(lng, lat), 4326));
