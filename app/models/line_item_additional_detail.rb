class LineItemAdditionalDetail < ActiveRecord::Base
  audited
  
  belongs_to :line_item
  belongs_to :additional_detail
  attr_accessible :form_data_json
  
  def service_name 
    return :TestMe
    
  end
  
end
