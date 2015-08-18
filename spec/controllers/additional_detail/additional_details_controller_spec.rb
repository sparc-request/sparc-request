require 'spec_helper'

describe AdditionalDetail::AdditionalDetailsController do

  it 'index should show grid' do
    get(:index) 
    #assigns(:protocol).should eq @protocol
    response.should render_template("index")
    expect(response.status).to eq(200)
  end
  
  it 'new should show empty form' do
    get(:new) 
    assigns(:additional_detail).should_not be_blank
    response.should render_template("new")
    expect(response.status).to eq(200)
  end
end
