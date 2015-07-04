class WelcomeController < ApplicationController
  def index
    redirect_to workspaces_url and return if user_signed_in?
  end
end
