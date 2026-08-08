import {
  AlertTriangle,
  Ban,
  Bell,
  BellRing,
  CalendarDays,
  FileCheck,
  Gauge,
  Image,
  Layers,
  LayoutDashboard,
  Receipt,
  RotateCcw,
  Settings,
  Star,
  Users,
  Wallet,
  type LucideIcon,
} from 'lucide-react';
import { PATHS } from '@/routes/paths';

export type NavItem = {
  key: string;
  path: string;
  icon: LucideIcon;
};

export type NavGroup = {
  titleKey: string;
  items: NavItem[];
};

export const NAV_GROUPS: NavGroup[] = [
  {
    titleKey: 'nhom.tongQuan',
    items: [{ key: 'tongQuan', path: PATHS.dashboard, icon: LayoutDashboard }],
  },
  {
    titleKey: 'nhom.nguoiDung',
    items: [
      { key: 'nguoiDung', path: PATHS.users, icon: Users },
      { key: 'hoSoChoDuyet', path: PATHS.sitterApprovals, icon: FileCheck },
      { key: 'kyLuat', path: PATHS.penalties, icon: Ban },
    ],
  },
  {
    titleKey: 'nhom.vanHanh',
    items: [
      { key: 'dichVu', path: PATHS.services, icon: Layers },
      { key: 'donDatLich', path: PATHS.bookings, icon: CalendarDays },
      { key: 'anhBangChung', path: PATHS.evidence, icon: Image },
    ],
  },
  {
    titleKey: 'nhom.anToan',
    items: [
      { key: 'khieuNai', path: PATHS.disputes, icon: AlertTriangle },
      { key: 'danhGia', path: PATHS.reviews, icon: Star },
    ],
  },
  {
    titleKey: 'nhom.taiChinh',
    items: [
      { key: 'doanhThu', path: PATHS.finance, icon: Wallet },
      { key: 'giaoDich', path: PATHS.payments, icon: Receipt },
      { key: 'hoanTien', path: PATHS.refunds, icon: RotateCcw },
    ],
  },
  {
    titleKey: 'nhom.heThong',
    items: [
      { key: 'guiThongBao', path: PATHS.broadcast, icon: BellRing },
      { key: 'loaiThongBao', path: PATHS.notificationTypes, icon: Bell },
      { key: 'caiDat', path: PATHS.settings, icon: Settings },
      { key: 'gioiHan', path: PATHS.limits, icon: Gauge },
    ],
  },
];

export function getNavKey(pathname: string): string | null {
  const items = NAV_GROUPS.flatMap((group) => group.items);
  const khop = items.find((item) => item.path === pathname);
  if (khop) return khop.key;
  const theoTienTo = items
    .filter((item) => item.path !== '/' && pathname.startsWith(`${item.path}/`))
    .sort((a, b) => b.path.length - a.path.length)[0];
  return theoTienTo?.key ?? null;
}
