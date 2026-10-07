KOTHARI HYUNDAI HRMS v5 - cPanel / Supabase / PWA

DEPLOY TO CPANEL
1. Extract this ZIP on your computer.
2. In cPanel File Manager open the target domain/subdomain document root (for example public_html or the HRMS folder).
3. Upload the CONTENTS of this folder, including .htaccess, index.html, manifest.json, sw.js and icons/.
4. Make sure index.html is directly inside the document root. Do not leave it one level deeper unless that folder is the intended URL.
5. Enable an SSL certificate for the domain/subdomain and open the site using HTTPS. PWA installation requires HTTPS (localhost is also supported for development).
6. No Node.js server is required for this package. cPanel Apache serves the static files.

SUPABASE
1. Open Supabase SQL Editor.
2. Run ONLY the single supabase.sql file included here. The previous v3/v4 SQL files have been merged and removed.
3. The frontend uses the existing Supabase URL and publishable key already configured in index.html. Do not put a Supabase service_role key in browser code.
4. Create/confirm an Auth user before signing in. Link it to a `user_profiles` row with a unique `username`; the `admin` username must have role `Super Admin`. Sign in using the username and that Auth user's password. Re-run `supabase.sql` to install the username-to-Auth-email lookup function.

PWA INSTALL
- On supported browsers, an Install App button appears when the browser fires beforeinstallprompt.
- If the button is not shown, use the browser's Install/Add to Home Screen menu. This depends on browser support and HTTPS.
- Service worker and manifest are included and cache-busted for v5.

FEATURES INCLUDED
- Employee Management
- Attendance
- Leave Management
- Payroll
- Data Import: Salary Sheet and Incentive Sheet
- Income Tax Calculator
- Recruitment
- Performance
- Employee Documents
- Month-wise and financial-year reports
- HR Administration
- Supabase database
- PWA install support

IMPORTANT
After deployment, if an older version is cached, open the browser site settings and clear the site's cached data once, then reload. The v5 service worker will remove its older HRMS cache after activation.


Version 6 update: KCPL HRMS logo and branding refresh.
Logo assets: icons/kcpl-logo.svg, icon-192.png, icon-512.png.


V7 statutory payroll update
- PF wage ceiling configured at Rs 25,000 effective 17-Sep-2026.
- Employee PF 12%, employer total PF share 12%, EPS 8.33% and EDLI 0.50% calculator included.
- Professional Tax is kept configurable rather than hard-coded to avoid using an incorrect slab.
- Run the single merged supabase.sql in Supabase SQL Editor.
