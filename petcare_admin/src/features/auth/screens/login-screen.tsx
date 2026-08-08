import { useState, type FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, Navigate, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { Mail } from 'lucide-react';
import { authApi } from '@/features/auth/api/auth-api';
import { AuthLayout } from '@/features/auth/components/auth-layout';
import { validateEmail } from '@/features/auth/auth-constants';
import { useSetCurrentAdmin } from '@/features/auth/hooks/use-current-admin';
import { Button } from '@/components/ui/button';
import { Field, TextInput } from '@/components/ui/field';
import { PasswordInput } from '@/components/ui/password-input';
import { getErrorCode, getErrorMessage, getErrorStatus, isNetworkError } from '@/lib/api/client';
import { tokenStorage } from '@/lib/api/token-storage';
import { notify } from '@/lib/toast';
import { PATHS } from '@/routes/paths';

export function LoginScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const setCurrentAdmin = useSetCurrentAdmin();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [remember, setRemember] = useState(true);
  const [emailError, setEmailError] = useState<string | null>(null);
  const [passwordError, setPasswordError] = useState<string | null>(null);

  const dangNhap = useMutation({
    mutationFn: async () => {
      const { accessToken } = await authApi.login(email.trim().toLowerCase(), password);
      tokenStorage.set(accessToken, remember);
      return authApi.getMe();
    },
    onSuccess: (user) => {
      if (user.role !== 'ADMIN') {
        tokenStorage.clear();
        setPasswordError(t('auth.loi.khongPhaiAdmin'));
        return;
      }
      setCurrentAdmin(user);
      void navigate(PATHS.dashboard, { replace: true });
    },
    onError: (error) => {
      tokenStorage.clear();
      if (isNetworkError(error)) {
        notify.error(t('auth.loi.matMang'));
        return;
      }
      const code = getErrorCode(error);
      if (code === 'EMAIL_NOT_VERIFIED') {
        notify.error(t('auth.loi.chuaXacMinh'));
        return;
      }
      if (code === 'INVALID_CREDENTIALS' || getErrorStatus(error) === 401) {
        setPasswordError(t('auth.loi.saiThongTin'));
        return;
      }
      notify.error(getErrorMessage(error, t('chung.khongTaiDuocDuLieu')));
    },
  });

  const guiForm = (event: FormEvent) => {
    event.preventDefault();
    setEmailError(null);
    setPasswordError(null);

    const loiEmail = validateEmail(email);
    const loiMatKhau = password ? null : 'auth.loi.matKhauTrong';
    if (loiEmail) setEmailError(t(loiEmail));
    if (loiMatKhau) setPasswordError(t(loiMatKhau));
    if (loiEmail || loiMatKhau) return;

    dangNhap.mutate();
  };

  if (tokenStorage.get() && !dangNhap.isPending) {
    return <Navigate to={PATHS.dashboard} replace />;
  }

  return (
    <AuthLayout>
      <h2 className="text-h1">{t('auth.dangNhap.tieuDe')}</h2>
      <p className="mt-block text-body text-text-secondary">{t('auth.dangNhap.moTa')}</p>

      <form onSubmit={guiForm} className="mt-block flex flex-col gap-block" noValidate>
        <Field label={t('auth.dangNhap.email')} error={emailError ?? undefined}>
          <TextInput
            type="email"
            autoComplete="email"
            leadingIcon={Mail}
            value={email}
            hasError={Boolean(emailError)}
            onChange={(event) => {
              setEmail(event.target.value);
              setEmailError(null);
            }}
          />
        </Field>

        <Field label={t('auth.dangNhap.matKhau')} error={passwordError ?? undefined}>
          <PasswordInput
            autoComplete="current-password"
            value={password}
            hasError={Boolean(passwordError)}
            onChange={(event) => {
              setPassword(event.target.value);
              setPasswordError(null);
            }}
          />
        </Field>

        <div className="flex items-center justify-between gap-item">
          <label className="flex cursor-pointer items-center gap-label text-label font-normal">
            <input
              type="checkbox"
              checked={remember}
              onChange={(event) => setRemember(event.target.checked)}
              className="h-5 w-5 rounded-[6px] accent-primary"
            />
            {t('auth.dangNhap.ghiNho')}
          </label>
          <Link to={PATHS.forgotPassword} className="text-label text-primary hover:underline">
            {t('auth.dangNhap.quenMatKhau')}
          </Link>
        </div>

        <Button type="submit" className="w-full" loading={dangNhap.isPending}>
          {t('auth.dangNhap.nut')}
        </Button>
      </form>
    </AuthLayout>
  );
}
