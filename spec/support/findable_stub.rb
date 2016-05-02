# Allows a stubbed object to be found.
# For example:
# line_item = findable_stub(LineItem) { build_stubbed(:line_item) }
# expect(LineItem.find(line_item.id)).to eq(line_item)
#
# @param [Class] klass Eg. LineItem, SubServiceRequest, etc.
# @param block Block that produces the stubbed object. Must respond to #id.
def findable_stub(klass, &block)
  obj = block.call
  allow(klass).to receive(:find).
    with(obj.id).
    and_return(obj)
  allow(klass).to receive(:find).
    with(obj.id.to_s).
    and_return(obj)
  obj
end
