import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { reviewsApi } from '@/features/reviews/api/reviews-api';
import type { ReviewListQuery } from '@/features/reviews/types';

const REVIEWS_KEY = ['admin', 'reviews'] as const;

export function useReviews(query: ReviewListQuery) {
  return useQuery({
    queryKey: [...REVIEWS_KEY, 'list', query],
    queryFn: () => reviewsApi.getReviews(query),
    placeholderData: keepPreviousData,
  });
}

export function useReviewTabCounts() {
  return useQuery({
    queryKey: [...REVIEWS_KEY, 'counts'],
    queryFn: reviewsApi.getTabCounts,
  });
}
