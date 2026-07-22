-- Đổi tên cột đường dẫn ảnh CCCD, RENAME để GIỮ NGUYÊN dữ liệu đã có
ALTER TABLE "ServiceProvider" RENAME COLUMN "idCardFrontPath" TO "cccdFrontPath";
ALTER TABLE "ServiceProvider" RENAME COLUMN "idCardBackPath" TO "cccdBackPath";
