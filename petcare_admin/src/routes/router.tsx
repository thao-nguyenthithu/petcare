import { createBrowserRouter } from 'react-router-dom';
import { AdminLayout } from '@/layouts/admin-layout';
import { RequireAdmin } from '@/features/auth/guards/require-admin';
import { LoginScreen } from '@/features/auth/screens/login-screen';
import { PATHS } from '@/routes/paths';

export const router = createBrowserRouter([
  { path: PATHS.login, element: <LoginScreen /> },
  {
    path: PATHS.forgotPassword,
    lazy: async () => ({
      Component: (await import('@/features/auth/screens/forgot-password-screen'))
        .ForgotPasswordScreen,
    }),
  },
  {
    path: PATHS.verifyOtp,
    lazy: async () => ({
      Component: (await import('@/features/auth/screens/verify-otp-screen')).VerifyOtpScreen,
    }),
  },
  {
    path: PATHS.resetPassword,
    lazy: async () => ({
      Component: (await import('@/features/auth/screens/reset-password-screen'))
        .ResetPasswordScreen,
    }),
  },
  {
    element: <RequireAdmin />,
    children: [
      {
        path: '/',
        element: <AdminLayout />,
        children: [
          {
            index: true,
            lazy: async () => ({
              Component: (await import('@/features/dashboard/screens/dashboard-screen'))
                .DashboardScreen,
            }),
          },
          {
            path: PATHS.users.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/users/screens/users-screen')).UsersScreen,
            }),
          },
          {
            path: `${PATHS.users.slice(1)}/:id`,
            lazy: async () => ({
              Component: (await import('@/features/users/screens/user-detail-screen'))
                .UserDetailScreen,
            }),
          },
          {
            path: `${PATHS.users.slice(1)}/:id/pets`,
            lazy: async () => ({
              Component: (await import('@/features/users/screens/user-pets-screen'))
                .UserPetsScreen,
            }),
          },
          {
            path: PATHS.sitterApprovals.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/sitters/screens/sitter-approvals-screen'))
                .SitterApprovalsScreen,
            }),
          },
          {
            path: `${PATHS.sitterApprovals.slice(1)}/:id`,
            lazy: async () => ({
              Component: (await import('@/features/sitters/screens/sitter-detail-screen'))
                .SitterDetailScreen,
            }),
          },
          {
            path: PATHS.penalties.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/penalties/screens/penalties-screen'))
                .PenaltiesScreen,
            }),
          },
          {
            path: PATHS.services.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/services/screens/services-screen'))
                .ServicesScreen,
            }),
          },
          {
            path: PATHS.bookings.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/bookings/screens/bookings-screen'))
                .BookingsScreen,
            }),
          },
          {
            path: PATHS.gpsFlagged.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/bookings/screens/gps-flagged-screen'))
                .GpsFlaggedScreen,
            }),
          },
          {
            path: `${PATHS.bookings.slice(1)}/:code`,
            lazy: async () => ({
              Component: (await import('@/features/bookings/screens/booking-detail-screen'))
                .BookingDetailScreen,
            }),
          },
          {
            path: `${PATHS.bookings.slice(1)}/:code/conversation`,
            lazy: async () => ({
              Component: (await import('@/features/bookings/screens/booking-conversation-screen'))
                .BookingConversationScreen,
            }),
          },
          {
            path: PATHS.evidence.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/evidence/screens/evidence-screen'))
                .EvidenceScreen,
            }),
          },
          {
            path: `${PATHS.evidence.slice(1)}/:code`,
            lazy: async () => ({
              Component: (await import('@/features/evidence/screens/booking-album-screen'))
                .BookingAlbumScreen,
            }),
          },
          {
            path: PATHS.disputes.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/disputes/screens/disputes-screen'))
                .DisputesScreen,
            }),
          },
          {
            path: `${PATHS.disputes.slice(1)}/:code`,
            lazy: async () => ({
              Component: (await import('@/features/disputes/screens/dispute-detail-screen'))
                .DisputeDetailScreen,
            }),
          },
          {
            path: PATHS.reviews.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/reviews/screens/reviews-screen')).ReviewsScreen,
            }),
          },
          {
            path: PATHS.finance.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/finance/screens/finance-screen')).FinanceScreen,
            }),
          },
          {
            path: PATHS.payments.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/finance/screens/payments-screen'))
                .PaymentsScreen,
            }),
          },
          {
            path: PATHS.refunds.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/finance/screens/refunds-screen')).RefundsScreen,
            }),
          },
          {
            path: PATHS.broadcast.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/notifications/screens/broadcast-screen'))
                .BroadcastScreen,
            }),
          },
          {
            path: PATHS.notificationTypes.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/notifications/screens/notification-types-screen'))
                .NotificationTypesScreen,
            }),
          },
          {
            path: PATHS.settings.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/settings/screens/settings-screen'))
                .SettingsScreen,
            }),
          },
          {
            path: PATHS.limits.slice(1),
            lazy: async () => ({
              Component: (await import('@/features/settings/screens/limits-screen')).LimitsScreen,
            }),
          },
          {
            path: '*',
            lazy: async () => ({
              Component: (await import('@/pages/not-found-page')).NotFoundPage,
            }),
          },
        ],
      },
    ],
  },
]);
