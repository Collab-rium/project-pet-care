#!/bin/bash

# Generate unique email
TIMESTAMP=$(date +%s%N)
EMAIL="pet$TIMESTAMP@example.com"

echo "=== Section 1: Pet Store & CRUD Endpoints Test ==="
echo "Using email: $EMAIL"

# Register user
echo -e "\n--- Register User ---"
REGISTER=$(curl -s -X POST http://localhost:4000/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"password123\",\"name\":\"Test User\"}")

TOKEN=$(echo "$REGISTER" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('token', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get token from register response"
  echo "Response: $REGISTER"
  exit 1
fi

echo "✅ User registered, token obtained"

# Test 1: GET /pets (empty)
echo -e "\n--- Test 1: GET /pets (empty) ---"
RESULT=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:4000/pets)
if echo "$RESULT" | grep -q '"data":\[\]'; then
  echo "✅ Empty pet list returned correctly"
else
  echo "❌ Unexpected response: $RESULT"
  exit 1
fi

# Test 2: POST /pets (create pet)
echo -e "\n--- Test 2: POST /pets (create pet) ---"
PET=$(curl -s -X POST http://localhost:4000/pets \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Buddy","type":"dog","age":3,"breed":"Golden Retriever"}')

PET_ID=$(echo "$PET" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('data', {}).get('id', ''))" 2>/dev/null)

if [ -z "$PET_ID" ]; then
  echo "❌ Failed to create pet"
  echo "Response: $PET"
  exit 1
fi

echo "✅ Pet created: $PET_ID"

# Test 3: GET /pets (with data)
echo -e "\n--- Test 3: GET /pets (with data) ---"
PETS=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:4000/pets)
if echo "$PETS" | grep -q "$PET_ID"; then
  echo "✅ Pet list contains created pet"
else
  echo "❌ Pet not found in list"
  echo "Response: $PETS"
  exit 1
fi

# Test 4: GET /pets/:id (single pet)
echo -e "\n--- Test 4: GET /pets/:id ---"
PET_DETAIL=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:4000/pets/$PET_ID)
if echo "$PET_DETAIL" | grep -q '"name":"Buddy"'; then
  echo "✅ Single pet retrieved correctly"
else
  echo "❌ Unexpected response: $PET_DETAIL"
  exit 1
fi

# Test 5: PUT /pets/:id (update)
echo -e "\n--- Test 5: PUT /pets/:id (update) ---"
UPDATED=$(curl -s -X PUT http://localhost:4000/pets/$PET_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"age":4,"breed":"Golden Retriever Mix"}')

if echo "$UPDATED" | grep -q '"age":4'; then
  echo "✅ Pet updated correctly"
else
  echo "❌ Update failed"
  echo "Response: $UPDATED"
  exit 1
fi

# Test 6: DELETE /pets/:id
echo -e "\n--- Test 6: DELETE /pets/:id ---"
DELETED=$(curl -s -X DELETE http://localhost:4000/pets/$PET_ID \
  -H "Authorization: Bearer $TOKEN")

if echo "$DELETED" | grep -q 'Pet deleted successfully'; then
  echo "✅ Pet deleted successfully"
else
  echo "❌ Delete failed"
  echo "Response: $DELETED"
  exit 1
fi

# Test 7: GET /pets/:id (should be 404)
echo -e "\n--- Test 7: GET /pets/:id (expect 404 after delete) ---"
NOT_FOUND=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:4000/pets/$PET_ID)

if echo "$NOT_FOUND" | grep -q '"error":"pet_not_found"'; then
  echo "✅ Correct 404 error after deletion"
else
  echo "❌ Unexpected response: $NOT_FOUND"
  exit 1
fi

echo -e "\n✅ ✅ ✅ ALL SECTION 1 TESTS PASSED ✅ ✅ ✅"
