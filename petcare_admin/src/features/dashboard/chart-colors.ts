export const SERVICE_TYPES = ['WALKING', 'BOARDING', 'GROOMING'] as const;
export type ServiceType = (typeof SERVICE_TYPES)[number];

export const SERVICE_MIX_COLORS: Record<ServiceType, string> = {
  WALKING: '#0E8F63',
  BOARDING: '#2F6FB8',
  GROOMING: '#D4562E',
};

export const REVENUE_COLORS = {
  sitterPayout: '#7C5CD6',
  platformFee: '#C2185B',
} as const;
