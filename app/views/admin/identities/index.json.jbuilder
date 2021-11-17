json.total @total
json.rows(@identities) do |identity|
  json.name           display_name(identity)
  json.email          identity.email
  json.phone          format_phone(identity.phone)
  json.created_at     format_date(identity.created_at)
  json.actions        identity_actions(identity)
end
