import type { BookingStatus } from '@/features/bookings/types';

export type UserRole = 'OWNER' | 'PROVIDER' | 'ADMIN';

export type UserRow = {
  id: string;
  fullName: string;
  email: string;
  phone: string | null;
  role: UserRole;
  avatarUrl: string | null;
  isActive: boolean;
  isVerified: boolean;
  createdAt: string;
  petCount: number;
  bookingCount: number;
  province: string | null;
  isSitter: boolean;
};

export type UserListQuery = {
  q?: string;
  role?: UserRole;
  active?: boolean;
  province?: string;
  from?: string;
  to?: string;
  page?: number;
  limit?: number;
};

export type UserListResponse = {
  total: number;
  page: number;
  limit: number;
  items: UserRow[];
};

export type UserTabKey = 'all' | 'owner' | 'provider' | 'locked';

export type UserTabCounts = Record<UserTabKey, number>;

export type AddressLabel = 'HOME' | 'WORK' | 'OTHER';

export type UserAddress = {
  id: string;
  label: AddressLabel;
  customLabel: string | null;
  text: string;
  isDefault: boolean;
};

export type PetSpecies = 'DOG' | 'CAT';

export type UserPetBrief = {
  id: string;
  name: string;
  species: PetSpecies;
  breed: string | null;
  ageLabel: string;
  avatarUrl: string | null;
  isActive: boolean;
};

export type UserActivityKind = 'BOOKING' | 'DISPUTE';

export type UserActivity = {
  kind: UserActivityKind;
  title: string;
  detail: string;
  at: string;
};

export type UserBookingRow = {
  code: string;
  createdAt: string;
  serviceName: string | null;
  petNames: string;
  sitterName: string | null;
  totalPrice: number | null;
  status: BookingStatus;
};

export type UserDetail = {
  user: {
    id: string;
    fullName: string;
    email: string;
    phone: string | null;
    role: UserRole;
    avatarUrl: string | null;
    isActive: boolean;
    isVerified: boolean;
    createdAt: string;
    defaultAddress: string | null;
    isSitter: boolean;
  };
  stats: {
    bookingCount: number;
    openBookingCount: number;
    runningBookingCount: number;
    totalSpent: number;
    avgPerBooking: number | null;
    reviewCount: number;
    avgRating: number | null;
    disputeCount: number;
    resolvedDisputeCount: number;
  };
  pets: UserPetBrief[];
  addresses: UserAddress[];
  recentBookings: UserBookingRow[];
  activities: UserActivity[];
};

export type PreventionDose = {
  id: string;
  doneAt: string;
  place: string | null;
  nextDueAt: string | null;
  photos: string[];
};

export type PreventionRecord = {
  id: string;
  code: string;
  customName: string | null;
  form: 'VACCINE' | 'ORAL' | 'SPOT_ON' | 'OTHER' | null;
  doses: PreventionDose[];
};

export type PetPreventionResponse = { items: PreventionRecord[] };

export type PetDetail = {
  id: string;
  name: string;
  species: PetSpecies;
  breed: string | null;
  gender: 'MALE' | 'FEMALE' | null;
  birthDate: string | null;
  weightKg: number | null;
  isNeutered: boolean;
  underTreatment: boolean;
  chronicDisease: string | null;
  medication: string | null;
  careNote: string | null;
  avatarUrl: string | null;
  isActive: boolean;
  photos: Array<{ id: string; url: string; sortOrder: number }>;
  preventionCount: number;
};
