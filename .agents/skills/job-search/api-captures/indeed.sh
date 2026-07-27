#!/usr/bin/env bash
# Indeed API captures — GraphQL via apis.indeed.com
# Captured: 2026-07-27
#
# Usage:
#   source .agents/skills/job-search/api-captures/indeed.sh
#   indeed_get_experiences
#   indeed_update_experience "$EXP_ID" "$TITLE" "$COMPANY" "$DESC" "$FROM_MONTH" "$FROM_YEAR" "$TO_MONTH" "$TO_YEAR" "$IS_CURRENT"
#   indeed_create_experience "$TITLE" "$COMPANY" "$DESC" "$FROM_MONTH" "$FROM_YEAR" "$TO_MONTH" "$TO_YEAR" "$IS_CURRENT"
#   indeed_delete_experience "$EXP_ID"

INDEED_GRAPHQL_URL="https://apis.indeed.com/graphql"
INDEED_API_KEY="0e5cc3c91d448c2f47bf97792f39eb2cfcb9ac319a983aa721dc3e8560264eec"
INDEED_RESUME_ID="Ee2zLRjfIoaERTG4vxWEtA"

# Extract cookies from Chrome perfil German via mcp1_browser_evaluate
# Run this first to get a fresh CTK token
indeed_get_cookies() {
  echo "# Run in mcp1_browser_evaluate:"
  echo '# () => document.cookie'
  echo "# Then extract CTK value from the result"
  echo "# CTK is used as indeed-ctk header"
}

# GET all work experiences
indeed_get_experiences() {
  local ctk="$1"
  curl -s "$INDEED_GRAPHQL_URL" \
    -H "content-type: application/json" \
    -H "indeed-api-key: $INDEED_API_KEY" \
    -H "indeed-co: AR" \
    -H "indeed-ctk: $ctk" \
    -H "indeed-locale: es-AR" \
    --data-raw '{"operationName":"WorkExperiences","variables":{},"query":"query WorkExperiences { jobSeekerProfile { profile { accountKey resume { id workExperiences { id title normalizedTitle company companySector { name } dateRange { fromDate { month year } toDate { month year } isCurrent } description location { country formattedLocation } } wordCount } } } } }"}'
}

# UPDATE an existing work experience
# Args: exp_id title company description from_month from_year to_month to_year is_current
# Months: JANUARY FEBRUARY MARCH APRIL MAY JUNE JULY AUGUST SEPTEMBER OCTOBER NOVEMBER DECEMBER
indeed_update_experience() {
  local ctk="$1"
  local exp_id="$2"
  local title="$3"
  local company="$4"
  local description="$5"
  local from_month="$6"
  local from_year="$7"
  local to_month="$8"
  local to_year="$9"
  local is_current="${10:-false}"

  local to_date_block
  if [ "$is_current" = "true" ]; then
    to_date_block='"toDate":null'
  else
    to_date_block="\"toDate\":{\"month\":\"$to_month\",\"year\":$to_year}"
  fi

  curl -s "$INDEED_GRAPHQL_URL" \
    -H "content-type: application/json" \
    -H "indeed-api-key: $INDEED_API_KEY" \
    -H "indeed-co: AR" \
    -H "indeed-ctk: $ctk" \
    -H "indeed-locale: es-AR" \
    --data-raw "{\"operationName\":\"UpdateWorkExperience\",\"variables\":{\"input\":{\"resumeId\":\"$INDEED_RESUME_ID\",\"workExperiences\":[{\"id\":\"$exp_id\",\"title\":\"$title\",\"company\":\"$company\",\"description\":\"$description\",\"location\":{\"unknownLocation\":\"\",\"country\":\"AR\"},\"dateRange\":{\"isCurrent\":$is_current,\"fromDate\":{\"month\":\"$from_month\",\"year\":$from_year},$to_date_block},\"customFields\":[],\"occupations\":[],\"attributes\":[]}]}},\"query\":\"mutation UpdateWorkExperience(\$input: UpdateJobSeekerProfileResumeWorkExperiencesInput!) { updateJobSeekerProfileResumeWorkExperiences(input: \$input) { workExperiences { id title company description dateRange { fromDate { month year } toDate { month year } isCurrent } } } } }\"}"
}

# CREATE a new work experience (same mutation, without id field)
indeed_create_experience() {
  local ctk="$1"
  local title="$2"
  local company="$3"
  local description="$4"
  local from_month="$5"
  local from_year="$6"
  local to_month="$7"
  local to_year="$8"
  local is_current="${9:-false}"

  local to_date_block
  if [ "$is_current" = "true" ]; then
    to_date_block='"toDate":null'
  else
    to_date_block="\"toDate\":{\"month\":\"$to_month\",\"year\":$to_year}"
  fi

  curl -s "$INDEED_GRAPHQL_URL" \
    -H "content-type: application/json" \
    -H "indeed-api-key: $INDEED_API_KEY" \
    -H "indeed-co: AR" \
    -H "indeed-ctk: $ctk" \
    -H "indeed-locale: es-AR" \
    --data-raw "{\"operationName\":\"UpdateWorkExperience\",\"variables\":{\"input\":{\"resumeId\":\"$INDEED_RESUME_ID\",\"workExperiences\":[{\"title\":\"$title\",\"company\":\"$company\",\"description\":\"$description\",\"location\":{\"unknownLocation\":\"\",\"country\":\"AR\"},\"dateRange\":{\"isCurrent\":$is_current,\"fromDate\":{\"month\":\"$from_month\",\"year\":$from_year},$to_date_block},\"customFields\":[],\"occupations\":[],\"attributes\":[]}]}},\"query\":\"mutation UpdateWorkExperience(\$input: UpdateJobSeekerProfileResumeWorkExperiencesInput!) { updateJobSeekerProfileResumeWorkExperiences(input: \$input) { workExperiences { id title company description dateRange { fromDate { month year } toDate { month year } isCurrent } } } } }\"}"
}

# DELETE a work experience
# Note: Indeed uses a separate mutation for deletion
# The delete is done via UpdateWorkExperience by omitting the experience from the array
# This requires fetching ALL experiences, removing the target, and sending the full list
indeed_delete_experience() {
  local ctk="$1"
  local exp_id="$2"
  echo "# TODO: Fetch all experiences, remove $exp_id, re-send full list via UpdateWorkExperience"
  echo "# This is how Indeed's GraphQL API handles deletions"
}
