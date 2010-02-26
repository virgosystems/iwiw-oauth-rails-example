require 'json'
require 'oauth/consumer'

# mixin for controller

module OauthSystem

  class GeneralError < StandardError
  end
  class RequestError < OauthSystem::GeneralError
  end
  class NotInitializedError < OauthSystem::GeneralError
  end

  # controller method to handle logout
  def signout
    self.current_user = false 
    flash[:notice] = "You have been logged out."
    redirect_to root_url
  end
  
  # controller method to handle iwiw callback (expected after login_by_oauth invoked)
  def callback
    self.oauth_agent.exchange_request_for_access_token( session[:request_token], 
                                                  session[:request_token_secret], 
                                                  params[:oauth_verifier] )

    user_info = self.oauth_agent.get_owner['entry']

    raise OauthSystem::RequestError unless user_info['id']
    
    # We have an authorized user, save the information to the database.
    @iwiw_user = IwiwUser.find_by_user_id(user_info['id'])

    if @iwiw_user
      @iwiw_user.token = self.oauth_agent.access_token.token
      @iwiw_user.secret = self.oauth_agent.access_token.secret
      @iwiw_user.anonymous = user_info['anonymous'] 
    else
      @iwiw_user = IwiwUser.new({ 
        :user_id => user_info['id'],
        :screen_name => user_info['screen_name'],
        :token => self.oauth_agent.access_token.token,
        :secret => self.oauth_agent.access_token.secret,
        :anonymous => user_info['anonymous'],
        :thumbnail_url => user_info['thumbnailUrl']
      })

    end
    
    @iwiw_user.save!

    self.current_user = @iwiw_user

    redirect_to iwiw_user_path( @iwiw_user.id )
    
  rescue => exc
    # The user might have rejected this application. Or there was some other error during the request.
    RAILS_DEFAULT_LOGGER.error "Failed to get user info via OAuth (#{exc})"

    flash[:error] = "iWiW API failure (account login)"
    redirect_to root_url
  end

protected
  
    # Inclusion hook to make #current_user, #logged_in? available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in? if base.respond_to? :helper_method
    end

    def oauth_agent( user_token = nil, user_secret = nil )
      self.oauth_agent = IwiwOauth.new( user_token, user_secret ) if user_token && user_secret
      self.oauth_agent = IwiwOauth.new( ) unless @oauth_agent
      @oauth_agent ||= raise OauthSystem::NotInitializedError
    end

    def oauth_agent=(new_agent)
      @oauth_agent = new_agent || false
    end
  
    # Accesses the current user from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (login_from_session) unless @current_user == false
    end
  
    # Sets the current_user, including initializing the OAuth agent
    def current_user=(new_user)
      if new_user
        session[:user_id] = new_user.user_id
        self.oauth_agent( user_token = new_user.token, user_secret = new_user.secret )
        @current_user = new_user
      else
        session[:request_token] = session[:request_token_secret] = session[:user_id] = nil 
        self.oauth_agent = false
        @current_user = false
      end
    end

    def oauth_login_required
      logged_in? || login_by_oauth
    end

    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !!current_user
    end

    def login_from_session
      self.current_user = IwiwUser.find_by_user_id(session[:user_id]) if session[:user_id]
    end

    def login_by_oauth

      request_token = self.oauth_agent.get_request_token

      session[:request_token] = request_token.token
      session[:request_token_secret] = request_token.secret

      redirect_to request_token.authorize_url
    rescue Exception => exc

      # The user might have rejected this application. Or there was some other error during the request.
      RAILS_DEFAULT_LOGGER.error "Failed to login via OAuth"
      flash[:error] = "iWiW API failure (account login)"
      redirect_to root_url
    end

end
