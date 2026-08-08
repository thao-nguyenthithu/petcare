import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { financeApi } from '@/features/finance/api/finance-api';
import type {
  MarkRefundManualInput,
  PaymentListQuery,
  RefundListQuery,
  UpdateWithdrawalInput,
  WithdrawalListQuery,
} from '@/features/finance/types';

const FINANCE_KEY = ['admin', 'finance'] as const;
const WITHDRAWAL_KEY = ['admin', 'withdrawals'] as const;
const PAYMENT_KEY = ['admin', 'payments'] as const;
const REFUND_KEY = ['admin', 'refunds'] as const;

export function useFinanceSummary() {
  return useQuery({
    queryKey: [...FINANCE_KEY, 'summary'],
    queryFn: financeApi.getSummary,
  });
}

export function useWithdrawals(query: WithdrawalListQuery) {
  return useQuery({
    queryKey: [...WITHDRAWAL_KEY, 'list', query],
    queryFn: () => financeApi.getWithdrawals(query),
    placeholderData: keepPreviousData,
  });
}

export function useUpdateWithdrawal() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: UpdateWithdrawalInput) => financeApi.updateWithdrawal(input),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: WITHDRAWAL_KEY });
      void queryClient.invalidateQueries({ queryKey: FINANCE_KEY });
    },
  });
}

export function usePayments(query: PaymentListQuery) {
  return useQuery({
    queryKey: [...PAYMENT_KEY, 'list', query],
    queryFn: () => financeApi.getPayments(query),
    placeholderData: keepPreviousData,
  });
}

export function usePaymentTabCounts() {
  return useQuery({
    queryKey: [...PAYMENT_KEY, 'counts'],
    queryFn: financeApi.getPaymentTabCounts,
  });
}

export function usePaymentRaw(txnRef: string | null) {
  return useQuery({
    queryKey: [...PAYMENT_KEY, 'raw', txnRef],
    queryFn: () => financeApi.getPaymentRaw(txnRef ?? ''),
    enabled: Boolean(txnRef),
  });
}

export function useRefunds(query: RefundListQuery) {
  return useQuery({
    queryKey: [...REFUND_KEY, 'list', query],
    queryFn: () => financeApi.getRefunds(query),
    placeholderData: keepPreviousData,
  });
}

export function useRefundTabCounts() {
  return useQuery({
    queryKey: [...REFUND_KEY, 'counts'],
    queryFn: financeApi.getRefundTabCounts,
  });
}

export function useMarkRefundManual() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: MarkRefundManualInput) => financeApi.markRefundManual(input),
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: REFUND_KEY });
      void queryClient.invalidateQueries({ queryKey: PAYMENT_KEY });
      void queryClient.invalidateQueries({ queryKey: FINANCE_KEY });
    },
  });
}
