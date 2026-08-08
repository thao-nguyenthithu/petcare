import { BadRequestException, Injectable } from '@nestjs/common';
import { BUCKET_ANH_CHAT, THU_MUC_ANH_CHAT } from '../media/anh-duong-dan';
import { AnhTaiLenService } from '../media/anh-tai-len.service';
import { type UploadedImage } from '../media/image-upload';
import { MessagingService } from './messaging.service';

export const SO_ANH_MOI_LUOT = 6;

// Tách khỏi MessagingService vì chỗ đó chỉ đụng database, đây phải qua storage
@Injectable()
export class ChatPhotoService {
  constructor(
    private readonly anh: AnhTaiLenService,
    private readonly messaging: MessagingService,
  ) {}

  async gui(
    userId: string,
    conversationId: string,
    files: UploadedImage[],
    caption?: string,
  ) {
    if (!files?.length) {
      throw new BadRequestException({
        code: 'THIEU_ANH',
        message: 'Cần ít nhất một ảnh',
      });
    }
    if (files.length > SO_ANH_MOI_LUOT) {
      throw new BadRequestException({
        code: 'VUOT_GIOI_HAN_ANH',
        message: `Mỗi lần gửi tối đa ${SO_ANH_MOI_LUOT} ảnh`,
      });
    }
    const ngu = await this.messaging.kiemQuyenGui(userId, conversationId);
    const duong = await this.anh.dayLen(
      BUCKET_ANH_CHAT,
      `${THU_MUC_ANH_CHAT}/${conversationId}`,
      files,
    );
    return this.messaging.ghiTin(ngu, { images: duong, caption });
  }
}
