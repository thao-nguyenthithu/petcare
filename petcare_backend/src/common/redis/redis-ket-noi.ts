import { ConfigService } from '@nestjs/config';

export type TuyChonRedis = {
  host: string;
  port: number;
  username?: string;
  password?: string;
  family?: number;
  tls?: { rejectUnauthorized: boolean };
};

export function tuyChonRedis(config: ConfigService): TuyChonRedis {
  const chuoi = config.get<string>('redis.url');
  if (!chuoi) {
    return {
      host: config.get<string>('redis.host') ?? '127.0.0.1',
      port: config.get<number>('redis.port') ?? 6379,
      family: 4,
    };
  }
  const dia = new URL(chuoi);
  return {
    host: dia.hostname,
    port: Number(dia.port) || 6379,
    username: decodeURIComponent(dia.username) || undefined,
    password: decodeURIComponent(dia.password) || undefined,
    family: 0,
    ...(dia.protocol === 'rediss:'
      ? { tls: { rejectUnauthorized: true } }
      : {}),
  };
}
