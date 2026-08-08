export type DonViThamSo = 'phanTram' | 'gio' | 'ngay' | 'dong' | 'lan' | 'don' | 'km';

export type KieuThamSo = 'so' | 'batTat' | 'chon';

export type GiaTriThamSo = number | boolean | string;

export type OperatingSetting = {
  key: string;
  kieu: KieuThamSo;
  donVi: DonViThamSo | null;
  giaTri: GiaTriThamSo;
  macDinh: GiaTriThamSo;
  min: number | null;
  max: number | null;
  luaChon: string[] | null;
  nguoiDoi: { id: string; hoTen: string | null } | null;
  capNhatLuc: string | null;
};

export type OperatingSettingsResponse = {
  capNhatLuc: string | null;
  items: OperatingSetting[];
};

export type UpdateSettingResult = {
  key: string;
  giaTri: GiaTriThamSo;
  capNhatLuc: string;
};

export type UpdateSettingInput = {
  key: string;
  giaTri: GiaTriThamSo;
  lyDo?: string;
};

export type AuditLogRow = {
  id: string;
  adminName: string;
  action: string;
  targetType: string;
  targetCode: string | null;
  reason: string | null;
  oldValue: string | null;
  newValue: string | null;
  createdAt: string;
};

export type AuditLogQuery = {
  action?: string;
  targetType?: string;
  page?: number;
  limit?: number;
};

export type AuditLogFilters = {
  actions: string[];
  targetTypes: string[];
};

export type AuditLogResponse = {
  total: number;
  page: number;
  limit: number;
  items: AuditLogRow[];
};

export type AdminAccountInfo = {
  id: string;
  hoTen: string;
  email: string;
  avatarUrl: string | null;
  taoLuc: string;
  doiMatKhauLuc: string | null;
  soThaoTacDaGhi: number;
  thaoTacGanNhatLuc: string | null;
};

export type LimitItem = {
  ma: string;
  value: string;
  unit: string;
};

export type LimitGroup = {
  key: string;
  cot: 'trai' | 'phai';
  items: LimitItem[];
  chuaCoTrongCode?: boolean;
  coDongDaChuyen?: boolean;
};
