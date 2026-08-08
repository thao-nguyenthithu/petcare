import { useEffect, useState, type FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { Navigate, useLocation, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Clock } from 'lucide-react';
import { authApi } from '@/features/auth/api/auth-api';
import { AuthLayout } from '@/features/auth/components/auth-layout';
import { MIN_PASSWORD_LENGTH, RESET_TOKEN_TTL_SECONDS } from '@/features/auth/auth-constants';
import { formatCountdown, useCountdown } from '@/features/auth/hooks/use-countdown';
import { Button } from '@/components/ui/button';
import { Field } from '@/components/ui/field';
import { PasswordInput } from '@/components/ui/password-input';
import { getErrorCode, isNetworkError } from '@/lib/api/client';
import { notify } from '@/lib/toast';
import { PATHS } from '@/routes/paths';

export function ResetPasswordScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  const resetToken = (location.state as { resetToken?: string } | null)?.resetToken ?? null;

  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [passwordError, setPasswordError] = useState<string | null>(null);
  const [confirmError, setConfirmError] = useState<string | null>(null);

  const hanDung = useCountdown(RESET_TOKEN_TTL_SECONDS);

  useEffect(() => {
    hanDung.start(RESET_TOKEN_TTL_SECONDS);
  }, [hanDung]);

  const datLai = useMutation({
    mutationFn: () => authApi.resetPassword(resetToken!, password),
    onSuccess: () => {
      notify.success(t('auth.datLaiThanhCong'));
      void navigate(PATHS.login, { replace: true });
    },
    onError: (error) => {
      if (isNetworkError(error)) {
        notify.error(t('auth.loi.matMang'));
        return;
      }
      if (getErrorCode(error) === 'RESET_TOKEN_INVALID') {
        notify.error(t('auth.loi.resetTokenHetHan'));
        void navigate(PATHS.forgotPassword, { replace: true });
        return;
      }
      notify.error(t('chung.khongTaiDuocDuLieu'));
    },
  });

  const guiForm = (event: FormEvent) => {
    event.preventDefault();
    setPasswordError(null);
    setConfirmError(null);

    const loiMatKhau = password.length < MIN_PASSWORD_LENGTH ? t('auth.loi.matKhauNgan') : null;
    const loiNhapLai = password !== confirm ? t('auth.loi.matKhauKhongKhop') : null;
    if (loiMatKhau) setPasswordError(loiMatKhau);
    if (loiNhapLai) setConfirmError(loiNhapLai);
    if (loiMatKhau || loiNhapLai) return;

    datLai.mutate();
  };

  if (!resetToken) return <Navigate to={PATHS.forgotPassword} replace />;

  return (
    <AuthLayout>
      <h2 className="text-h1">{t('auth.datLai.tieuDe')}</h2>
      <p className="mt-block text-body text-text-secondary">{t('auth.datLai.moTa')}</p>

      <form onSubmit={guiForm} className="mt-block flex flex-col gap-block" noValidate>
        <Field label={t('auth.datLai.matKhauMoi')} error={passwordError ?? undefined}>
          <PasswordInput
            autoComplete="new-password"
            value={password}
            hasError={Boolean(passwordError)}
            onChange={(event) => {
              setPassword(event.target.value);
              setPasswordError(null);
            }}
          />
        </Field>

        <Field label={t('auth.datLai.nhapLai')} error={confirmError ?? undefined}>
          <PasswordInput
            autoComplete="new-password"
            value={confirm}
            hasError={Boolean(confirmError)}
            onChange={(event) => {
              setConfirm(event.target.value);
              setConfirmError(null);
            }}
          />
        </Field>

        <span className="flex items-center gap-text text-caption-sm text-text-secondary">
          <Clock className="h-[15px] w-[15px]" strokeWidth={1.8} />
          {t('auth.datLai.conLai', { time: formatCountdown(hanDung.secondsLeft) })}
        </span>

        <Button type="submit" className="w-full" loading={datLai.isPending}>
          {t('auth.datLai.nut')}
        </Button>
      </form>
    </AuthLayout>
  );
}
