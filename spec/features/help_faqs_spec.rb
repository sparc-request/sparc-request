require 'rails_helper'

RSpec.feature "Help/FAQs", js: true do
  before :each do
    visit root_path
  end

  describe 'clicking the button' do

    it 'should take user to SPARC FAQ link' do
    	find(:xpath, "//a[@href='http://academicdepartments.musc.edu/sctr/sparc_request/faq.html']").click
    end
  end
end