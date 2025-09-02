#!/bin/bash

# AWS CloudWatch Log Downloader and Scanner
# Author: Daniel Chisasura
# This script downloads logs and searches for suspicious activity.

# --- CONFIGURATION ---
LOG_GROUP_NAME="/aws/ec2/my-instance-logs" # CHANGE to your target log group
KEYWORD_TO_FIND="Unauthorized"             # CHANGE to a keyword like "Failed", "Error", etc.
OUTPUT_FILE="downloaded_logs.txt"

# --- SCRIPT LOGIC ---

echo "☁️  Starting AWS CloudWatch log download..."
echo "Log Group: $LOG_GROUP_NAME"

# Calculate timestamps for the last 24 hours.
# This uses the 'date' command compatible with Linux. For macOS, use `date -v-1d +%s000`.
START_TIME=$(date --date="24 hours ago" +%s000)
END_TIME=$(date +%s000)

# Use the AWS CLI to get log events.
aws logs get-log-events \
    --log-group-name "$LOG_GROUP_NAME" \
    --start-time "$START_TIME" \
    --end-time "$END_TIME" \
    --output text \
    --query 'events[].message' > "$OUTPUT_FILE"

# Check if the AWS CLI command succeeded.
if [ $? -ne 0 ]; then
    echo "🚫 Error downloading logs. Check your AWS config, permissions, and log group name."
    exit 1
fi

echo "Log download complete. Saved to $OUTPUT_FILE"
echo "------------------------------------------------"
echo "🔍 Scanning logs for keyword: '$KEYWORD_TO_FIND'"

# Use 'grep' to find the keyword in the downloaded file.
if grep -i --color=always "$KEYWORD_TO_FIND" "$OUTPUT_FILE"; then
    echo "🚨 ALERT: Suspicious keyword '$KEYWORD_TO_FIND' found in logs."
else
    echo "✅ No suspicious keywords found."
fi