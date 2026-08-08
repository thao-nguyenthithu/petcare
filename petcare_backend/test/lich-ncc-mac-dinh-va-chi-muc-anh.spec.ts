import { readFileSync } from 'node:fs';
import { join } from 'node:path';

const schema = readFileSync(
  join(__dirname, '..', 'prisma', 'schema.prisma'),
  'utf8',
);

function khoiModel(ten: string) {
  const bd = schema.indexOf(`model ${ten} {`);
  return schema.slice(bd, schema.indexOf('\n}', bd));
}

describe('giờ làm việc mặc định của người chăm', () => {
  const sitter = khoiModel('Sitter');

  it('workStart mặc định 07:00 đúng bộ luật mục 1', () => {
    expect(sitter).toMatch(/workStart\s+String\s+@default\("07:00"\)/);
  });

  it('workEnd mặc định 20:00 đúng bộ luật mục 1', () => {
    expect(sitter).toMatch(/workEnd\s+String\s+@default\("20:00"\)/);
  });

  // Lệch một giờ so với app là chặn nhầm khung 07:00 của chủ nuôi
  it('không còn chỗ nào trong Sitter để 08:00', () => {
    expect(sitter).not.toContain('08:00');
  });
});

describe('chỉ mục bảng SessionPhoto', () => {
  const anh = khoiModel('SessionPhoto');

  // Thứ tự cột phải khớp cách truy vấn thật, đảo lại thì database bỏ qua chỉ mục
  it('lọc theo đơn rồi sắp theo giờ chụp', () => {
    expect(anh).toContain('@@index([bookingId, takenAt])');
  });

  it('danh sách quản trị sắp giờ chụp giảm dần, id là mốc phá hoà', () => {
    expect(anh).toContain('@@index([takenAt(sort: Desc), id])');
  });
});
