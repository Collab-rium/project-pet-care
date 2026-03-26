# JWT Explained for Project Pet Care

This file explains JWT in simple terms and how we use it in this project.

## 1) JWT Basics

JWT means JSON Web Token.

It is a string like this:

header.payload.signature

Example:

eyJ...abc.eyJ...xyz.SflK...123

- `header`: token type and algorithm (for us: HS256)
- `payload`: data (called claims), like user id and expiry time
- `signature`: proof that the token was created by our backend secret

Important:
- JWT payload is encoded, not encrypted. Do not put private secrets inside payload.
- Security comes from the signature, not from hiding payload text.

## 2) Why We Need JWT

We need a way to know who is calling protected APIs like `GET /pets`.

JWT gives us this:
- User logs in once
- Backend returns token
- Frontend sends token in `Authorization: Bearer <jwt>`
- Backend verifies token and gets user id from it

Benefits:
- Standard approach used by most APIs
- Stateless verification (no separate token map required)
- Built-in expiry (`exp`) claim

## 3) How JWT Is Used In This Project

Current auth flow:

1. `POST /auth/register` or `POST /auth/login`
2. Backend creates signed JWT with claims like:
   - `sub`: user id
   - `email`: user email
   - `iat`: issued-at time
   - `exp`: expiry time
3. Backend returns:

```json
{
  "user": {
    "id": "...",
    "email": "...",
    "name": "...",
    "createdAt": "..."
  },
  "token": "eyJ..."
}
```

4. Frontend stores token safely (secure storage recommended)
5. Frontend calls protected endpoints with header:

```http
Authorization: Bearer <jwt>
```

6. `authMiddleware` verifies JWT and sets `req.user`
7. Protected route runs only if token is valid

## 4) What Changed (Before vs Now)

Before:
- Backend created random UUID tokens
- Tokens were stored in memory map (`token -> userId`)
- Middleware checked token by map lookup
- If server restarted, old tokens died (memory lost)

Now:
- Backend signs JWT using `JWT_SECRET`
- Middleware verifies JWT signature + expiry
- User id comes from `sub` claim
- No separate in-memory token map needed

What did NOT change:
- Client still sends `Authorization: Bearer <token-like-string>`
- Register/login endpoints are same URLs

## 5) JWT_SECRET: What It Is and Why It Matters

`JWT_SECRET` is the signing key for HS256 JWT.

If leaked, anyone can generate valid fake tokens.

So:
- Keep it in `backend/.env` only
- Never commit real secret to git
- Use long random value

Why it must be private (very important):
- Think of `JWT_SECRET` like your backend's stamp/seal.
- The backend uses this seal to mark tokens as "real".
- If attackers steal the seal, they can create fake tokens that look real.
- Then they can impersonate any user by setting `sub` to someone else's user id.

Example attack if secret leaks:
1. Attacker gets `JWT_SECRET`.
2. Attacker creates a JWT with payload like `{ "sub": "admin-or-any-user-id" }`.
3. Attacker signs it with leaked secret.
4. Your backend accepts it as valid unless other controls exist.

That is why secret handling is non-negotiable:
- Keep secret out of git.
- Rotate secret if you suspect leakage.
- Use short expiry tokens to limit damage window.

## 6) How To Set It Up

1. Generate strong secret:

```bash
openssl rand -hex 32
```

Important notes about this command:
- It returns a different value every time. This is expected and correct.
- Pick one generated value and keep using that same value in `backend/.env`.
- If you change `JWT_SECRET` later, previously issued JWTs will stop working (they become invalid).

Is it okay to share this value?
- Treat it like a password.
- Do not post it in public chat, screenshots, commits, issues, or logs.
- If you accidentally share it, rotate immediately: generate a new one, replace in `.env`, restart backend.

If `openssl` is not available, use Node:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

2. Put it in `backend/.env`:

```env
PORT=4000
FIRESTORE_EMULATOR_HOST=localhost:8080
FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
JWT_SECRET=PASTE_GENERATED_SECRET_HERE
```

3. Restart backend:

```bash
cd backend
npm start
```

## 6.1) Setup Status (Right Now)

Auth code is implemented and working (register/login + JWT verification middleware), but local setup still has one important step:

- `backend/auth.js` already uses JWT signing/verification.
- `backend/.env.example` includes `JWT_SECRET`.
- Your local `backend/.env` must also include `JWT_SECRET=<your-random-secret>`.

If `JWT_SECRET` is missing in `.env`, code currently falls back to a dev default string (`dev_jwt_secret_change_me`). This is okay only for quick local development, not for real/shared environments.

So the recommended final step is:
1. Add real random `JWT_SECRET` to `backend/.env`
2. Restart backend
3. Re-test register/login + protected route

## 7) How To Test JWT End-to-End

### A) Register and get token

```bash
curl -s -X POST http://localhost:4000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"jwtflow@example.com","password":"test123","name":"JWT Flow"}'
```

Copy `token` from response.

### B) Use token on protected endpoint

```bash
TOKEN="paste_token_here"
curl -s http://localhost:4000/pets \
  -H "Authorization: Bearer $TOKEN"
```

Expected:
- Valid token: route returns 200 response
- Missing/invalid token: 401 with `missing_token` or `invalid_token`

### C) Negative test (should fail)

```bash
curl -s http://localhost:4000/pets \
  -H "Authorization: Bearer not-a-real-token"
```

Expected: 401 `invalid_token`

## 8) Curl Differences: Before vs Now

Your curl commands mostly stay the same.

Before and now both use:

```bash
curl -H "Authorization: Bearer $TOKEN" http://localhost:4000/pets
```

The difference is backend validation:
- Before: checked if token string existed in in-memory map
- Now: verifies JWT signature and expiry using `JWT_SECRET`

So the command is almost identical, but security model is stronger now.

## 9) Frontend Notes (Quick)

- Save JWT in secure storage (not plain shared preferences)
- Add JWT to Authorization header on protected APIs
- If API returns 401, clear token and send user to login

## 10) Common Confusions

"Can user read JWT payload?"
- Yes. Payload is visible if decoded.

"Can user change payload and still pass auth?"
- Not without `JWT_SECRET`, because signature check will fail.

"Why not keep UUID token map?"
- JWT is standard, scalable, and easier to verify statelessly.

"Does JWT mean no backend checks needed?"
- No. Backend must still verify token and enforce ownership/authorization rules.
