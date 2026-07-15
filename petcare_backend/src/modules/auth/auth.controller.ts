import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { FirebaseAuthDto } from './dto/firebase-auth.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Đăng ký tài khoản mới, gửi OTP xác minh về email' })
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('verify-email')
  @ApiOperation({ summary: 'Xác minh email bằng mã OTP 6 số' })
  verifyEmail(@Body() dto: VerifyEmailDto) {
    return this.authService.verifyEmail(dto);
  }

  @Post('resend-verify-otp')
  @ApiOperation({ summary: 'Gửi lại mã xác minh email (cooldown 30 giây)' })
  resendVerifyOtp(@Body() dto: SendOtpDto) {
    return this.authService.resendVerifyOtp(dto.email);
  }

  @Post('login')
  @ApiOperation({ summary: 'Đăng nhập bằng Email/Password, trả về JWT' })
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('login/google')
  @ApiOperation({ summary: 'Đăng nhập Google (Firebase ID Token), trả về JWT' })
  loginGoogle(@Body() dto: FirebaseAuthDto) {
    return this.authService.loginWithFirebase(dto.idToken);
  }

  @Post('login/facebook')
  @ApiOperation({
    summary: 'Đăng nhập Facebook (Firebase ID Token), trả về JWT',
  })
  loginFacebook(@Body() dto: FirebaseAuthDto) {
    return this.authService.loginWithFirebase(dto.idToken);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Lấy thông tin user hiện tại' })
  getMe(@CurrentUser() user: { id: string }) {
    return this.authService.getMe(user.id);
  }
}
