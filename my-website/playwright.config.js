module.exports = {
  testDir: 'tests',
  timeout: 30000,
  expect: {
    timeout: 5000
  },
  reporter: 'html',
  use: {
    headless: true,
    browserName: 'chromium'
  },
  projects: [
    {
      name: 'Chromium',
      use: { browserName: 'chromium' }
    },
    {
      name: 'Firefox',
      use: { browserName: 'firefox' }
    },
    {
      name: 'WebKit',
      use: { browserName: 'webkit' }
    }
  ]
};