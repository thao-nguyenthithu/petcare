import { ArrayNotEmpty, IsArray, IsString } from 'class-validator';

// Xoá 1 hoặc nhiều ảnh trong thư viện NCC
export class DeletePhotosDto {
  @IsArray({ message: 'Danh sách ảnh không hợp lệ' })
  @ArrayNotEmpty({ message: 'Thiếu ảnh cần xoá' })
  @IsString({ each: true })
  ids!: string[];
}
