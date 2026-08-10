import {
  ExecutionContext,
  HttpException,
  HttpStatus,
  Injectable,
} from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';

// Chỉ đếm HTTP: đưa ngữ cảnh socket vào đây là guard đọc nhầm request và vỡ mọi gateway
@Injectable()
export class IpThrottlerGuard extends ThrottlerGuard {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    if (context.getType() !== 'http') return true;
    return super.canActivate(context);
  }

  protected throwThrottlingException(): Promise<void> {
    throw new HttpException(
      {
        code: 'QUA_NHIEU_YEU_CAU',
        message: 'Bạn thao tác quá nhanh, vui lòng thử lại sau một phút',
      },
      HttpStatus.TOO_MANY_REQUESTS,
    );
  }
}
