import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../../../prisma/prisma.service';

export interface JwtPayload {
  sub: string;
  email: string;
  role: string;
  iat?: number;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    config: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.get<string>('jwt.secret') as string,
    });
  }

  async validate(payload: JwtPayload) {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: { passwordChangedAt: true, isActive: true },
    });
    if (!user?.isActive) {
      throw new UnauthorizedException({
        code: 'TAI_KHOAN_KHONG_HOAT_DONG',
        message: 'Tài khoản không còn hoạt động',
      });
    }
    if (
      user.passwordChangedAt &&
      payload.iat !== undefined &&
      payload.iat * 1000 <= user.passwordChangedAt.getTime()
    ) {
      throw new UnauthorizedException({
        code: 'PHIEN_DA_HET_HIEU_LUC',
        message: 'Mật khẩu đã được đổi, vui lòng đăng nhập lại',
      });
    }
    return { id: payload.sub, email: payload.email, role: payload.role };
  }
}
