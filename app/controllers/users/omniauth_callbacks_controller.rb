class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController #ApplicationController

  def twitter
  end

  def facebook
    @user = User.find_for_facebook_oauth request.env["omniauth.auth"]

    session['fb_access_token'] = request.env['omniauth.auth']['credentials']['token']
    if @user.persisted?
    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
    sign_in_and_redirect @user, :event => :authentication
    else
      flash[:notice] = "authentication error"
      redirect_to root_path
    end
  end
end
