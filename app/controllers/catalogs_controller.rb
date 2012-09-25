class CatalogsController < ApplicationController
  def update_description
    @organization = Organization.find(params[:id])
  end
end
