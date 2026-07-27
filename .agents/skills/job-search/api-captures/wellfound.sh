#!/usr/bin/env bash
# Wellfound API captures — GraphQL (Apollo)
# Captured: 2026-07-27
#
# Wellfound uses Apollo GraphQL with persisted queries (APQ).
# operationIds are hashes baked into the JS bundle and can change on deploy.
# DO NOT hardcode them — always fetch dynamically via wf_get_operation_ids first.
#
# Auth: session cookie. Headers: content-type, x-requested-with.
#
# User ID: 16064021 | Profile slug: german-aliprandi
#
# Static reference IDs (these are data, not code — stable across deploys):
#   Role IDs: 14726=Software Engineer, 151118=Engineering Manager, 151580=CTO
#   Company IDs: 8737181=Cencosud, 8800087=Egg Cooperation, 8004430=Rooftop, 7979596=Gadget
#   Skill IDs: 14781=JS, 15597=Management, 16999=MongoDB, 17000=Node.js, 94482=TS,
#     139914=React.js, 17966=AI, 14775=Python, 258360=GraphQL, 110461=Docker,
#     198603=Kubernetes, 629815=CI/CD, 22286=PostgreSQL, 171817=AWS, 683870=Fastify,
#     918359=LLMs, 75683=Agile
#   Experience IDs: 23920112=Egg Cooperation
#
# ── USAGE (two-step: get IDs, then mutate) ─────────────────────────────────────
#
# Step 1: Extract operationIds from the running page (via mcp1_browser_evaluate):
#
#   // Run this in mcp1_browser_evaluate to get all operationIds as JSON:
#   () => {
#     const ops = {};
#     // Apollo Client stores persisted query manifests in window.__APOLLO_CLIENT__
#     // or in the webpack modules. We intercept by scanning the inFlightLinkObservable.
#     const queries = window.__APOLLO_CLIENT__?.queryManager?.queries;
#     if (queries) {
#       for (const [key, val] of queries) {
#         const opName = val?.observableQuery?.queryName;
#         const opId = val?.document?.loc?.source?.body
#           ? undefined  // inline query, no persisted id
#           : val?.observableQuery?.options?.extensions?.operationId;
#         if (opName && opId) ops[opName] = opId;
#       }
#     }
#     // Fallback: scan all fetch/XHR payloads captured by Apollo's link
#     // The most reliable way: search the JS bundle for operationName→operationId mappings
#     return Object.keys(ops).length > 0 ? ops : 'FALLBACK_NEEDED';
#   }
#
#   If the Apollo store approach doesn't expose operationIds, use the network
#   intercept approach (see wf_intercept_operations below).
#
# Step 2: Pass operationIds to the curl functions:
#
#   source .agents/skills/job-search/api-captures/wellfound.sh
#   wf_save_bio "$COOKIE" "$OP_BIO" "Your bio text"
#   wf_save_roles "$COOKIE" "$OP_ROLES" "14726" "151118 151580" 10
#   wf_save_experience "$COOKIE" "$OP_EXP" "8737181" "Software Engineer" 6 2025 0 0 true "desc"

WF_BASE_URL="https://wellfound.com"
WF_GRAPHQL_URL="https://wellfound.com/graphql"
WF_USER_ID="16064021"

# ═══════════════════════════════════════════════════════════════════════════════
# OPERATION ID EXTRACTION (run in browser via mcp1_browser_evaluate)
# ═══════════════════════════════════════════════════════════════════════════════

# JS snippet to extract operationIds by intercepting network requests.
# Run this BEFORE performing any profile edit action. It monkey-patches fetch
# and collects all GraphQL operationIds for 30 seconds, then returns them.
#
# Usage in mcp1_browser_run_code_unsafe:
#   const ids = await page.evaluate(() => { ... wf_intercept_js ... });
#
# Or simpler: trigger one UI action per section and capture the operationId
# from the network request. See wf_intercept_operations below.

WF_INTERCEPT_JS='
(() => {
  const ops = {};
  const origFetch = window.fetch;
  window.fetch = async function(...args) {
    const [url, opts] = args;
    if (url === "/graphql" && opts?.body) {
      try {
        const body = JSON.parse(opts.body);
        if (body.operationName && body.extensions?.operationId) {
          ops[body.operationName] = body.extensions.operationId;
        }
      } catch(e) {}
    }
    return origFetch.apply(this, args);
  };
  window.__wf_ops__ = ops;
  window.__wf_restore__ = () => { window.fetch = origFetch; };
  return "interceptor installed — trigger UI actions, then call window.__wf_ops__";
})()
'

# JS snippet to collect intercepted operationIds (call after triggering UI saves)
WF_COLLECT_JS='
(() => {
  const ops = { ...window.__wf_ops__ };
  window.__wf_restore__?.();
  return ops;
})()
'

# ═══════════════════════════════════════════════════════════════════════════════
# GRAPHQL CURL FUNCTIONS (all accept operationId as 2nd arg)
# ═══════════════════════════════════════════════════════════════════════════════

# Save bio
# Args: session_cookie operation_id bio_text
wf_save_bio() {
  local cookie="$1" local op_id="$2" local bio="$3"
  curl -s "$WF_GRAPHQL_URL" -X POST \
    -H "content-type: application/json" -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" -H "origin: $WF_BASE_URL" -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveBio\",\"variables\":{\"input\":{\"bio\":\"$bio\",\"userId\":\"$WF_USER_ID\"}},\"extensions\":{\"operationId\":\"$op_id\"}}"
}

# Save roles (primary role + open to roles + years of experience)
# Args: session_cookie operation_id primary_role_id "role_id1 role_id2" years_experience
wf_save_roles() {
  local cookie="$1" op_id="$2" primary_role_id="$3" role_ids="$4" years="$5"
  local role_ids_json=$(echo "$role_ids" | sed 's/ /","/g' | sed 's/^/["/;s/$/"]/')
  curl -s "$WF_GRAPHQL_URL" -X POST \
    -H "content-type: application/json" -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" -H "origin: $WF_BASE_URL" -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveRoles\",\"variables\":{\"input\":{\"primaryRoleId\":\"$primary_role_id\",\"roleIds\":$role_ids_json,\"userId\":\"$WF_USER_ID\",\"yearsExperienceInPrimaryRole\":$years}},\"extensions\":{\"operationId\":\"$op_id\"}}"
}

# Save social profiles
# Args: session_cookie operation_id website_url github_url linkedin_url [twitter_url]
wf_save_social() {
  local cookie="$1" op_id="$2" website="$3" github="$4" linkedin="$5" twitter="${6:-}"
  local twitter_json="null"
  [ -n "$twitter" ] && twitter_json="\"$twitter\""
  curl -s "$WF_GRAPHQL_URL" -X POST \
    -H "content-type: application/json" -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" -H "origin: $WF_BASE_URL" -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveSocialProfiles\",\"variables\":{\"input\":{\"onlineBioUrl\":\"$website\",\"githubUrl\":\"$github\",\"linkedinUrl\":\"$linkedin\",\"twitterUrl\":$twitter_json,\"userId\":\"$WF_USER_ID\"}},\"extensions\":{\"operationId\":\"$op_id\"}}"
}

# Save skills
# Args: session_cookie operation_id "skill_tag_id1 skill_tag_id2 ..."
wf_save_skills() {
  local cookie="$1" op_id="$2" skill_ids="$3"
  local skill_ids_json=$(echo "$skill_ids" | sed 's/ /","/g' | sed 's/^/["/;s/$/"]/')
  curl -s "$WF_GRAPHQL_URL" -X POST \
    -H "content-type: application/json" -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" -H "origin: $WF_BASE_URL" -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveSkills\",\"variables\":{\"input\":{\"skillTags\":$skill_ids_json,\"userId\":\"$WF_USER_ID\"}},\"extensions\":{\"operationId\":\"$op_id\"}}"
}

# Save education
# Args: session_cookie operation_id degree_type graduation_year "major1 major2" [gpa] [max_gpa]
wf_save_education() {
  local cookie="$1" op_id="$2" degree_type="$3" grad_year="$4" majors="$5" gpa="${6:-null}" max_gpa="${7:-null}"
  local majors_json=$(echo "$majors" | sed 's/ /","/g' | sed 's/^/["/;s/$/"]/')
  curl -s "$WF_GRAPHQL_URL" -X POST \
    -H "content-type: application/json" -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" -H "origin: $WF_BASE_URL" -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveEducation\",\"variables\":{\"input\":{\"gpa\":$gpa,\"graduationMonth\":null,\"graduationYear\":$grad_year,\"maxGpa\":$max_gpa,\"degreeType\":\"$degree_type\",\"majors\":$majors_json,\"userId\":\"$WF_USER_ID\"}},\"extensions\":{\"operationId\":\"$op_id\"}}"
}

# Search for skills by query (to find skill tag IDs)
# Args: session_cookie operation_id "query text"
wf_search_skills() {
  local cookie="$1" op_id="$2" query="$3"
  curl -s "$WF_GRAPHQL_URL" -X POST \
    -H "content-type: application/json" -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" -H "origin: $WF_BASE_URL" -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"SkillTagAutocompleteField\",\"variables\":{\"canonicalSkillsOnly\":false,\"query\":\"$query\"},\"extensions\":{\"operationId\":\"$op_id\"}}"
}

# Save work experience (create or update)
# Args: session_cookie operation_id startup_id title start_month start_year end_month end_year current description [experience_id]
wf_save_experience() {
  local cookie="$1" op_id="$2" startup_id="$3" title="$4" start_month="$5" start_year="$6" end_month="$7" end_year="$8" current="$9" description="${10}" experience_id="${11:-}"
  local id_json=""
  [ -n "$experience_id" ] && id_json="\"id\":\"$experience_id\","
  local current_json="null"
  [ "$current" = "true" ] && current_json="true"
  [ "$current" = "false" ] && current_json="false"
  local end_json="\"endedAtMonth\":$end_month,\"endedAtYear\":$end_year,"
  [ "$current" = "true" ] && end_json="\"endedAtMonth\":null,\"endedAtYear\":null,"
  curl -s "$WF_GRAPHQL_URL" -X POST \
    -H "content-type: application/json" -H "x-requested-with: XMLHttpRequest" \
    -H "cookie: $cookie" -H "origin: $WF_BASE_URL" -H "referer: $WF_BASE_URL/profile/edit" \
    --data-raw "{\"operationName\":\"ProfileSaveExperience\",\"variables\":{\"input\":{$id_json\"averageDealSize\":null,\"canonicalSkillIds\":[],$end_json\"marketSegmentId\":null,\"percentageOfQuotaAchieved\":null,\"startedAtMonth\":$start_month,\"startedAtYear\":$start_year,\"startupId\":\"$startup_id\",\"current\":$current_json,\"description\":\"$description\",\"title\":\"$title\",\"userId\":\"$WF_USER_ID\"}},\"extensions\":{\"operationId\":\"$op_id\"}}"
}

# GET public profile
wf_get_profile() {
  curl -s "$WF_BASE_URL/u/german-aliprandi"
}
