require 'json'
require 'oauth'

class IwiwOauth

  class GeneralError < StandardError
  end
  class APIError < IwiwOauth::GeneralError
  end
  class UnexpectedResponse < IwiwOauth::APIError
  end  
  class APILimitWarning < IwiwOauth::APIError
  end
  

  # initialize the oauth consumer, and also access token if user_token and user_secret provided
  def initialize( user_token = nil, user_secret = nil )
    @consumer = OAuth::Consumer.new( IWIW_OAUTH_KEY, IWIW_OAUTH_SECRET, { 
      :site => IWIW_OAUTH_SITE,
      :request_token_path => '/social/oauth/requestToken',
      :access_token_path => '/social/oauth/accessToken',
      :authorize_url => IWIW_OAUTH_AUTHORIZE_URL
        })
    @access_token = OAuth::AccessToken.new( @consumer, user_token, user_secret ) if user_token && user_secret
  end  
  
  # returns the consumer
  def consumer
    @consumer
  end
  
  # returns the access token, also initializes new access token if user_token and user_secret provided
  def access_token( user_token = nil, user_secret = nil )
    if user_token and user_secret 
      @access_token = OAuth::AccessToken.new( self.consumer, user_token, user_secret )
    else
      @access_token
    end
  end

  def access_token=(new_access_token)
    @access_token = new_access_token || false
  end


  # when the callback has been received, exchange the request token for an access token
  def exchange_request_for_access_token( request_token, request_token_secret, oauth_verifier )
    #request_token = self.request_token( request_token, request_token_secret )
    request_token = OAuth::RequestToken.new(self.consumer, request_token, request_token_secret)
    #Exchange the request token for an access token. this may get 401 error
    self.access_token = request_token.get_access_token( :oauth_verifier => oauth_verifier )
  rescue => err
    puts "Exception in exchange_request_for_access_token: #{err}"
    raise err
  end

  # gets a request token to be used for the authorization request
  def get_request_token( oauth_callback = IWIW_OAUTH_CALLBACK )
    self.consumer.get_request_token( :oauth_callback => oauth_callback )
  end

  # {{{ iwiw API methods

  def get_owner
    response = access_token.get('/social/connect/rest/people/@me/@self')
    
    case response
    when Net::HTTPSuccess
      user_hash = JSON.parse(response.body)

      raise IwiwOauth::UnexpectedResponse unless user_hash.is_a? Hash

      user_hash
    else
      raise IwiwOauth::APIError
    end
  rescue => err
    puts "Exception in get_owner: #{err}"
    raise err
  end

  def iwiw_api options = { 'method' => 'get', 'path' => '/social/connect/rest/people/@me/@self',
    'params' => {}}

    response = case options['method']
               when 'get'
                 http_params = options['params'].map{|k,v| "#{k}=#{v}"}.join('&')
                 access_token.get("#{options['path']}?#{http_params}")
               when 'put'
                 access_token.put(options['path'],options['params'])
               else
                 access_token.post(options['path'],options['params'])
               end

    if response.is_a? Net::HTTPSuccess
      return response_hash = JSON.parse(response.body)
    end

    response

  rescue => err
    puts "Exception in iwiw_api method call: #{err}"
    raise err
  end

  # }}}


end
