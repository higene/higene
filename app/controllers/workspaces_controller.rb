class WorkspacesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_workspace, only: [:show, :edit, :update, :destroy]
  before_action :workspace_params, only: [:update]

  def new
    @workspace = Workspace.new
  end

  def create
    member = Member.new(role: :owner, user: current_user)
    @workspace = Workspace.new name: params[:workspace][:name],
                               description: params[:workspace][:description],
                               members: [member]
    if @workspace.valid?
      @workspace.save!
      member.save!
      redirect_to workspaces_url and return
    end

    render :new
  end

  def show
  end

  def edit
  end

  def update
    if @member.role == "owner"
      if @workspace.update workspace_params
        flash.notice = "The workspace #{@workspace.name} was updated successfully."
      else
        flash.alert = "The workspace #{@workspace.name} updated failed."
      end
    else
      flash.alert = "You don't have the permission to do that."
    end

    redirect_to workspaces_url
  end

  def destroy
    if @member.role == "owner"
      @workspace.destroy
      flash.notice = "The workspace #{@workspace.name} was removed successfully."
    else
      flash.alert = "You don't have the permission to do that."
    end
    redirect_to workspaces_url
  end

  def index
    members = Member.where(user: current_user)
    @workspaces = members.collect(&:workspace).sort! do |a, b|
      b.updated_at <=> a.updated_at
    end
  end

  private

  def find_workspace
    @member = Member.find_by(user: current_user, workspace_id: params[:id])
    @workspace = @member.workspace
  end

  def workspace_params
    params.require(:workspace).permit :name,
                                      :description
  end
end
