export type NotificationType =
  | 'DON_HANG'
  | 'DON_HUY'
  | 'DON_MOI'
  | 'BANG_CHUNG'
  | 'NHAC_LICH'
  | 'HO_SO'
  | 'DANH_GIA'
  | 'TIN_NHAN'
  | 'NOI_DUNG'
  | 'TIEN_VI'
  | 'PHONG_BENH'
  | 'KHIEU_NAI';

export type NotificationRole = 'CHU_NUOI' | 'NGUOI_CHAM';

export type AudienceKind =
  | 'ALL_OWNERS'
  | 'ALL_SITTERS'
  | 'BOTH'
  | 'OWNERS_BY_PROVINCE'
  | 'SINGLE_USER';

export const NHOM_CAN_THAM_SO: AudienceKind[] = ['OWNERS_BY_PROVINCE', 'SINGLE_USER'];

export const NHOM_NGUOI_NHAN: AudienceKind[] = [
  'ALL_OWNERS',
  'ALL_SITTERS',
  'BOTH',
  'OWNERS_BY_PROVINCE',
  'SINGLE_USER',
];

export type CampaignRow = {
  id: string;
  title: string;
  body: string;
  role: NotificationRole;
  audienceKind: AudienceKind;
  audienceValue: string | null;
  urgent: boolean;
  recipientCount: number;
  readCount: number;
  sentAt: string | null;
  scheduledAt: string | null;
  createdAt: string;
};

export type CampaignListResponse = {
  total: number;
  page: number;
  limit: number;
  items: CampaignRow[];
};

export type BroadcastInput = {
  title: string;
  body: string;
  audienceKind: AudienceKind;
  audienceValue?: string;
  urgent: boolean;
  scheduledAt?: string;
};

export type BroadcastResult = {
  id: string;
  scheduledAt: string | null;
};

export type AudienceCount = {
  kind: AudienceKind;
  value: string | null;
  count: number;
};

export type NotificationTypeRow = {
  type: NotificationType;
  event: string;
  audience: 'OWNER' | 'SITTER' | 'BOTH';
  openTarget: string;
  inApp: boolean;
  push: boolean;
  hasTrigger: boolean;
};

export type PreventionNote = {
  label: string;
  desc: string;
  value: string;
};
