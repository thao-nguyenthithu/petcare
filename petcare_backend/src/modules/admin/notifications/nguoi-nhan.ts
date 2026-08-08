import { Prisma } from '../../../../generated/prisma/client';
import {
  NotificationRole,
  SitterStatus,
  UserRole,
} from '../../../../generated/prisma/enums';

// Nhóm người nhận chọn ở màn 14, đúng tập ghi trong cột audienceKind
export const NHOM_NGUOI_NHAN = [
  'ALL_OWNERS',
  'ALL_SITTERS',
  'BOTH',
  'OWNERS_BY_PROVINCE',
  'SINGLE_USER',
] as const;

export type NhomNguoiNhan = (typeof NHOM_NGUOI_NHAN)[number];

// Nhóm cần tham số đi kèm, thiếu là chặn ngay ở biên
export const NHOM_CAN_THAM_SO: NhomNguoiNhan[] = [
  'OWNERS_BY_PROVINCE',
  'SINGLE_USER',
];

export type LopNguoiNhan = {
  where: Prisma.UserWhereInput;
  role: NotificationRole;
};

// Tài khoản bị khoá không nhận tin: gửi cho họ chỉ làm phình bảng Notification
const DANG_HOAT_DONG = { isActive: true };

function chuNuoi(tinh?: string | null): Prisma.UserWhereInput {
  return {
    ...DANG_HOAT_DONG,
    role: UserRole.OWNER,
    ...(tinh
      ? { addresses: { some: { isDefault: true, province: tinh } } }
      : {}),
  };
}

function nguoiCham(): Prisma.UserWhereInput {
  return { ...DANG_HOAT_DONG, sitter: { status: SitterStatus.APPROVED } };
}

// Một lượt gửi tách thành các lớp, mỗi lớp một vai vì role là thuộc tính của TIN
export function lopNguoiNhan(
  nhom: NhomNguoiNhan,
  thamSo: string | null,
  vai: NotificationRole,
): LopNguoiNhan[] {
  switch (nhom) {
    case 'ALL_OWNERS':
      return [{ where: chuNuoi(), role: NotificationRole.CHU_NUOI }];
    case 'ALL_SITTERS':
      return [{ where: nguoiCham(), role: NotificationRole.NGUOI_CHAM }];
    case 'BOTH':
      return [
        { where: chuNuoi(), role: NotificationRole.CHU_NUOI },
        { where: nguoiCham(), role: NotificationRole.NGUOI_CHAM },
      ];
    case 'OWNERS_BY_PROVINCE':
      return [{ where: chuNuoi(thamSo), role: NotificationRole.CHU_NUOI }];
    case 'SINGLE_USER':
      return [{ where: { ...DANG_HOAT_DONG, id: thamSo ?? '' }, role: vai }];
  }
}

export function vaiTheoVaiTaiKhoan(role: UserRole): NotificationRole {
  return role === UserRole.PROVIDER
    ? NotificationRole.NGUOI_CHAM
    : NotificationRole.CHU_NUOI;
}

// Vai của tin khi chưa biết người nhận cụ thể; nhóm BOTH lấy vai của lớp đầu
export function vaiMacDinh(nhom: NhomNguoiNhan): NotificationRole {
  return nhom === 'ALL_SITTERS'
    ? NotificationRole.NGUOI_CHAM
    : NotificationRole.CHU_NUOI;
}
