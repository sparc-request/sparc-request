echo "Running 3.0.0b rake tasks"

echo "Import permissible values"
bin/rake import_permissible_values
echo "Restore service requester IDs"
bin/rake data:restore_service_requester_id
