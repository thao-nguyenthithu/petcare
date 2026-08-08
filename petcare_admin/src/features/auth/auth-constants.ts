export const OTP_LENGTH = 6;
export const OTP_MAX_ATTEMPTS = 5;
export const RESEND_COOLDOWN_SECONDS = 30;
export const RESET_TOKEN_TTL_SECONDS = 10 * 60;
export const MIN_PASSWORD_LENGTH = 6;

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function validateEmail(value: string): string | null {
  const email = value.trim();
  if (!email) return 'auth.loi.emailTrong';
  if (!EMAIL_PATTERN.test(email)) return 'auth.loi.emailSaiDinhDang';
  return null;
}
