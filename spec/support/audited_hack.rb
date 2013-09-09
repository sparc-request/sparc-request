# Ensure that the Sweeper after method gets called even when there is an
# exception.
# 
# https://github.com/collectiveidea/audited/issues/146

ActionController::Base.class_eval do
  around_filter do |controller, &block|
    begin
      block.call
    ensure
      Audited::Sweeper.instance.after(controller)
    end
  end
end
