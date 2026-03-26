# Client vs Server Validation

Validation, Authentication or Verification applies to most web & mobile apps:

- Client-side validation (UI)
  - Purpose: improve user experience by catching simple mistakes4 early.
  - Typical checks: required fields, email format, password confirmation, simple length/format checks.
  - NOT authoritative: users can bypass client checks (bad actors, automated requests).

- Server-side validation (Backend)
  - Purpose: authoritative enforcement of correctness and security.
  - Required checks: presence of required fields, canonicalization (trim, lowercase emails), type checking, uniqueness (email), password strength policy, input sanitization.
  - Security: always validate and sanitize on server; hash passwords; do not trust client-provided data for access control.

- Who handles what?
  - UI: immediate feedback and UX responsibilities (show friendly messages, reduce round-trips).
  - Backend: enforce rules, authenticate, authorize, and persist data. Backend responses should be machine-friendly (error codes) and user-friendly messages can be mapped by UI.

- Error format recommendation (JSON):
  ```json
  { "error": "email_exists", "message": "Email already registered" }
  {
    "errors": [ { "field": "password", "code": "too_short", "message": "Password must be at least 6 characters" } ]
  }
  ```

- Notes for MVP vs Production:
  - MVP: in-memory stores + simple tokens are acceptable for local dev and tests, but hash passwords (bcrypt) even for MVP.
  - Production: use secure token issuance (JWT or session store), rate-limiting, email verification, and robust password policy.

- Quick checklist to implement:
  - [ ] Client: required-field checks, email pattern, password confirmation
  - [ ] Backend: validate required fields, check email uniqueness, hash passwords, return structured errors

Created for Project Pet Care — March 2026
