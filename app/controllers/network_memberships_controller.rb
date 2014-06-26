class NetworkMembershipsController < ApplicationController

  before_filter :find_network
  before_filter :find_membership, :only => [:update, :destroy]
  before_filter :admin_required, :only => [:create, :index]
  before_filter :admin_or_membership_required, :only => [:update, :destroy]

  include Seek::BreadCrumbs

  # GET /network_memberships
  # GET /network_memberships.json
  def index
    @network_memberships = @network.memberships

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @network_memberships }
    end
  end

  # POST /network_memberships
  # POST /network_memberships.json
  def create
    @network_membership = NetworkMembership.new(params[:network_membership])
    @network_membership.network = @network

    respond_to do |format|
      if @network_membership.save
        format.html { redirect_to network_members_path(@network), notice: 'Membership invitation has been sent.' }
        format.json { render json: @network_membership, status: :created, location: @network_membership }
      else
        format.html { render action: "new" }
        format.json { render json: @network_membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /network_memberships/1
  # PUT /network_memberships/1.json
  def update
    @network_membership = NetworkMembership.find(params[:id])

    if @network_membership.accepted?
      message = 'Membership updated.'
    else
      message = 'Invitation accepted.'
    end

    respond_to do |format|
      if @network_membership.update_attributes(params[:network_membership])
        format.html { redirect_to :back, notice: message }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, error: 'Membership not updated.' }
        format.json { render json: @network_membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /network_memberships/1
  # DELETE /network_memberships/1.json
  def destroy
    if @network_membership.accepted?
      message = 'Membership removed.'
    elsif current_user.person == @network_membership.person
      message = 'Invitation declined.'
    else
      message = 'Invitation revoked.'
    end

    @network_membership.destroy

    respond_to do |format|
      format.html { redirect_to :back, notice: message }
      format.json { head :no_content }
    end
  end

  private

  def find_network
    @network = Network.find(params[:network_id])
  end

  def find_membership
    @network_membership = NetworkMembership.find(params[:id])
  end

  def admin_required
    unless @network.admin?(current_user) || @network.owner?(current_user)
      respond_to do |format|
        format.html { redirect_to network_url(@network), error: "You are not authorized to perform this action." }
      end
    end
  end

  def admin_or_membership_required
    unless @network_membership.person.user == current_user
      admin_required
    end
  end

end
