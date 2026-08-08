import { PartialType } from '@nestjs/swagger';
import { CreateDoseDto } from './create-dose.dto';

// Sửa một lần đã ghi
export class UpdateDoseDto extends PartialType(CreateDoseDto) {}
