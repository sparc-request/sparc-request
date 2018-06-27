echo "Running 2.0.5 data migrations"

echo "Update protocol filters"
bin/rake data:update_protocol_filters
echo "Replace arm name special characters"
bin/rake data:replace_arm_name_special_characters
