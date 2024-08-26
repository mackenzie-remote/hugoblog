#!/bin/bash
set -euo pipefail

ROBOTS_TXT="hugoblog/public/robots.txt"
ETAG_FILE="robots.txt.etag"
URL="https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/main/robots.txt"

CURL_ARGS="-fsSL --etag-save $ETAG_FILE --etag-compare $ETAG_FILE -o $ROBOTS_TXT -w "%{http_code}" $URL"

if [[ "$(curl $CURL_ARGS)" == "200" ]]; then
  echo "Updated robots.txt"
  gzip -v -k -f --best $ROBOTS_TXT
  brotli -v -k -f --best $ROBOTS_TXT
fi
