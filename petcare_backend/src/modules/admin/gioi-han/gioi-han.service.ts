import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { nhomNenTang } from './gioi-han-nen-tang';
import { nhomVanHanh } from './gioi-han-van-hanh';
import type { NhomGioiHan } from './gioi-han.types';

// Không chạm cơ sở dữ liệu: mọi con số đã nằm trong mã nguồn đang chạy
@Injectable()
export class GioiHanService {
  constructor(private readonly config: ConfigService) {}

  danhSach(): NhomGioiHan[] {
    const hanPhien = this.config.get<string>('jwt.expiresIn') ?? '';
    return [...nhomNenTang(hanPhien), ...nhomVanHanh()];
  }
}
