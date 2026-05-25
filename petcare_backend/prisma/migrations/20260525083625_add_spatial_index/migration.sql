-- GIST Spatial Index cho ST_DWithin search (tìm SP gần)
-- Prisma không hỗ trợ GIST index natively → phải dùng Raw SQL
-- Không xóa file migration này kể cả khi reset schema
CREATE INDEX IF NOT EXISTS idx_service_provider_location
ON "ServiceProvider"
USING GIST (ST_SetSRID(ST_MakePoint(lng, lat), 4326));