class WorkspacesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_workspace, only: [:show, :update, :destroy]
  respond_to :json

  def new
  end

  def edit
  end

  def create
    member = Member.new(role: "owner", user: current_user)
    if member.valid?
      @workspace = Workspace.new name: params[:name],
                                 description: params[:description],
                                 members: [member]
      if @workspace.valid?
        @workspace.save
        member.save
        render json: @workspace and return
      else
        render json: error(@workspace.errors), status: :bad_request
      end
    else
      render json: error(@member.errors), status: :bad_request
    end
  end

  def show
    render json: @workspace
  end

  def update
    if %w(owner editor).include? @member.role
      if @workspace.update name: params[:name],
                           description: params[:description]
        render json: @workspace and return
      else
        render(json: error(@workspace.errors),
               status: :bad_request) and return
      end
    else
      render(json: error("You don't have the permission to do that."),
             status: :bad_request) and return
    end
  end

  def destroy
    if @member.role == "owner"
      @workspace.update trashed: true
      render json: @workspace and return
    else
      render(json: error("You don't have the permission to do that."),
             status: :bad_request) and return
    end
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

    if @member
      @workspace = @member.workspace
    else
      render json: error("invalid workspace"),
             status: :bad_request and return
    end
  end
end
