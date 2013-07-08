require 'spec_helper'

describe Payment do
  it{ should validate_presence_of :date_submitted }
  it{ should validate_numericality_of :amount_invoiced }
  it{ should validate_numericality_of :amount_received }
  it{ should allow_value(nil).for(:amount_received) }

  describe '#formatted_date_recieved' do
  	let(:payment){ Payment.new( date_received: Date.new(2013, 12, 30) ) }
  	subject{ payment.formatted_date_received }

  	it{ should == '12/30/2013' }
  end

  describe '#formatted_date_recieved=' do
  	it "accepts formatted input" do
  		p = Payment.new
  		p.formatted_date_received = "12/30/2013"
  		p.date_received.should == Date.new(2013, 12, 30)
  	end
  end

end
