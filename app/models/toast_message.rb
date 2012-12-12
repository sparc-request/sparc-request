class ToastMessage < ActiveRecord::Base
  belongs_to :sender, :class_name => 'Identity', :foreign_key => 'from'
  belongs_to :recipient, :class_name => 'Identity', :foreign_key => 'to'

  attr_accessible :from
  attr_accessible :to
  attr_accessible :sending_class
  attr_accessible :sending_class_id
  attr_accessible :message

  def sending_object
    self.sending_class.constantize.send(:find, self.sending_class_id)
  end
end
