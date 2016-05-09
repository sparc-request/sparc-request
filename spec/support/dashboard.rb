# Same as stub_controller, but for controllers which inherit from
# Dashboard::BaseController
def log_in_dashboard_identity(opts = {})
  allow(controller).to receive(:authenticate_identity!) do
  end

  allow(controller).to receive(:current_identity) do
    if opts[:id]
      Identity.find_by_id(opts[:id])
    elsif opts[:obj]
      opts[:obj]
    else
      Identity.find_by_id(session[:identity_id])
    end
  end
end
alias :log_in_catalog_manager_identity :log_in_dashboard_identity


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

# Allow (or forbid) access to a Protocol by an identity.
#
# @param identity
# @param protocol
# @param opts Authorization options
# @option opts :can_view (false) Grant view rights to identity
# @option opts :can_edit (false) Grant edit rights to identity
def authorize(identity, protocol, opts = {})
  auth_mock = instance_double(ProtocolAuthorizer,
    can_view?: opts[:can_view].nil? ? false : opts[:can_view],
    can_edit?: opts[:can_edit].nil? ? false : opts[:can_edit])
  allow(ProtocolAuthorizer).to receive(:new).
    with(protocol, identity).
    and_return(auth_mock)
end
