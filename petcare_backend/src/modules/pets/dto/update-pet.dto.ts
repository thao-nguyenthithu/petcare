import { PartialType } from '@nestjs/swagger';
import { CreatePetDto } from './create-pet.dto';

// Sửa hồ sơ bé
export class UpdatePetDto extends PartialType(CreatePetDto) {}
