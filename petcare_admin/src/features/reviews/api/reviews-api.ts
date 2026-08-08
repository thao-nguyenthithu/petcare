import type {
  ReviewListQuery,
  ReviewListResponse,
  ReviewTabKey,
} from '@/features/reviews/types';
import { apiClient } from '@/lib/api/client';

export const reviewsApi = {
  async getReviews(query: ReviewListQuery): Promise<ReviewListResponse> {
    const { data } = await apiClient.get<ReviewListResponse>('/admin/reviews', {
      params: query,
    });
    return data;
  },

  async getTabCounts(): Promise<Record<ReviewTabKey, number>> {
    const { data } = await apiClient.get<Record<ReviewTabKey, number>>(
      '/admin/reviews/counts',
    );
    return data;
  },
};
