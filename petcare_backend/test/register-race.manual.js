/*
 * KIEM THU TUONG TRANH (race condition) cho POST /auth/register
 * 
 */
const URL = 'http://localhost:3000/api/v1/auth/register';

let pc = Number(String(Date.now()).slice(-7));
function nextPhone() {
  pc += 1;
  return '09' + String(pc).padStart(8, '0'); 
}
let ec = 0;
function nextEmail(tag) {
  ec += 1;
  return `race_${tag}_${ec}_${Date.now()}@example.com`;
}

async function register(payload, label) {
  const t0 = Date.now();
  try {
    const res = await fetch(URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const body = await res.json().catch(() => ({}));
    return {
      label,
      status: res.status,
      code: body.code ?? '-',
      message: Array.isArray(body.message) ? body.message[0] : body.message,
      ms: Date.now() - t0,
    };
  } catch (e) {
    return { label, status: 0, error: e.message };
  }
}

async function scenario(name, users) {
  console.log(`\n===== ${name} =====`);
  // Promise.all, ca 3 request duoc khoi tao cung mot nhip roi moi cho ket qua
  const results = await Promise.all(
    users.map((u, i) => register(u, `user${i + 1}`)),
  );
  for (const r of results) console.log('  ' + JSON.stringify(r));

  const soThanhCong = results.filter(
    (r) => r.status === 201 || r.status === 200,
  ).length;
  const so500 = results.filter((r) => r.status === 500).length;
  const loiThieuCode = results.filter(
    (r) => r.status >= 400 && r.status < 500 && (r.code === '-' || !r.code),
  ).length;
  const pass = so500 === 0 && loiThieuCode === 0 && soThanhCong >= 1;
  console.log(
    `  => ${pass ? 'PASS' : 'FAIL'} (thanh cong=${soThanhCong}, loi 500=${so500}, thua thieu code=${loiThieuCode})`,
  );
  return pass;
}

(async () => {
  const ketQua = [];

  const e1 = nextEmail('sameEmail');
  ketQua.push(
    await scenario('1) 3 user CUNG email, KHAC phone', [
      { fullName: 'U1', email: e1, phone: nextPhone(), password: 'Test@1234' },
      { fullName: 'U2', email: e1, phone: nextPhone(), password: 'Test@1234' },
      { fullName: 'U3', email: e1, phone: nextPhone(), password: 'Test@1234' },
    ]),
  );

  const e2 = nextEmail('sameBoth');
  const p2 = nextPhone();
  ketQua.push(
    await scenario('2) 3 user CUNG email, CUNG phone', [
      { fullName: 'U1', email: e2, phone: p2, password: 'Test@1234' },
      { fullName: 'U2', email: e2, phone: p2, password: 'Test@1234' },
      { fullName: 'U3', email: e2, phone: p2, password: 'Test@1234' },
    ]),
  );

  const p3 = nextPhone();
  ketQua.push(
    await scenario('3) 3 user KHAC email, CUNG phone', [
      { fullName: 'U1', email: nextEmail('samePhone'), phone: p3, password: 'Test@1234' },
      { fullName: 'U2', email: nextEmail('samePhone'), phone: p3, password: 'Test@1234' },
      { fullName: 'U3', email: nextEmail('samePhone'), phone: p3, password: 'Test@1234' },
    ]),
  );

  const tatCaPass = ketQua.every(Boolean);
  console.log(`\n===== TONG KET: ${tatCaPass ? 'PASS' : 'FAIL'} =====`);
  process.exit(tatCaPass ? 0 : 1);
})();
