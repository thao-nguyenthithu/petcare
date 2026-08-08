import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { evidenceApi } from '@/features/evidence/api/evidence-api';
import type { EvidenceQuery } from '@/features/evidence/types';

const EVIDENCE_KEY = ['admin', 'evidence'] as const;

export function useEvidence(query: EvidenceQuery) {
  return useQuery({
    queryKey: [...EVIDENCE_KEY, 'list', query],
    queryFn: () => evidenceApi.getEvidence(query),
    placeholderData: keepPreviousData,
  });
}

export function useEvidenceSourceCounts() {
  return useQuery({
    queryKey: [...EVIDENCE_KEY, 'counts'],
    queryFn: evidenceApi.getSourceCounts,
  });
}

export function useBookingEvidence(code: string) {
  return useQuery({
    queryKey: [...EVIDENCE_KEY, 'album', code],
    queryFn: () => evidenceApi.getBookingEvidence(code),
    enabled: Boolean(code),
  });
}
