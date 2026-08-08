import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { NccDaDuyet } from '../guards/sitter.guard';

export const NccHienTai = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): NccDaDuyet => {
    const request = ctx.switchToHttp().getRequest<{ sitter: NccDaDuyet }>();
    return request.sitter;
  },
);
