export default () => ({
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  },

  supabase: {
    url: process.env.SUPABASE_URL,
    serviceKey: process.env.SUPABASE_SERVICE_KEY,
  },

  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  },

  mail: {
    user: process.env.MAIL_USER,
    appPassword: process.env.MAIL_APP_PASSWORD?.replace(/\s/g, ''),
  },

  ai: {
    anthropicApiKey: process.env.ANTHROPIC_API_KEY,
    geminiApiKey: process.env.GEMINI_API_KEY,
  },

  redis: {
    url: process.env.REDIS_URL,
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
  },

  payment: {
    gateway: process.env.PAYMENT_GATEWAY || 'mock',
    vnpay: {
      tmnCode: process.env.VNPAY_TMN_CODE ?? '',
      hashSecret: process.env.VNPAY_HASH_SECRET ?? '',
      payUrl:
        process.env.VNPAY_PAY_URL ||
        'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
      returnUrl:
        process.env.VNPAY_RETURN_URL ||
        'http://localhost:3000/api/v1/payments/vnpay/return',
    },
  },
});
