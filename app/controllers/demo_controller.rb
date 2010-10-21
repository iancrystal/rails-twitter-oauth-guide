require 'oauth'
require 'json'

class DemoController < ApplicationController

  before_filter :login_required, :except => [ :callback, :signout, :index, :show_guide ]

  def callback
    request_token = OAuth::RequestToken.new(session[:consumer], session[:request_token], session[:request_token_secret])
    session[:access_token] = request_token.get_access_token( :oauth_verifier => params[:oauth_verifier] )
    redirect_to url_for(:controller => "demo", :action => "index")
  end

  def index
    session[:credentials] = get_credentials if session[:access_token]
  rescue => err
    flash.now[:error] = err
  end

  def signin
    # the before_filter :login_required will be invoked
  end

  def signout
    session[:access_token] = session[:credentials] = nil
    flash[:notice] = "You have been logged out."
    redirect_to root_url
  end


  def update_status
    response = session[:access_token].post('/statuses/update.json', {:status => params[:status_message] })
    case response
    when Net::HTTPSuccess
      flash[:notice] = 'status update sent'
    else
      flash[:error] = 'error in updating the status'
    end
    redirect_to root_path
  end

  def show_tweets
    if (request.xhr?)
      response = session[:access_token].get('/statuses/friends_timeline.json')
      case response
      when Net::HTTPSuccess
        @tweets=JSON.parse(response.body)
        if (@tweets.is_a? Array)
          render :partial => 'demo/tweet', :collection => @tweets, :layout => false
        else
          raise 'unexpected response in getting tweets' 
        end 
      else
        raise 'error in getting tweets'
      end
    else
      raise 'method only supporting XmlHttpRequest'
    end
  rescue => err
    render(:text => err)
  end

  def show_guide
    render :partial => 'demo/show_guide', :layout => false
  end

protected

  def login_required
    return if session[:access_token]
    session[:consumer] = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET, { :site=> TWITTER_SITE })
    oauth_callback = OAUTH_CALLBACK
    request_token = session[:consumer].get_request_token(:oauth_callback => oauth_callback)
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    # redirect to tweeter login page
    redirect_to request_token.authorize_url
  rescue => err
    logger.error err
  end

  def get_credentials
    # Twitter REST API Method: account verify_credentials
    response = session[:access_token].get('/account/verify_credentials.json')
    case response
    when Net::HTTPSuccess
      credentials=JSON.parse(response.body)
      raise "unexpected response" unless (credentials.is_a? Hash)
      credentials
    else
      raise 
    end
  rescue => err
    logger.error "Exception in verify_credentials: #{err}"
    raise
  end

end

