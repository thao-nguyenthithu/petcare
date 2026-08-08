import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';

// Đúng hình dạng GET /admin/settings trả về, chỉ giữ các khoá màn thật sự đọc
export const THAM_SO_VAN_HANH = {
  capNhatLuc: '2026-08-06T03:00:00.000Z',
  items: [
    {
      key: 'dispute.support_days',
      nhan: 'Chỉ tiêu kết luận một khiếu nại',
      kieu: 'so',
      donVi: 'ngay',
      giaTri: 7,
      macDinh: 7,
      min: 1,
      max: 30,
      luaChon: null,
      nguoiDoi: null,
      capNhatLuc: null,
    },
    {
      key: 'search.radius_max_km',
      nhan: 'Bán kính tìm kiếm tối đa',
      kieu: 'so',
      donVi: 'km',
      giaTri: 15,
      macDinh: 15,
      min: 5,
      max: 50,
      luaChon: null,
      nguoiDoi: null,
      capNhatLuc: null,
    },
  ],
};

// Chỉ khai sẵn tham số vận hành vì nhiều màn đọc chung; API nghiệp vụ thì mỗi test tự nói
export const server = setupServer(
  http.get('*/admin/settings', () => HttpResponse.json(THAM_SO_VAN_HANH)),
);
