var assert;
assert = function(v, msg) {
  if (!v) {
    throw new Error(msg);
  }
};