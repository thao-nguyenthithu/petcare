import { useEffect, useState, type FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, Navigate, useLocation, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Clock } from 'lucide-react';
import { authApi } from '@/features/auth/api/auth-api';
import { AuthLayout } from '@/features/auth/components/auth-layout';
import { OtpInput } from '@/features/auth/components/otp-input';
import {
  OTP_LENGTH,
  OTP_MAX_ATTEMPTS,
  RESEND_COOLDOWN_SECONDS,
} from '@/features/auth/auth-constants';
import { formatCountdown, useCountdown } from '@/features/auth/hooks/use-countdown';
import { Button } from '@/components/ui/button';
import { FieldError } from '@/components/ui/field';
import { getErrorCode, getErrorMeta, isNetworkError } from '@/lib/api/client';
import { notify } from '@/lib/toast';
import { PATHS } from '@/routes/paths';

type OtpLockedMeta = { minutes: number; seconds: number };

export function VerifyOtpScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const email = (location.state as { email?: string } | null)?.email ?? null;

  const [otp, setOtp] = useState('');
  const [otpError, setOtpError] = useState<string | null>(null);
  const [soLanConLai, setSoLanConLai] = useState(OTP_MAX_ATTEMPTS);

  const cooldown = useCountdown(RESEND_COOLDOWN_SECONDS);
  const khoa = useCountdown(0);
  const dangBiKhoa = khoa.secondsLeft > 0;

  useEffect(() => {
    cooldown.start(RESEND_COOLDOWN_SECONDS);
  }, [cooldown]);

  const xacMinh = useMutation({
    mutationFn: () => authApi.verifyResetOtp(email!, otp),
    onSuccess: (resetToken) => {
      void navigate(PATHS.resetPassword, { replace: true, state: { resetToken } });
    },
    onError: (error) => {
      if (isNetworkError(error)) {
        notify.error(t('auth.loi.matMang'));
        return;
      }
      const code = getErrorCode(error);
      if (code === 'OTP_EXPIRED') {
        setOtpError(t('auth.loi.otpHetHan'));
        return;
      }
      if (code === 'OTP_LOCKED') {
        const meta = getErrorMeta<OtpLockedMeta>(error);
        setOtpError(t('auth.loi.otpKhoa', { count: meta?.minutes ?? 5 }));
        khoa.start(meta?.seconds ?? 300);
        setSoLanConLai(0);
        return;
      }
      const conLai = Math.max(soLanConLai - 1, 0);
      setSoLanConLai(conLai);
      setOtpError(t('auth.loi.otpSai', { count: conLai }));
    },
  });

  const guiLai = useMutation({
    mutationFn: () => authApi.forgotPassword(email!),
    onSuccess: () => {
      cooldown.start(RESEND_COOLDOWN_SECONDS);
      setOtp('');
      setOtpError(null);
      setSoLanConLai(OTP_MAX_ATTEMPTS);
    },
    onError: (error) => {
      if (isNetworkError(error)) {
        notify.error(t('auth.loi.matMang'));
        return;
      }
      if (getErrorCode(error) === 'OTP_COOLDOWN') {
        notify.error(t('auth.loi.otpCooldown'));
        cooldown.start(RESEND_COOLDOWN_SECONDS);
      }
    },
  });

  const guiForm = (event: FormEvent) => {
    event.preventDefault();
    setOtpError(null);

    if (otp.length < OTP_LENGTH) {
      setOtpError(t('auth.loi.otpThieuSo'));
      return;
    }
    xacMinh.mutate();
  };

  if (!email) return <Navigate to={PATHS.forgotPassword} replace />;

  return (
    <AuthLayout>
      <h2 className="text-h1">{t('auth.nhapMa.tieuDe')}</h2>
      <p className="mt-block text-body text-text-secondary">{t('auth.nhapMa.moTa', { email })}</p>

      <form onSubmit={guiForm} className="mt-block flex flex-col gap-block" noValidate>
        <div className="flex flex-col gap-label">
          <span className="text-label-sm uppercase tracking-[0.02em] text-text-primary">
            {t('auth.nhapMa.nhan')}
          </span>
          <OtpInput
            value={otp}
            onChange={(value) => {
              setOtp(value);
              setOtpError(null);
            }}
            disabled={dangBiKhoa}
            hasError={Boolean(otpError)}
          />
          {otpError ? <FieldError message={otpError} /> : null}
        </div>

        <div className="flex items-center justify-between gap-item">
          {dangBiKhoa ? (
            <span className="flex items-center gap-text text-caption-sm text-text-secondary">
              <Clock className="h-[15px] w-[15px]" strokeWidth={1.8} />
              {t('auth.nhapMa.thuLaiSau', { time: formatCountdown(khoa.secondsLeft) })}
            </span>
          ) : cooldown.secondsLeft > 0 ? (
            <span className="flex items-center gap-text text-caption-sm text-text-secondary">
              <Clock className="h-[15px] w-[15px]" strokeWidth={1.8} />
              {t('auth.nhapMa.guiLaiSau', { time: formatCountdown(cooldown.secondsLeft) })}
            </span>
          ) : (
            <button
              type="button"
              onClick={() => guiLai.mutate()}
              disabled={guiLai.isPending}
              className="text-label text-primary hover:underline"
            >
              {t('auth.nhapMa.guiLai')}
            </button>
          )}

          <Link to={PATHS.forgotPassword} className="text-label text-primary hover:underline">
            {t('auth.nhapMa.doiEmail')}
          </Link>
        </div>

        <Button type="submit" className="w-full" loading={xacMinh.isPending} disabled={dangBiKhoa}>
          {t('auth.nhapMa.nut')}
        </Button>
      </form>
    </AuthLayout>
  );
}
