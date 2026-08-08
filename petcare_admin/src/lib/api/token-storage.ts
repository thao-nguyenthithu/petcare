const ACCESS_TOKEN_KEY = 'petcare_admin.accessToken';

// Ghi nhớ đăng nhập
export const tokenStorage = {
  get(): string | null {
    return localStorage.getItem(ACCESS_TOKEN_KEY) ?? sessionStorage.getItem(ACCESS_TOKEN_KEY);
  },
  set(token: string, remember: boolean): void {
    this.clear();
    const store = remember ? localStorage : sessionStorage;
    store.setItem(ACCESS_TOKEN_KEY, token);
  },
  clear(): void {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    sessionStorage.removeItem(ACCESS_TOKEN_KEY);
  },
};
