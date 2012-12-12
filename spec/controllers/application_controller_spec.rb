require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      render :json => { }
    end
  end
end

