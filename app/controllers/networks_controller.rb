class NetworksController < ApplicationController

  include IndexPager
  include Seek::BreadCrumbs

  before_filter :find_assets, :only=>[:index]
  before_filter :find_network, :only => [:show, :edit, :update, :destroy, :leave]
  before_filter :admin_required, :only => [:edit, :update]
  before_filter :owner_required, :only => [:destroy]

  # GET /networks/1
  # GET /networks/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @network }
    end
  end

  # GET /networks/new
  # GET /networks/new.json
  def new
    @network = Network.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @network }
    end
  end

  # GET /networks/1/edit
  def edit
  end

  # POST /networks
  # POST /networks.json
  def create
    @network = Network.new(params[:network])
    @network.owner = current_user.person

    respond_to do |format|
      if @network.save
        format.html { redirect_to @network, notice: "#{t('network')} was successfully created." }
        format.json { render json: @network, status: :created, location: @network }
      else
        format.html { render action: "new" }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /networks/1
  # PUT /networks/1.json
  def update
    respond_to do |format|
      if @network.update_attributes(params[:network])
        format.html { redirect_to @network, notice: "#{t('network')} was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.json
  def destroy
    @network.destroy

    respond_to do |format|
      format.html { redirect_to networks_url }
      format.json { head :no_content }
    end
  end

  def leave
    @network_membership = @network.memberships.where(:person_id => current_user.person_id).first

    if @network_membership
      @network_membership.destroy
      flash[:notice] = "You have cancelled your membership."
    else
      flash[:error] = "You are not a member of this network."
    end

    respond_to do |format|
      format.html { redirect_to network_url(@network) }
      format.json { head :no_content }
    end
  end

  private

  def find_network
    @network = Network.find(params[:id])
  end

  def admin_required
    unless @network.admin?(current_user) || @network.owner?(current_user)
      respond_to do |format|
        format.html { redirect_to network_url(@network), error: "Only administrators may perform this action." }
      end
    end
  end

  def owner_required
    unless @network.owner?(current_user)
      respond_to do |format|
        format.html { redirect_to network_url(@network), error: "Only the network owner may perform this action." }
      end
    end
  end

end
