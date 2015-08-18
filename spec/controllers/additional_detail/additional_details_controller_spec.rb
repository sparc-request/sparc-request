require 'spec_helper'

describe AdditionalDetail::AdditionalDetailsController do

  it 'index should show grid' do
    get(:index) 
    #assigns(:protocol).should eq @protocol
    response.should render_template("index")
    expect(response.status).to eq(200)
  end
end
