#!/usr/bin/env bash
# Wellfound API captures — GraphQL (Apollo)
# Captured: 2026-07-27
#
# Wellfound uses GraphQL via POST to /graphql with Apollo Client.
# Auth: session cookie + CSRF token (not always required for GraphQL).
# Headers: content-type: application/json, x-requested-with: XMLHttpRequest
#
# User ID: 16064021
# Profile slug: german-aliprandi
#
# Role IDs reference:
#   14726 = Software Engineer (primary role)
#   151118 = Engineering Manager
#   151580 = CTO
#   151711 = Frontend Engineer
#
# Usage:
#   source .agents/skills/job-search/api-captures/wellfound.sh
#
#   # Get session cookie from browser (run in mcp1_browser_evaluate):
#   # () => document.cookie
#
#   wf_save_bio "$SESSION_COOKIE" "Your bio text here"
#   wf_save_roles "$SESSION_COOKIE" "14726" "151118 151580" 10
#   wf_save_social "$SESSION_COOKIE" "https://galiprandi.github.io/me" "https://github.com/galiprandi" "https://www.linkedin.com/in/galiprandi"

WF_BASE_URL="https://wellfound.com"
WF_GRAPHQL_URL="https://wellfound.com/graphql"
WF_USER_ID="16064021"

# Save bio
# Args: session_cookie bio_text
wf_save_bio() {
  local cookie="$1"
  local bio="$2"

  curl -s "$WF_GRAPHQL_URL" \
    -X POST \
    -H "content-type: application/json" \
    -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" \
    -H "origin: $WF_BASE_URL" \
    -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveBio\",\"variables\":{\"input\":{\"bio\":\"$bio\",\"userId\":\"$WF_USER_ID\"}},\"extensions\":{\"operationId\":\"tfe/7a19d4a2372ad9057d5ae29abee4582b04de4eccc3df98e078b998fd27e4bed0\"}}"
}

# Save roles (primary role + open to roles + years of experience)
# Args: session_cookie primary_role_id "role_id1 role_id2" years_experience
wf_save_roles() {
  local cookie="$1"
  local primary_role_id="$2"
  local role_ids="$3"
  local years="$4"

  # Build roleIds array JSON
  local role_ids_json=$(echo "$role_ids" | sed 's/ /","/g' | sed 's/^/["/;s/$/"]/')

  curl -s "$WF_GRAPHQL_URL" \
    -X POST \
    -H "content-type: application/json" \
    -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" \
    -H "origin: $WF_BASE_URL" \
    -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveRoles\",\"variables\":{\"input\":{\"primaryRoleId\":\"$primary_role_id\",\"roleIds\":$role_ids_json,\"userId\":\"$WF_USER_ID\",\"yearsExperienceInPrimaryRole\":$years}},\"extensions\":{\"operationId\":\"tfe/473ebe616eeefebafb37e0e9f15083bbec919d51556bfa7b2b3ab7ba0b775bdb\"}}"
}

# Save social profiles
# Args: session_cookie website_url github_url linkedin_url [twitter_url]
wf_save_social() {
  local cookie="$1"
  local website="$2"
  local github="$3"
  local linkedin="$4"
  local twitter="${5:-null}"

  local twitter_json="null"
  if [ "$twitter" != "null" ] && [ -n "$twitter" ]; then
    twitter_json="\"$twitter\""
  fi

  curl -s "$WF_GRAPHQL_URL" \
    -X POST \
    -H "content-type: application/json" \
    -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" \
    -H "origin: $WF_BASE_URL" \
    -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveSocialProfiles\",\"variables\":{\"input\":{\"onlineBioUrl\":\"$website\",\"githubUrl\":\"$github\",\"linkedinUrl\":\"$linkedin\",\"twitterUrl\":$twitter_json,\"userId\":\"$WF_USER_ID\"}},\"extensions\":{\"operationId\":\"tfe/8be924bafedbaa18bea8a94d6b08a05387d7fd05cbe89d710c18e47f3d55d0bd\"}}"
}

# Save skills
# Args: session_cookie "skill_tag_id1 skill_tag_id2 ..."
wf_save_skills() {
  local cookie="$1"
  local skill_ids="$2"

  local skill_ids_json=$(echo "$skill_ids" | sed 's/ /","/g' | sed 's/^/["/;s/$/"]/')

  curl -s "$WF_GRAPHQL_URL" \
    -X POST \
    -H "content-type: application/json" \
    -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" \
    -H "origin: $WF_BASE_URL" \
    -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveSkills\",\"variables\":{\"input\":{\"skillTags\":$skill_ids_json,\"userId\":\"$WF_USER_ID\"}},\"extensions\":{\"operationId\":\"tfe/77e6ef40d61e30d1a307c5a0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0\"}}"
}

# Save education
# Args: session_cookie degree_type graduation_year "major1 major2" [gpa] [max_gpa]
wf_save_education() {
  local cookie="$1"
  local degree_type="$2"
  local grad_year="$3"
  local majors="$4"
  local gpa="${5:-null}"
  local max_gpa="${6:-null}"

  local majors_json=$(echo "$majors" | sed 's/ /","/g' | sed 's/^/["/;s/$/"]/')

  curl -s "$WF_GRAPHQL_URL" \
    -X POST \
    -H "content-type: application/json" \
    -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" \
    -H "origin: $WF_BASE_URL" \
    -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveEducation\",\"variables\":{\"input\":{\"gpa\":$gpa,\"graduationMonth\":null,\"graduationYear\":$grad_year,\"maxGpa\":$max_gpa,\"degreeType\":\"$degree_type\",\"majors\":$majors_json,\"userId\":\"$WF_USER_ID\"}},\"extensions\":{\"operationId\":\"tfe/d2168ea96c86c95952d32087da5633b6233d8049fac9bd338f2387c10e8879b1\"}}"
}

# Search for skills by query (to find skill tag IDs)
# Args: session_cookie "query text"
wf_search_skills() {
  local cookie="$1"
  local query="$2"

  curl -s "$WF_GRAPHQL_URL" \
    -X POST \
    -H "content-type: application/json" \
    -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" \
    -H "origin: $WF_BASE_URL" \
    -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"SkillTagAutocompleteField\",\"variables\":{\"canonicalSkillsOnly\":false,\"query\":\"$query\"},\"extensions\":{\"operationId\":\"tfe/0ca44ecafb1f994f981bac26cce2aba2fcff4ec4757fd5eb2f9cf06fc9bf29bf\"}}"
}

# GET public profile
wf_get_profile() {
  curl -s "$WF_BASE_URL/u/german-aliprandi"
}
