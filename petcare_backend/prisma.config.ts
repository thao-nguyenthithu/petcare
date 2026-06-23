import "dotenv/config";
import { defineConfig } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    url: process.env["DIRECT_URL"],
    // Database riêng để Prisma thử migration, tránh lỗi thiếu hàm PostGIS
    shadowDatabaseUrl: process.env["SHADOW_DATABASE_URL"],
  },
});