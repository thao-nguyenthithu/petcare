import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class FirebaseAuthDto {
  @ApiProperty({
    description:
      'Firebase ID Token do Flutter lấy về sau khi đăng nhập Google/Facebook',
  })
  @IsString({ message: 'idToken không hợp lệ' })
  @IsNotEmpty({ message: 'Thiếu idToken' })
  idToken!: string;
}
