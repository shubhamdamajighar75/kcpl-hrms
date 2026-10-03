KOTHARI HYUNDAI HRMS v2
=========================

FILES
-----
index.html     Frontend. Replace Supabase URL + publishable/anon key.
supabase.sql   Database schema, RLS, seed masters and document bucket.
README.txt     Setup instructions.

SUPABASE
--------
1. Create a Supabase project.
2. SQL Editor -> paste/run supabase.sql.
3. Authentication -> create the first admin user.
4. Copy that Auth user's UUID.
5. Run the commented user_profiles INSERT at the bottom of supabase.sql using the UUID.
6. Open index.html and set:
   SUPABASE_URL
   SUPABASE_KEY
7. Upload index.html to cPanel public_html (or deploy as a static site).

IMPORTANT SECURITY
------------------
Never put the Supabase service_role/secret key in frontend HTML.
Use the browser-safe publishable/anon key and RLS.

NEXT PRODUCTION STEPS
---------------------
- Add Excel import using SheetJS or server-side validation.
- Add Supabase Storage upload UI with file type/size validation.
- Add salary-slip PDF generation.
- Add complete CRUD for departments/designations/branches.
- Add stricter branch-level RLS based on branch_id instead of display branch name.
- Add audit triggers for sensitive HR/payroll changes.
