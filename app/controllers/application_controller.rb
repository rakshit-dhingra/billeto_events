class ApplicationController < ActionController::Base
  before_action :set_current_user

  private

  def set_current_user
    token = session[:clerk_token] || request.headers["Authorization"]&.split(" ")&.last
    return unless token

    @current_user_id = Clerk::SDK.new.verify_token(token)&.dig("sub")
  rescue Clerk::Errors::TokenVerificationError
    nil
  end

  def current_user_id
    @current_user_id
  end

  def require_authentication!
    unless current_user_id
      redirect_to sign_in_path, alert: "Please sign in to vote."
    end
  end
end