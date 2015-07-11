class HomeController < ApplicationController
  def index
    redirect_to domains_path
  end
end