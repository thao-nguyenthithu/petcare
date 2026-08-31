-- GIST idx_sitter_location (tạo thủ công ở migration khởi tạo) không được planner dùng cho lọc
-- range lat/lng thường (WHERE lat BETWEEN ... AND lng BETWEEN ...) như search/sitter-search.service.ts
-- đang làm, chỉ dùng được cho hàm không gian kiểu ST_DWithin. Thêm btree thường cho đúng kiểu lọc hiện có.
CREATE INDEX IF NOT EXISTS "Sitter_lat_lng_idx" ON "Sitter"("lat", "lng");
