json.total @total
json.rows(@identities) do |identity|
  json.name            display_name(identity)
  json.institution     identity.institution
  json.email           identity.email
  json.created_at      format_date(identity.created_at)
  json.last_sign_in_at format_date(identity.current_sign_in_at)
  json.sign_in_count   identity.sign_in_count
  json.actions         identity_actions(identity)
end
