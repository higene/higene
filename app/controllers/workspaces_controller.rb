class WorkspacesController < ApplicationController
  before_action :authenticate_user!

  def index
    workspaces = Workspace.where("members.user" => current_user.id)
    render json: workspaces
  end

  def new
  end

  def create
    member = Member.new(role: :owner, user: current_user)
    workspace = Workspace.new(name: params[:name], members: [member])
    member.save!
    workspace.save!
    render json: workspace
  end
end
