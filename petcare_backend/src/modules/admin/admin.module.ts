import { Module } from '@nestjs/common';
import { SitterPenaltyService } from '../bookings/sitter-penalty.service';
import { FirebaseModule } from '../firebase/firebase.module';
import { MediaModule } from '../media/media.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { WalletLedgerService } from '../wallet/wallet-ledger.service';
import { AdminSettingsController } from './admin-settings.controller';
import { CauHinhCongKhaiController } from './cau-hinh-cong-khai.controller';
import { DanhMucDichVuService } from './danh-muc-dich-vu.service';
import { AdminBookingCancelService } from './bookings/admin-booking-cancel.service';
import { AdminBookingConversationService } from './bookings/admin-booking-conversation.service';
import { AdminBookingDetailService } from './bookings/admin-booking-detail.service';
import { AdminBookingsController } from './bookings/admin-bookings.controller';
import { AdminBookingsReadService } from './bookings/admin-bookings-read.service';
import { AdminGpsReportsController } from './bookings/admin-gps-reports.controller';
import { AdminGpsReportsService } from './bookings/admin-gps-reports.service';
import { AdminTrackCsvService } from './bookings/admin-track-csv.service';
import { NhatKyQuanTriService } from './chung/nhat-ky-quan-tri.service';
import { AdminDashboardController } from './dashboard/admin-dashboard.controller';
import { AdminDashboardService } from './dashboard/admin-dashboard.service';
import { AdminQueueService } from './dashboard/admin-queue.service';
import { GioiHanController } from './gioi-han/gioi-han.controller';
import { GioiHanService } from './gioi-han/gioi-han.service';
import { AdminDisputeDetailService } from './disputes/admin-dispute-detail.service';
import { AdminDisputeResolveService } from './disputes/admin-dispute-resolve.service';
import { AdminDisputesController } from './disputes/admin-disputes.controller';
import { AdminDisputesReadService } from './disputes/admin-disputes-read.service';
import { AdminBookingEvidenceService } from './evidence/admin-booking-evidence.service';
import { AdminEvidenceController } from './evidence/admin-evidence.controller';
import { AdminEvidenceReadService } from './evidence/admin-evidence-read.service';
import { AdminFinanceController } from './finance/admin-finance.controller';
import { AdminFinanceSummaryService } from './finance/admin-finance-summary.service';
import { AdminPaymentsController } from './finance/admin-payments.controller';
import { AdminPaymentsReadService } from './finance/admin-payments-read.service';
import { AdminRefundsController } from './finance/admin-refunds.controller';
import { AdminRefundsReadService } from './finance/admin-refunds-read.service';
import { AdminRefundsWriteService } from './finance/admin-refunds-write.service';
import { AdminWithdrawalsService } from './finance/admin-withdrawals.service';
import { AdminAuditLogsController } from './nhat-ky/admin-audit-logs.controller';
import { AdminAuditLogsService } from './nhat-ky/admin-audit-logs.service';
import { AdminBroadcastProcessor } from './notifications/admin-broadcast.processor';
import { AdminNotificationsController } from './notifications/admin-notifications.controller';
import { AdminNotificationsReadService } from './notifications/admin-notifications-read.service';
import { AdminNotificationsWriteService } from './notifications/admin-notifications-write.service';
import { AdminReviewsController } from './reviews/admin-reviews.controller';
import { AdminReviewsReadService } from './reviews/admin-reviews-read.service';
import { AdminServicesController } from './services/admin-services.controller';
import { AdminServicesReadService } from './services/admin-services-read.service';
import { AdminServicesWriteService } from './services/admin-services-write.service';
import { AdminPenaltiesService } from './sitters/admin-penalties.service';
import { AdminSittersController } from './sitters/admin-sitters.controller';
import { AdminSittersReadService } from './sitters/admin-sitters-read.service';
import { AdminSittersWriteService } from './sitters/admin-sitters-write.service';
import { AdminAccountController } from './tai-khoan/admin-account.controller';
import { AdminAccountService } from './tai-khoan/admin-account.service';
import { AdminPetsService } from './users/admin-pets.service';
import { AdminUserDetailService } from './users/admin-user-detail.service';
import { AdminUsersController } from './users/admin-users.controller';
import { AdminUsersReadService } from './users/admin-users-read.service';
import { AdminUsersWriteService } from './users/admin-users-write.service';

// SystemSettingsService do ThamSoModule cấp, khai lại ở đây là hai bản cache
@Module({
  imports: [NotificationsModule, MediaModule, FirebaseModule],
  controllers: [
    AdminSettingsController,
    GioiHanController,
    CauHinhCongKhaiController,
    AdminDashboardController,
    AdminUsersController,
    AdminSittersController,
    AdminBookingsController,
    AdminGpsReportsController,
    AdminDisputesController,
    AdminEvidenceController,
    AdminReviewsController,
    AdminServicesController,
    AdminFinanceController,
    AdminPaymentsController,
    AdminRefundsController,
    AdminAuditLogsController,
    AdminAccountController,
    AdminNotificationsController,
  ],
  providers: [
    GioiHanService,
    NhatKyQuanTriService,
    DanhMucDichVuService,
    AdminDashboardService,
    AdminQueueService,
    AdminAccountService,
    AdminUsersReadService,
    AdminUserDetailService,
    AdminUsersWriteService,
    AdminPetsService,
    AdminSittersReadService,
    AdminSittersWriteService,
    AdminPenaltiesService,
    AdminBookingsReadService,
    AdminBookingDetailService,
    AdminBookingConversationService,
    AdminTrackCsvService,
    AdminBookingCancelService,
    AdminGpsReportsService,
    AdminDisputesReadService,
    AdminDisputeDetailService,
    AdminDisputeResolveService,
    AdminEvidenceReadService,
    AdminBookingEvidenceService,
    AdminReviewsReadService,
    AdminServicesReadService,
    AdminServicesWriteService,
    AdminFinanceSummaryService,
    AdminWithdrawalsService,
    AdminPaymentsReadService,
    AdminRefundsReadService,
    AdminRefundsWriteService,
    AdminAuditLogsService,
    AdminNotificationsReadService,
    AdminNotificationsWriteService,
    AdminBroadcastProcessor,
    // Khai thẳng chứ không nhập BookingsModule: nhập là thành vòng qua PaymentsModule
    SitterPenaltyService,
    // Cùng lý do với SitterPenaltyService, nhập WalletModule là thành vòng phụ thuộc
    WalletLedgerService,
  ],
})
export class AdminModule {}
