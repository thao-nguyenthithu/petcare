export function chuoiThanhMang(value: unknown): string[] {
  if (Array.isArray(value)) return value.map((e) => String(e));
  if (typeof value === 'string') {
    return value
      .split(',')
      .map((e) => e.trim())
      .filter((e) => e.length > 0);
  }
  return [];
}
