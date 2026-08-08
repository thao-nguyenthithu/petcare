import { useState, type FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import { ChevronLeft, Mail } from 'lucide-react';
import { authApi } from '@/features/auth/api/auth-api';
import { AuthLayout } from '@/features/auth/components/auth-layout';
import { validateEmail } from '@/features/auth/auth-constants';
import { Button } from '@/components/ui/button';
import { Field, TextInput } from '@/components/ui/field';
import { getErrorCode, isNetworkError } from '@/lib/api/client';
import { notify } from '@/lib/toast';
import { PATHS } from '@/routes/paths';

export function ForgotPasswordScreen() {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const [email, setEmail] = useState('');
  const [emailError, setEmailError] = useState<string | null>(null);

  const guiMa = useMutation({
    mutationFn: (value: string) => authApi.forgotPassword(value),
    onSuccess: (_data, value) => {
      void navigate(PATHS.verifyOtp, { state: { email: value } });
    },
    onError: (error) => {
      if (isNetworkError(error)) {
        notify.error(t('auth.loi.matMang'));
        return;
      }
      if (getErrorCode(error) === 'OTP_COOLDOWN') {
        notify.error(t('auth.loi.otpCooldown'));
        return;
      }
      notify.error(t('chung.khongTaiDuocDuLieu'));
    },
  });

  const guiForm = (event: FormEvent) => {
    event.preventDefault();
    setEmailError(null);

    const loi = validateEmail(email);
    if (loi) {
      setEmailError(t(loi));
      return;
    }
    guiMa.mutate(email.trim().toLowerCase());
  };

  return (
    <AuthLayout>
      <h2 className="text-h1">{t('auth.quenMatKhau.tieuDe')}</h2>
      <p className="mt-block text-body text-text-secondary">{t('auth.quenMatKhau.moTa')}</p>

      <form onSubmit={guiForm} className="mt-block flex flex-col gap-block" noValidate>
        <Field
          label={t('auth.quenMatKhau.email')}
          error={emailError ?? undefined}
          hint={t('auth.quenMatKhau.nhac')}
        >
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

        <Button type="submit" className="w-full" loading={guiMa.isPending}>
          {t('auth.quenMatKhau.nut')}
        </Button>

        <Link
          to={PATHS.login}
          className="flex items-center justify-center gap-text text-label text-primary hover:underline"
        >
          <ChevronLeft className="h-[15px] w-[15px]" strokeWidth={2} />
          {t('auth.quenMatKhau.quayLai')}
        </Link>
      </form>
    </AuthLayout>
  );
}
