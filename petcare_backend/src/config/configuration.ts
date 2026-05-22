export default () => ({
  port: parseInt(process.env.PORT ?? '3000', 10),

  database: {
    url: process.env.DATABASE_URL,
  },

  jwt: {
    secret:    process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },

  supabase: {
    url:        process.env.SUPABASE_URL,
    serviceKey: process.env.SUPABASE_SERVICE_KEY,
  },

  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID,
  },

  ai: {
    activeProvider:  process.env.ACTIVE_AI_PROVIDER || 'anthropic',
    anthropicApiKey: process.env.ANTHROPIC_API_KEY,
    openaiApiKey:    process.env.OPENAI_API_KEY,
  },

  google: {
    clientId:     process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  },

  facebook: {
    appId:     process.env.FACEBOOK_APP_ID,
    appSecret: process.env.FACEBOOK_APP_SECRET,
  },

  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT ?? '6379', 10),
  },
});
