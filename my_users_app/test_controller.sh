#!/bin/bash

# This script tests the Sinatra API endpoints using curl
# Concept: INTEGRATION TESTING - testing components working together

echo "============================================"
echo "TESTING SINATRA CONTROLLER"
echo "============================================"
echo ""

# Base URL - change if your server runs elsewhere
BASE_URL="http://localhost:8080"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clean up old cookies
rm -f cookies.txt

echo "=== TEST 1: GET /users (empty database) ==="
response=$(curl -s -X GET "$BASE_URL/users")
echo "Response: $response"
if [[ "$response" == "[]" ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: Empty users array"
else
    echo -e "${YELLOW}⚠ WARNING${NC}: Database might not be empty"
fi
echo ""

echo "=== TEST 2: POST /users (create user) ==="
response=$(curl -s -X POST "$BASE_URL/users" \
  -d "firstname=TestUser" \
  -d "lastname=McTest" \
  -d "age=28" \
  -d "password=test123" \
  -d "email=test@example.com")
echo "Response: $response"

# Check if response contains firstname
# Concept: RESPONSE VALIDATION
if [[ "$response" == *"TestUser"* ]] && [[ "$response" != *"password"* ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: User created, password not exposed"
else
    echo -e "${RED}❌ FAILED${NC}: User creation failed or password exposed"
fi
echo ""

echo "=== TEST 3: POST /users (missing fields) ==="
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$BASE_URL/users" \
  -d "firstname=Incomplete" \
  -d "email=incomplete@example.com")
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d':' -f2)
echo "HTTP Code: $http_code"

# Should return 400 Bad Request
# Concept: ERROR HANDLING validation
if [[ "$http_code" == "400" ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: Returns 400 for missing fields"
else
    echo -e "${RED}❌ FAILED${NC}: Should return 400, got $http_code"
fi
echo ""

echo "=== TEST 4: GET /users (should have 1 user) ==="
response=$(curl -s -X GET "$BASE_URL/users")
echo "Response: $response"

# Count how many users (simple check)
if [[ "$response" == *"TestUser"* ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: User found in list"
else
    echo -e "${RED}❌ FAILED${NC}: User not in list"
fi
echo ""

echo "=== TEST 5: POST /sign_in (correct credentials) ==="
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$BASE_URL/sign_in" \
  -c cookies.txt \
  -d "email=test@example.com" \
  -d "password=test123")
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d':' -f2)
body=$(echo "$response" | grep -v "HTTP_CODE")

echo "HTTP Code: $http_code"
echo "Response: $body"

# Should return 200 OK
# Concept: AUTHENTICATION success
if [[ "$http_code" == "200" ]] && [[ "$body" == *"TestUser"* ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: Sign in successful"
    echo "Cookies saved to cookies.txt"
else
    echo -e "${RED}❌ FAILED${NC}: Sign in failed"
fi
echo ""

echo "=== TEST 6: POST /sign_in (wrong password) ==="
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$BASE_URL/sign_in" \
  -d "email=test@example.com" \
  -d "password=wrongpassword")
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d':' -f2)

echo "HTTP Code: $http_code"

# Should return 401 Unauthorized
# Concept: AUTHENTICATION failure
if [[ "$http_code" == "401" ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: Returns 401 for wrong password"
else
    echo -e "${RED}❌ FAILED${NC}: Should return 401, got $http_code"
fi
echo ""

echo "=== TEST 7: PUT /users (update password - logged in) ==="
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X PUT "$BASE_URL/users" \
  -b cookies.txt \
  -d "password=newpass456")
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d':' -f2)
body=$(echo "$response" | grep -v "HTTP_CODE")

echo "HTTP Code: $http_code"
echo "Response: $body"

# Should return 200 OK
# Concept: AUTHORIZED UPDATE
if [[ "$http_code" == "200" ]] && [[ "$body" == *"TestUser"* ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: Password updated"
else
    echo -e "${RED}❌ FAILED${NC}: Password update failed"
fi
echo ""

echo "=== TEST 8: PUT /users (without login) ==="
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X PUT "$BASE_URL/users" \
  -d "password=hackme")
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d':' -f2)

echo "HTTP Code: $http_code"

# Should return 401 Unauthorized
# Concept: AUTHORIZATION check
if [[ "$http_code" == "401" ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: Returns 401 without login"
else
    echo -e "${RED}❌ FAILED${NC}: Should return 401, got $http_code"
fi
echo ""

echo "=== TEST 9: DELETE /sign_out ==="
response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X DELETE "$BASE_URL/sign_out" \
  -b cookies.txt)
http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d':' -f2)

echo "HTTP Code: $http_code"

# Should return 204 No Content
# Concept: LOGOUT success
if [[ "$http_code" == "204" ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: Signed out successfully"
else
    echo -e "${RED}❌ FAILED${NC}: Sign out failed"
fi
echo ""

echo "=== TEST 10: GET / (home page HTML) ==="
response=$(curl -s "$BASE_URL/")
echo "Response preview: ${response:0:100}..."

# Should contain HTML table
# Concept: VIEW RENDERING
if [[ "$response" == *"<table>"* ]] && [[ "$response" == *"TestUser"* ]]; then
    echo -e "${GREEN}✅ PASSED${NC}: HTML page rendered with user data"
else
    echo -e "${RED}❌ FAILED${NC}: HTML page missing or no data"
fi
echo ""

echo "============================================"
echo "CONTROLLER TESTS COMPLETE"
echo "============================================"
echo ""
echo "Check cookies.txt for session data"