class NetworkMembershipsController < ApplicationController

  include Seek::BreadCrumbs

  before_filter :find_network
  before_filter :find_membership, :only => [:update, :destroy]

  # GET /network_memberships
  # GET /network_memberships.json
  def index
    @network_memberships = NetworkMembership.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @network_memberships }
    end
  end

  # POST /network_memberships
  # POST /network_memberships.json
  def create
    @network_membership = NetworkMembership.new(params[:network_membership])

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

    respond_to do |format|
      if @network_membership.update_attributes(params[:network_membership])
        format.html { redirect_to network_members_path(@network), notice: 'Membership was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @network_membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /network_memberships/1
  # DELETE /network_memberships/1.json
  def destroy
    @network_membership.destroy

    respond_to do |format|
      format.html { redirect_to network_members_path(@network) }
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
end
