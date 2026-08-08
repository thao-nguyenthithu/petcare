import i18n from '@/core/i18n';
import { DO_DAI_MA_HOAN_TOI_THIEU } from '@/features/finance/finance-constants';
import type {
  FinanceSummary,
  MarkRefundManualInput,
  MarkRefundManualResult,
  PaymentListQuery,
  PaymentListResponse,
  PaymentTabKey,
  RefundListQuery,
  RefundListResponse,
  RefundTabKey,
  UpdateWithdrawalInput,
  WithdrawalListQuery,
  WithdrawalListResponse,
} from '@/features/finance/types';
import { apiClient } from '@/lib/api/client';

export const financeApi = {
  async getSummary(): Promise<FinanceSummary> {
    const { data } = await apiClient.get<FinanceSummary>('/admin/finance/summary');
    return data;
  },

  async getWithdrawals(query: WithdrawalListQuery): Promise<WithdrawalListResponse> {
    const { data } = await apiClient.get<WithdrawalListResponse>('/admin/withdrawals', {
      params: query,
    });
    return data;
  },

  async updateWithdrawal({ id, ...than }: UpdateWithdrawalInput) {
    const { data } = await apiClient.patch<{ id: string; status: string }>(
      `/admin/withdrawals/${encodeURIComponent(id)}`,
      than,
    );
    return data;
  },

  async getPayments({ status, ...conLai }: PaymentListQuery): Promise<PaymentListResponse> {
    const { data } = await apiClient.get<PaymentListResponse>('/admin/payments', {
      params: { ...conLai, status: status?.length ? status.join(',') : undefined },
    });
    return data;
  },

  async getPaymentTabCounts(): Promise<Record<PaymentTabKey, number>> {
    const { data } = await apiClient.get<Record<PaymentTabKey, number>>('/admin/payments/counts');
    return data;
  },

  async getPaymentRaw(txnRef: string): Promise<string | null> {
    const { data } = await apiClient.get<{ rawReturn: unknown }>(
      `/admin/payments/${encodeURIComponent(txnRef)}/raw`,
    );
    const tho = data.rawReturn;
    if (tho === null || tho === undefined) return null;
    return typeof tho === 'string' ? tho : JSON.stringify(tho, null, 2);
  },

  async getRefunds(query: RefundListQuery): Promise<RefundListResponse> {
    const { data } = await apiClient.get<RefundListResponse>('/admin/refunds', { params: query });
    return data;
  },

  async getRefundTabCounts(): Promise<Record<RefundTabKey, number>> {
    const { data } = await apiClient.get<Record<RefundTabKey, number>>('/admin/refunds/counts');
    return data;
  },

  async markRefundManual({ txnRef, reference, note }: MarkRefundManualInput) {
    const ma = reference.trim();
    if (ma.length < DO_DAI_MA_HOAN_TOI_THIEU) {
      throw new Error(i18n.t('hoanTien.maQuaNgan', { count: DO_DAI_MA_HOAN_TOI_THIEU }));
    }
    const ghiChu = note?.trim();
    const { data } = await apiClient.post<MarkRefundManualResult>(
      `/admin/refunds/${encodeURIComponent(txnRef)}/mark-manual`,
      { reference: ma, note: ghiChu ? ghiChu : undefined },
    );
    return data;
  },
};
