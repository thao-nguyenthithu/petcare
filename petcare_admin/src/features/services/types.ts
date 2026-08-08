import type { ServiceType } from '@/features/dashboard/chart-colors';

export type ServicesTabKey = 'catalog' | 'sitterServices' | 'constants';

export type ServiceRow = {
  id: string | null;
  type: ServiceType;
  name: string | null;
  description: string | null;
  enabledSitterCount: number;
};

export type ServiceUpdateInput = {
  name: string;
  description: string;
};

export type PetKind = 'DOG' | 'CAT' | 'BOTH';

export type WalkingPricing = {
  type: 'WALKING';
  priceByDuration: Record<string, number>;
  additionalPetFee: number | null;
  maxPets: number | null;
};

export type BoardingPricing = {
  type: 'BOARDING';
  pricePerDay: number | null;
  capacity: number | null;
  additionalPetFee: number | null;
  maxPets: number | null;
};

export type GroomingPricing = {
  type: 'GROOMING';
  priceByPackage: Record<string, Record<string, number>>;
  durationByPackage: Record<string, Record<string, number>>;
  maxPets: number | null;
};

export type ServicePricing = WalkingPricing | BoardingPricing | GroomingPricing;

export type SitterServiceRow = {
  id: string;
  sitterId: string;
  sitterName: string;
  type: ServiceType;
  enabled: boolean;
  petKind: PetKind;
  pricing: ServicePricing;
  updatedAt: string;
};

export type SitterServiceQuery = {
  q?: string;
  type?: ServiceType;
  enabled?: boolean;
  page?: number;
  limit?: number;
};

export type SitterServiceResponse = {
  total: number;
  page: number;
  limit: number;
  items: SitterServiceRow[];
};

export type SetSitterServiceEnabledInput = {
  id: string;
  enabled: boolean;
  reason: string;
};

export type ServiceConstraintRow = {
  code: string;
  numbers: number[];
  keys: string[];
};
