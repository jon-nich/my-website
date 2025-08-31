# My Website

This repository contains the classroom dashboard and QR tools.

Structure:

- `index.html` and `dashboard.html` – main pages
- `qr-attendance-app/` – QR-based attendance scanner and generator
- `standards-dashboard/` – standards calendar and dashboard
- `tests/` – small Playwright test utilities
- `tools/` – helper scripts (e.g., Netlify deploy)

Notes:

- `config.js` is intentionally ignored by Git (see `.gitignore`). Copy from `config.example.js` and set your local values.
- Netlify SPA redirect is configured in `netlify.toml`.

Live site:

- <https://polite-concha-38b3bd.netlify.app/>
