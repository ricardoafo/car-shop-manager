export const adminFixture = {
  credentials: {
    email: process.env['TEST_ADMIN_EMAIL'] ?? 'admin@rbr-test.local',
    password: process.env['TEST_ADMIN_PASSWORD'] ?? 'TestPassword123!',
  },
} as const;
