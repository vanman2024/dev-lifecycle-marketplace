#!/usr/bin/env bash
# inject-auth.sh - Inject authentication strategy into Postman collection
# Usage: bash inject-auth.sh <collection.json> <strategy>
# Strategies: supabase_cookie, clerk_jwt, auth0_token, bearer_token, api_key

set -euo pipefail

COLLECTION="${1:?Usage: inject-auth.sh <collection.json> <strategy>}"
STRATEGY="${2:?Strategy required: supabase_cookie, clerk_jwt, auth0_token, bearer_token, api_key}"

if ! command -v jq &>/dev/null; then
  echo "[!] jq required for auth injection"
  exit 1
fi

echo "Injecting auth: $STRATEGY into $COLLECTION"

case "$STRATEGY" in
  supabase_cookie)
    # Add Supabase cookie auth pre-request script
    PRE_REQUEST='const supabaseUrl = pm.environment.get("SUPABASE_URL") || "your_supabase_url_here";
const supabaseKey = pm.environment.get("SUPABASE_ANON_KEY") || "your_supabase_anon_key_here";
const email = pm.environment.get("TEST_USER_EMAIL") || "test@example.com";
const password = pm.environment.get("TEST_USER_PASSWORD") || "your_test_password_here";

pm.sendRequest({
  url: supabaseUrl + "/auth/v1/token?grant_type=password",
  method: "POST",
  header: { "Content-Type": "application/json", "apikey": supabaseKey },
  body: { mode: "raw", raw: JSON.stringify({ email, password }) }
}, (err, res) => {
  if (!err && res.code === 200) {
    const token = res.json().access_token;
    pm.environment.set("AUTH_TOKEN", token);
  }
});'
    ;;

  clerk_jwt)
    PRE_REQUEST='const clerkSecretKey = pm.environment.get("CLERK_SECRET_KEY") || "your_clerk_secret_key_here";
pm.request.headers.add({ key: "Authorization", value: "Bearer " + pm.environment.get("AUTH_TOKEN") });'
    ;;

  auth0_token)
    PRE_REQUEST='const domain = pm.environment.get("AUTH0_DOMAIN") || "your_auth0_domain_here";
const clientId = pm.environment.get("AUTH0_CLIENT_ID") || "your_auth0_client_id_here";
const clientSecret = pm.environment.get("AUTH0_CLIENT_SECRET") || "your_auth0_client_secret_here";
const audience = pm.environment.get("AUTH0_AUDIENCE") || "your_auth0_audience_here";

pm.sendRequest({
  url: "https://" + domain + "/oauth/token",
  method: "POST",
  header: { "Content-Type": "application/json" },
  body: { mode: "raw", raw: JSON.stringify({ client_id: clientId, client_secret: clientSecret, audience: audience, grant_type: "client_credentials" }) }
}, (err, res) => {
  if (!err && res.code === 200) {
    pm.environment.set("AUTH_TOKEN", res.json().access_token);
  }
});'
    ;;

  bearer_token)
    PRE_REQUEST='const token = pm.environment.get("AUTH_TOKEN") || "your_auth_token_here";
pm.request.headers.add({ key: "Authorization", value: "Bearer " + token });'
    ;;

  api_key)
    PRE_REQUEST='const apiKey = pm.environment.get("API_KEY") || "your_api_key_here";
pm.request.headers.add({ key: "X-API-Key", value: apiKey });'
    ;;

  *)
    echo "[!] Unknown strategy: $STRATEGY"
    echo "Valid: supabase_cookie, clerk_jwt, auth0_token, bearer_token, api_key"
    exit 1
    ;;
esac

# Inject pre-request script into collection
tmp=$(mktemp)
jq --arg script "$PRE_REQUEST" \
  '.event = (.event // []) + [{"listen": "prerequest", "script": {"type": "text/javascript", "exec": ($script | split("\n"))}}]' \
  "$COLLECTION" > "$tmp" && mv "$tmp" "$COLLECTION"

echo "Auth injected successfully"
