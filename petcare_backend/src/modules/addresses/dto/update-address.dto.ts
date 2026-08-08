import { PartialType } from '@nestjs/swagger';
import { CreateAddressDto } from './create-address.dto';

// Sửa địa chỉ
export class UpdateAddressDto extends PartialType(CreateAddressDto) {}
