// Query string chỉ mang chuỗi, "true" và "false" phải tự đổi sang boolean
export function veBoolean(gia: unknown): boolean | undefined {
  if (gia === true || gia === 'true') return true;
  if (gia === false || gia === 'false') return false;
  return undefined;
}

export function catKhoangTrang(gia: unknown): string | undefined {
  if (typeof gia !== 'string') return undefined;
  const sach = gia.trim();
  return sach.length ? sach : undefined;
}
