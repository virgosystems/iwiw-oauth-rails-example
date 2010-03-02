class IwiwUsersController < ApplicationController

  include OauthSystem

  before_filter :oauth_login_required, :except => [ :callback, :signout, :index ]

  def call_iwiw_api
    response = unless oauth_call_params = params[:oauth_iwiw_api]
                 'Invalid input'
               else
                 oauth_call_params[:params] = JSON.parse(oauth_call_params[:params])

                 self.oauth_agent.iwiw_api( oauth_call_params )
               end

    unless response.is_a? Net::HTTPSuccess
      response = "class: #{resonse.class} code: #{response.code} status: #{ response.status }"
    end

    respond_to do |format|
      format.json { render :json => response }
    end
  end

  # GET /iwiw_users
  # GET /iwiw_users.xml
  def index
    @iwiw_users = IwiwUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @iwiw_users }
    end
  end

  # GET /iwiw_users/1
  # GET /iwiw_users/1.xml
  def show
    @iwiw_user = IwiwUser.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @iwiw_user }
    end
  end

  # GET /iwiw_users/new
  # GET /iwiw_users/new.xml
  def new
    @iwiw_user = IwiwUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @iwiw_user }
    end
  end

  # GET /iwiw_users/1/edit
  def edit
    @iwiw_user = IwiwUser.find(params[:id])
  end

  # POST /iwiw_users
  # POST /iwiw_users.xml
  def create
    @iwiw_user = IwiwUser.new(params[:iwiw_user])

    respond_to do |format|
      if @iwiw_user.save
        flash[:notice] = 'IwiwUser was successfully created.'
        format.html { redirect_to(@iwiw_user) }
        format.xml  { render :xml => @iwiw_user, :status => :created, :location => @iwiw_user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @iwiw_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /iwiw_users/1
  # PUT /iwiw_users/1.xml
  def update
    @iwiw_user = IwiwUser.find(params[:id])

    respond_to do |format|
      if @iwiw_user.update_attributes(params[:iwiw_user])
        flash[:notice] = 'IwiwUser was successfully updated.'
        format.html { redirect_to(@iwiw_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @iwiw_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /iwiw_users/1
  # DELETE /iwiw_users/1.xml
  def destroy
    @iwiw_user = IwiwUser.find(params[:id])
    @iwiw_user.destroy

    respond_to do |format|
      format.html { redirect_to(iwiw_users_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def init_user
		begin
			user_id = params[:id] unless params[:id].nil?
			user_id = params[:user_id] unless params[:user_id].nil?

			@iwiw_user = IwiwUser.find_by_user_id( user_id )

			raise ActiveRecord::RecordNotFound unless @iwiw_user
		rescue
			flash[:error] = 'Sorry, that is not a valid user.'
			redirect_to root_path
			return false
		end
  end
end
