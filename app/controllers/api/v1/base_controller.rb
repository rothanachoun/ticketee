class Api::V1::BaseController < ApplicationController
  respond_to :json, :xml

  before_filter :authenticate_user
  before_filter :check_rate_limit
  before_filter :authorize_admin!, :except => [:index, :show]

  private

  def authenticate_user
    @current_user = User.find_by_authentication_token(params[:token])
    unless @current_user
      respond_with({:error => "Token is invalid."})
    end
  end

  def authorize_admin!
    unless @current_user.admin?
      error = { :error => "You must be an admin to do that." }
      warden.custom_failure!
      render params[:format].to_sym => error, :status => 401
    end
  end

  def check_rate_limit
    if @current_user.request_count > 100
      error = { :error => "Rate limit exceeded." }
      respond_with(error, :status => 403)
    else
      @current_user.increment!(:request_count)
    end
  end

  def current_user
    @current_user
  end
end
