import { IsIn, IsInt, Min } from 'class-validator';

// Hai nút của màn giả lập cổng thanh toán
export class MockPayDto {
  @IsIn(['success', 'fail'])
  ketQua!: 'success' | 'fail';

  @IsInt()
  @Min(0)
  soTien!: number;
}
