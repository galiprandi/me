#!/usr/bin/env bash
# Get on Board API captures — Rails form-based (not JSON API)
# Captured: 2026-07-27
#
# Get on Board uses traditional Rails form POST (multipart/form-data)
# with CSRF token + session cookie for auth.
# The form POSTs to /webpros/<slug> with _method=patch (Rails method override).
#
# Form ID: edit_webpro_202021
# Action: https://www.getonbrd.com/webpros/german-aliprandi
# Method: POST (with hidden _method=patch)
#
# Usage:
#   source .agents/skills/job-search/api-captures/getonbrd.sh
#
#   # Get CSRF token + cookie from browser (run in mcp1_browser_evaluate):
#   # () => {
#   #   const form = document.querySelector('#edit_webpro_202021');
#   #   const token = form.querySelector('input[name="authenticity_token"]').value;
#   #   return { token, cookie: document.cookie };
#   # }
#
#   gob_update_profile "$CSRF_TOKEN" "$SESSION_COOKIE" \
#     "Software Engineer | SDLC & AI Strategy Architect" \
#     "<div>Software Engineer con más de 25 años...</div>" \
#     "<div>Software Engineer with over 25 years...</div>" \
#     "<div>EET N°654...</div>" \
#     "<div>EET N°654...</div>" \
#     "upper_intermediate" \
#     "4 5"

GOB_BASE_URL="https://www.getonbrd.com"
GOB_PROFILE_SLUG="german-aliprandi"

# UPDATE profile (Rails PATCH via form POST)
# Full form submission with all fields captured from live request.
#
# Args:
#   $1 - csrf_token
#   $2 - session_cookie (full document.cookie string)
#   $3 - description_es
#   $4 - professional_background_es (HTML with <div> tags)
#   $5 - professional_background_en (HTML with <div> tags)
#   $6 - academic_background_es (HTML with <div> tags)
#   $7 - academic_background_en (HTML with <div> tags)
#   $8 - english_level (upper_intermediate | advanced)
#   $9 - seniority_ids (space-separated: "4" = Senior, "5" = Expert)
gob_update_profile() {
  local csrf_token="$1"
  local session_cookie="$2"
  local description_es="$3"
  local professional_es="$4"
  local professional_en="$5"
  local academic_es="$6"
  local academic_en="$7"
  local english_level="$8"
  local seniority_ids="$9"

  local url="$GOB_BASE_URL/webpros/$GOB_PROFILE_SLUG"

  # Build curl with all form fields
  # Rails expects multipart/form-data for form submissions
  curl -s -L "$url" \
    -X POST \
    -H "cookie: $session_cookie" \
    -H "origin: $GOB_BASE_URL" \
    -H "referer: $GOB_BASE_URL/webpros/edit" \
    -F "_method=patch" \
    -F "authenticity_token=$csrf_token" \
    -F "webpro[image_cache]=" \
    -F "webpro[name]=German Aliprandi" \
    -F "new_email=galiprandi@gmail.com" \
    -F "webpro[phone]=+543816187329" \
    -F "webpro[country]=AR" \
    -F "webpro[description_es]=$description_es" \
    -F "webpro[professional_background_es]=$professional_es" \
    -F "webpro[academic_background_es]=$academic_es" \
    -F "webpro[description_en]=$description_es" \
    -F "webpro[professional_background_en]=$professional_en" \
    -F "webpro[academic_background_en]=$academic_en" \
    -F "webpro[english_level]=$english_level" \
    $(for id in $seniority_ids; do echo "-F webpro[seniority_ids][]=$id"; done) \
    -F "webpro[portfolio]=https://galiprandi.github.io/me/" \
    -F "webpro[youtube]=" \
    -F "webpro[gitlab]=" \
    -F "webpro[linkedin]=http://linkedin.com/in/galiprandi" \
    -F "commit=Guardar todos los cambios"
}

# GET profile edit page (to extract fresh CSRF token)
# Parse CSRF with: grep -o 'name="authenticity_token" value="[^"]*"' | head -1
gob_get_edit_page() {
  local session_cookie="$1"
  curl -s "$GOB_BASE_URL/webpros/edit" \
    -H "cookie: $session_cookie"
}

# GET public profile
gob_get_profile() {
  curl -s "$GOB_BASE_URL/p/$GOB_PROFILE_SLUG"
}

# Extract CSRF token from edit page HTML
gob_extract_csrf_token() {
  local html="$1"
  echo "$html" | grep -o 'name="authenticity_token" value="[^"]*"' | head -1 | sed 's/.*value="//;s/"//'
}

# Seniority IDs reference:
#   2 = Junior
#   3 = Semi Senior
#   4 = Senior
#   5 = Expert
#   6 = Lead
#   7 = Architect
