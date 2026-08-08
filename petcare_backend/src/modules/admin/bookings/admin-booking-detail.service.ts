import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../prisma/prisma.service';
import { hanNhanDonCua } from '../../bookings/booking-time';
import { AnhKyService } from '../../media/anh-ky.service';
import { TRAN_DIEM_TRA_SOAT } from './tra-soat-gps';

@Injectable()
export class AdminBookingDetailService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly kyAnh: AnhKyService,
  ) {}

  private layDon(code: string) {
    return this.prisma.booking.findUnique({
      where: { code },
      select: {
        id: true,
        code: true,
        status: true,
        scheduledAt: true,
        scheduledEndAt: true,
        durationMinutes: true,
        addressText: true,
        totalPrice: true,
        platformFee: true,
        sitterPayout: true,
        cancellationFee: true,
        createdAt: true,
        paidAt: true,
        acceptedAt: true,
        departedAt: true,
        arrivedAt: true,
        arriveDistanceM: true,
        ownerArrivedAt: true,
        startedAt: true,
        endedAt: true,
        completedAt: true,
        escrowReleaseAt: true,
        lateMinutes: true,
        lateReportedAt: true,
        gearReportedAt: true,
        distanceKm: true,
        noShowProofUrls: true,
        owner: {
          select: { id: true, fullName: true, email: true, avatarUrl: true },
        },
        sitter: {
          select: {
            id: true,
            ratingAvg: true,
            user: {
              select: {
                id: true,
                fullName: true,
                email: true,
                avatarUrl: true,
              },
            },
          },
        },
        service: { select: { name: true, type: true } },
        pets: {
          select: {
            durationMinutes: true,
            price: true,
            pet: {
              select: {
                id: true,
                name: true,
                breed: true,
                birthDate: true,
                weightKg: true,
              },
            },
          },
        },
        // Trả hỏng rồi thử lại sinh bản mới, màn tiền đọc đúng bản mới nhất
        payments: {
          orderBy: { createdAt: 'desc' },
          take: 1,
          select: {
            status: true,
            txnRef: true,
            gatewayTxnNo: true,
            bankCode: true,
            cardType: true,
            paidAt: true,
            releasedAt: true,
            expiresAt: true,
          },
        },
        gpsReport: {
          select: {
            totalWaypoints: true,
            totalDistanceM: true,
            durationMinutes: true,
            avgSpeedKmh: true,
            suspicionScore: true,
            flaggedForReview: true,
            suspicionNote: true,
            mockedCount: true,
            speedFlag: true,
          },
        },
      },
    });
  }

  async chiTiet(code: string) {
    const [don, track] = await Promise.all([
      this.layDon(code),
      this.prisma.locationTrack.findMany({
        where: { booking: { code } },
        orderBy: { clientTs: 'asc' },
        // Lấy dư một điểm để phân biệt đúng 5000 điểm với lộ trình bị cắt
        take: TRAN_DIEM_TRA_SOAT + 1,
        select: {
          latitude: true,
          longitude: true,
          clientTs: true,
          isNoise: true,
        },
      }),
    ]);
    if (!don) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }

    const { owner, sitter, service, pets, payments, gpsReport, ...b } = don;
    const kyAnhVangMat = await this.kyAnh.kyMang(b.noShowProofUrls);
    return {
      booking: {
        ...b,
        noShowProofUrls: kyAnhVangMat,
        serviceName: service.name,
        serviceType: service.type,
        // Công thức bốn bậc kèm ràng buộc trước giờ hẹn, web không tự suy được
        acceptDeadlineAt: hanNhanDonCua(b),
      },
      owner,
      sitter: {
        id: sitter.id,
        userId: sitter.user.id,
        fullName: sitter.user.fullName,
        email: sitter.user.email,
        avatarUrl: sitter.user.avatarUrl,
        ratingAvg: sitter.ratingAvg,
      },
      pets: pets.map((p) => ({
        id: p.pet.id,
        name: p.pet.name,
        breed: p.pet.breed,
        birthDate: p.pet.birthDate,
        weightKg: p.pet.weightKg,
        durationMinutes: p.durationMinutes,
        price: p.price,
      })),
      payment: payments[0] ?? null,
      gpsReport,
      track: track.slice(0, TRAN_DIEM_TRA_SOAT).map((t) => ({
        lat: t.latitude,
        lng: t.longitude,
        clientTs: t.clientTs,
        isNoise: t.isNoise,
      })),
      // Màn phải nói thẳng là đã cắt, im lặng thì người soát tưởng đơn chỉ có bấy nhiêu
      trackTruncated: track.length > TRAN_DIEM_TRA_SOAT,
    };
  }
}
