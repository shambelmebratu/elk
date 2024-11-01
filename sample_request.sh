#!/bin/bash

if [ -f .env ]; then
  source .env
else
  echo -e "\e[31m.env file not found!\e[0m"
  exit 1
fi

ENDPOINT="http://localhost:$LOGSTASH_PORT"
AUTH="$LOGSTASH_USER:$LOGSTASH_PASSWORD"
CONTENT_TYPE="Content-Type: application/json"

declare -a services=("payment-gateway" "fraud-detection" "account-management" "investment-platform" "customer-support")

declare -A messages
messages[payment-gateway]="Transaction processed|Payment failed|Refund initiated|New payment method added|Recurring payment set up"
messages[fraud-detection]="Suspicious activity detected|Risk assessment completed|Fraud alert triggered|Transaction blocked|Security rules updated"
messages[account-management]="Account created|Password changed|KYC verification completed|Account balance updated|Beneficiary added"
messages[investment-platform]="Trade executed|Portfolio rebalanced|Dividend received|Investment strategy updated|Market data refreshed"
messages[customer-support]="Ticket created|Chat session initiated|Call logged|Feedback received|Issue escalated"

declare -a severities=("INFO" "WARN" "ERROR")
declare -a eventTags=("security" "transaction" "user" "system" "compliance")
declare -a devices=("mobile" "desktop" "tablet" "smartwatch")
declare -a browsers=("Chrome" "Firefox" "Safari" "Edge" "Opera")
declare -a statuses=("success" "failure" "pending" "cancelled" "in_progress")

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

i=1
while true
do
  RANDOM_SERVICE=${services[$RANDOM % ${#services[@]} ]}
  IFS='|' read -ra SERVICE_MESSAGES <<< "${messages[$RANDOM_SERVICE]}"
  RANDOM_MESSAGE=${SERVICE_MESSAGES[$RANDOM % ${#SERVICE_MESSAGES[@]} ]}
  RANDOM_SEVERITY=${severities[$RANDOM % ${#severities[@]} ]}
  RANDOM_TAG=${eventTags[$RANDOM % ${#eventTags[@]} ]}
  RANDOM_DEVICE=${devices[$RANDOM % ${#devices[@]} ]}
  RANDOM_BROWSER=${browsers[$RANDOM % ${#browsers[@]} ]}
  RANDOM_STATUS=${statuses[$RANDOM % ${#statuses[@]} ]}

  RANDOM_IP="192.168.1.$((RANDOM % 255))"
  LOCATION="City $((RANDOM % 100)), Country $((RANDOM % 10))"

  JSON_PAYLOAD=$(cat <<EOF
{
  "service": "$RANDOM_SERVICE",
  "severity": "$RANDOM_SEVERITY",
  "message": "$RANDOM_MESSAGE",
  "tags": ["$RANDOM_TAG"],
  "extra": {
    "ipAddress": "$RANDOM_IP",
    "deviceType": "$RANDOM_DEVICE",
    "browser": "$RANDOM_BROWSER",
    "location": "$LOCATION",
    "status": "$RANDOM_STATUS",
    "environment": "$LOG_ENVIRONMENT"
  }
}
EOF
  )

  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "$CONTENT_TYPE" -u $AUTH $ENDPOINT -d "$JSON_PAYLOAD")

  echo -e "${BLUE}Log Entry #$i${NC}"
  echo -e "${BLUE}Service:   ${YELLOW}$RANDOM_SERVICE${NC}"
  echo -e "${BLUE}Message:   ${GREEN}$RANDOM_MESSAGE${NC}"
  echo -e "${BLUE}Severity:  ${RED}$RANDOM_SEVERITY${NC}"
  echo -e "${BLUE}Tag:       ${YELLOW}$RANDOM_TAG${NC}"
  echo -e "${BLUE}Device:    $RANDOM_DEVICE${NC}"
  echo -e "${BLUE}Browser:   $RANDOM_BROWSER${NC}"
  echo -e "${BLUE}Status:    $RANDOM_STATUS${NC}"
  echo -e "${BLUE}IP:        $RANDOM_IP${NC}"
  echo -e "${BLUE}Location:  $LOCATION${NC}"
  echo -e "${BLUE}Response:  ${RESPONSE}${NC}"
  echo -e "${BLUE}--------------------${NC}"

  sleep 3
  i=$((i+1))
done