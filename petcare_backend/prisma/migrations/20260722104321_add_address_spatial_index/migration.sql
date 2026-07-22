-- GIST Spatial Index cho ST_DWithin search (NCC tìm địa chỉ gần)
-- Prisma không hỗ trợ GIST index natively → dùng Raw SQL, không xoá file này
CREATE INDEX IF NOT EXISTS idx_address_location
ON "Address"
USING GIST (ST_SetSRID(ST_MakePoint(lng, lat), 4326));
