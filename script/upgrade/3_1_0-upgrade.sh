echo "Running 3.0.0b rake tasks"

echo "Restore service requester IDs"
bin/rake data:restore_service_requester_id

echo "Fix historical epic queues"
bin/rake data:fix_historical_epic_queues
