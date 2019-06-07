#! /usr/bin/env sh

set -o nounset
set -e

echo "Running 2.0.0 data migrations"

echo "Remove duplicate past status"
bin/rake remove_duplicate_past_status
echo "fix OTF service associtaions"
bin/rake fix_otf_service_associations
echo "remove invalid identities"
bin/rake data:remove_invalid_identities
echo "Replace arm name special characters"
bin/rake data:replace_arm_name_special_characters
echo "Add service request to dashboard protocols"
bin/rake add_service_request_to_dashboard_protocols
echo "Fix missing ssr ids"
bin/rake data:fix_missing_ssr_ids

