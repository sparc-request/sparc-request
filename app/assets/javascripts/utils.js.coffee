# Assert
# -----
# catch bad things, be nice with a message.
assert = (v, msg) ->
  unless(v)
    throw new Error(msg)