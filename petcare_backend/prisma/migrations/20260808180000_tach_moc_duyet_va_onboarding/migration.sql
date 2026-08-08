-- Mốc duyệt hồ sơ tách khỏi mốc người chăm bấm bắt đầu nhận đơn
ALTER TABLE "Sitter" ADD COLUMN "approvedAt" TIMESTAMPTZ(3);

UPDATE "Sitter" SET "approvedAt" = "onboardedAt" WHERE "onboardedAt" IS NOT NULL;

-- Hồ sơ chưa khai dịch vụ nào thì mốc cũ là do lệnh duyệt ghi, không phải người chăm bấm
UPDATE "Sitter" SET "onboardedAt" = NULL
WHERE "onboardedAt" IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM "SitterService" WHERE "SitterService"."sitterId" = "Sitter"."id");
