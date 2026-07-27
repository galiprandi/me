#!/usr/bin/env bash
# Greenhouse API capture — Job application POST
# Captured: 2026-07-27 from:
#   - Caylent job 5985808004 (resume_text, 4 custom questions)
#   - Apiphani job 5141628007 (file upload, 0 custom questions, location fields)
#
# Endpoint: POST https://boards.greenhouse.io/{company_slug}/jobs/{job_id}
# Content-Type: application/json
# Response: 200, 13 bytes JSON (likely {"success":true})
#
# REUSABILITY:
#   ✅ Body structure, basic fields (name, email, phone, time_zone)
#   ✅ Endpoint pattern (only company_slug + job_id change)
#   ✅ employments/educations empty structure
#   ✅ from_job_board_renderer: true
#   ✅ answers_attributes: {} when no custom questions
#   ❌ question_id / question_option_id — custom per job posting
#   ❌ g-recaptcha-enterprise-token — per-request, expires ~2 min, browser-only
#   ❌ fingerprint — per-session browser fingerprint
#   ❌ resume_url — S3 pre-signed URL from separate upload step (expires 300s)
#
# BLOCKER: reCAPTCHA Enterprise token cannot be generated via curl.
# Workaround: hybrid approach — use browser to get token, then curl for POST.
#
# HYBRID WORKFLOW (browser + curl):
#   1. Navigate to Greenhouse job form in browser
#   2. Fill form fields via UI (or skip if using curl for body)
#   3. Click reCAPTCHA checkbox to generate token
#   4. Extract token via mcp1_browser_evaluate
#   5. Send curl POST with token
#   6. Token expires in ~2 min — act fast
#
# SHARED RECAPTCHA SITE KEY (all Greenhouse boards):
#   6LfmcbcpAAAAAChNTbhUShzUOAMj_wY9LQIvLFX0

GREENHOUSE_BASE="https://boards.greenhouse.io"

# Apply to a Greenhouse job posting using resume_text (manual entry)
# Args: company_slug job_id first_name last_name email phone resume_text recaptcha_token [fingerprint] [location]
greenhouse_apply_text() {
  local company_slug="$1"
  local job_id="$2"
  local first_name="$3"
  local last_name="$4"
  local email="$5"
  local phone="$6"
  local resume_text="$7"
  local recaptcha_token="$8"
  local fingerprint="${9:-}"
  local location="${10:-}"

  if [ -z "$recaptcha_token" ]; then
    echo "ERROR: reCAPTCHA token required. Extract from browser."
    echo "See greenhouse_get_recaptcha_snippet for instructions."
    return 1
  fi

  local resume_escaped
  resume_escaped=$(echo "$resume_text" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))')

  local url="${GREENHOUSE_BASE}/${company_slug}/jobs/${job_id}"
  local location_block=""
  if [ -n "$location" ]; then
    location_block=",\"location\":\"${location}\",\"country_short_name\":\"AR\""
  fi

  curl -s -X POST "$url" \
    -H "content-type: application/json" \
    -H "referer: ${GREENHOUSE_BASE}/${company_slug}/jobs/${job_id}" \
    -d "{\"job_application\":{\"first_name\":\"${first_name}\",\"last_name\":\"${last_name}\",\"email\":\"${email}\",\"phone\":\"${phone}\",\"resume_text\":${resume_escaped}${location_block},\"from_job_board_renderer\":true,\"employments\":[{\"start_date\":{\"month\":null,\"year\":null},\"end_date\":{\"month\":null,\"year\":null},\"current\":false}],\"educations\":[{\"school_name_id\":null,\"degree_id\":null,\"discipline_id\":null,\"start_date\":{\"month\":null,\"year\":null},\"end_date\":{\"month\":null,\"year\":null}}],\"mapped_url_token\":null,\"appcast_click_id\":null,\"time_zone\":\"America/Argentina/Tucuman\",\"answers_attributes\":{},\"demographic_answers\":[],\"data_compliance\":{},\"attachments\":{}},\"g-recaptcha-enterprise-token\":\"${recaptcha_token}\",\"fingerprint\":\"${fingerprint}\"}"
}

# Apply to a Greenhouse job posting using a pre-uploaded resume URL
# Args: company_slug job_id first_name last_name email phone resume_url resume_filename recaptcha_token [fingerprint] [location]
greenhouse_apply_file() {
  local company_slug="$1"
  local job_id="$2"
  local first_name="$3"
  local last_name="$4"
  local email="$5"
  local phone="$6"
  local resume_url="$7"
  local resume_filename="$8"
  local recaptcha_token="$9"
  local fingerprint="${10:-}"
  local location="${11:-}"

  if [ -z "$recaptcha_token" ]; then
    echo "ERROR: reCAPTCHA token required."
    return 1
  fi

  local url="${GREENHOUSE_BASE}/${company_slug}/jobs/${job_id}"
  local location_block=""
  if [ -n "$location" ]; then
    location_block=",\"location\":\"${location}\",\"country_short_name\":\"AR\""
  fi

  curl -s -X POST "$url" \
    -H "content-type: application/json" \
    -H "referer: ${GREENHOUSE_BASE}/${company_slug}/jobs/${job_id}" \
    -d "{\"job_application\":{\"first_name\":\"${first_name}\",\"last_name\":\"${last_name}\",\"email\":\"${email}\",\"phone\":\"${phone}\",\"resume_url\":\"${resume_url}\",\"resume_url_filename\":\"${resume_filename}\"${location_block},\"from_job_board_renderer\":true,\"employments\":[{\"start_date\":{\"month\":null,\"year\":null},\"end_date\":{\"month\":null,\"year\":null},\"current\":false}],\"educations\":[{\"school_name_id\":null,\"degree_id\":null,\"discipline_id\":null,\"start_date\":{\"month\":null,\"year\":null},\"end_date\":{\"month\":null,\"year\":null}}],\"mapped_url_token\":null,\"appcast_click_id\":null,\"time_zone\":\"America/Argentina/Tucuman\",\"answers_attributes\":{},\"demographic_answers\":[],\"data_compliance\":{},\"attachments\":{}},\"g-recaptcha-enterprise-token\":\"${recaptcha_token}\",\"fingerprint\":\"${fingerprint}\"}"
}

# Extract reCAPTCHA token from a submitted form (post-submit network capture)
# The token appears in the POST body as "g-recaptcha-enterprise-token"
# Use mcp1_browser_network_requests to find the POST, then mcp1_browser_network_request to get the body
#
# ALTERNATIVE: intercept form submit, extract token before sending
# Run this in mcp1_browser_evaluate BEFORE clicking submit:
#
# () => {
#   const form = document.querySelector('form');
#   if (!form) return 'No form found';
#   const originalSubmit = form.onsubmit;
#   form.addEventListener('submit', async (e) => {
#     e.preventDefault();
#     // Try to get token from various sources
#     const tokenInput = document.querySelector('[name="g-recaptcha-enterprise-token"]');
#     let token = tokenInput?.value;
#     if (!token && window.grecaptcha?.enterprise) {
#       try {
#         token = await new Promise((resolve, reject) => {
#           grecaptcha.enterprise.execute(
#             '6LfmcbcpAAAAAChNTbhUShzUOAMj_wY9LQIvLFX0',
#             { action: 'submit' }
#           ).then(resolve).catch(reject);
#         });
#       } catch(e) { token = 'ERROR: ' + e.message; }
#     }
#     window.__recaptcha_token = token;
#     console.log('CAPTURED TOKEN:', token?.substring(0, 50) + '...');
#     // Now actually submit
#     form.submit();
#   }, { once: true });
#   return 'Submit interceptor installed. Click submit to capture token.';
# }
#
# After submit, retrieve with:
# () => window.__recaptcha_token

# Get all custom questions for a specific Greenhouse job (GET the form page)
# This helps identify question_id values needed for answers_attributes
# Args: company_slug job_id
greenhouse_get_job_questions() {
  local company_slug="$1"
  local job_id="$2"
  local url="${GREENHOUSE_BASE}/${company_slug}/jobs/${job_id}"

  curl -s "$url" \
    -H "accept: text/html" \
    -H "referer: ${GREENHOUSE_BASE}/${company_slug}" | \
    grep -oP 'question_id["\s:]+\d+' | sort -u
}
