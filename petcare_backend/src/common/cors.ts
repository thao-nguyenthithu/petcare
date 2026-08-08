export function nguonChoPhep(): string[] | boolean {
  const khai = process.env.CORS_ORIGINS?.split(',')
    .map((nguon) => nguon.trim())
    .filter(Boolean);
  if (khai?.length) return khai;
  return process.env.NODE_ENV !== 'production';
}
