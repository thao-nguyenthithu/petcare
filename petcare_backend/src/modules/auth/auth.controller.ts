import {
  Body,
  Controller,
  Get,
  Patch,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { CAU_HINH_ANH, type UploadedImage } from '../media/image-upload';
import { AccountService } from './account.service';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { FirebaseAuthDto } from './dto/firebase-auth.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { UpdateMeDto } from './dto/update-me.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { VerifyResetOtpDto } from './dto/verify-reset-otp.dto';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly account: AccountService,
  ) {}

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

  @Post('forgot-password')
  @ApiOperation({
    summary:
      'Gửi OTP đặt lại mật khẩu về email. scope admin chỉ nhận tài khoản ADMIN và luôn trả cùng một câu',
  })
  forgotPassword(@Body() dto: ForgotPasswordDto) {
    return this.account.forgotPassword(dto.email, dto.scope);
  }

  @Post('verify-reset-otp')
  @ApiOperation({ summary: 'Xác minh OTP quên mật khẩu, trả về resetToken' })
  verifyResetOtp(@Body() dto: VerifyResetOtpDto) {
    return this.account.verifyResetOtp(dto.email, dto.otp, dto.scope);
  }

  @Post('reset-password')
  @ApiOperation({ summary: 'Đặt mật khẩu mới bằng resetToken' })
  resetPassword(@Body() dto: ResetPasswordDto) {
    return this.account.resetPassword(dto.resetToken, dto.newPassword);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Lấy thông tin user hiện tại' })
  getMe(@CurrentUser() user: { id: string }) {
    return this.account.getMe(user.id);
  }

  @Patch('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Sửa hồ sơ cá nhân: tên, số điện thoại, ngày sinh' })
  capNhatHoSo(@CurrentUser() user: { id: string }, @Body() dto: UpdateMeDto) {
    return this.account.capNhatHoSo(user.id, dto);
  }

  @Post('me/avatar')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Đổi ảnh đại diện của tài khoản đang đăng nhập' })
  @UseInterceptors(FileInterceptor('file', CAU_HINH_ANH))
  uploadAvatar(
    @CurrentUser() user: { id: string },
    @UploadedFile() file: UploadedImage,
  ) {
    return this.account.uploadAvatar(user.id, file);
  }
}
