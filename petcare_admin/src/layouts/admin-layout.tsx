import { Outlet } from 'react-router-dom';
import { Sidebar } from '@/layouts/sidebar';
import { Topbar } from '@/layouts/topbar';

export function AdminLayout() {
  return (
    <div className="flex h-screen overflow-hidden">
      <Sidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        <Topbar />
        <main className="flex-1 overflow-y-auto bg-canvas px-section pb-block pt-[18px] [scrollbar-gutter:stable]">
          <div className="mx-auto w-full max-w-content">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}
