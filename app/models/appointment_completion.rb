class AppointmentCompletion < ActiveRecord::Base
  belongs_to :appointment
  belongs_to :organization
  attr_accessible :completed_date
  attr_accessible :organization_id
  attr_accessible :formatted_completed_date

  def formatted_completed_date
    format_date self.completed_date
  end
  def formatted_completed_date=(d)
    self.completed_date = parse_date(d)
  end

  private

  def format_date(d)
    d.try(:strftime, '%-m/%d/%Y')
  end

  def parse_date(str)
    begin
      Date.strptime(str.to_s.strip, '%m/%d/%Y')  
    rescue ArgumentError => e
      nil
    end
  end
end
