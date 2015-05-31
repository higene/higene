class WorkspacesController < ApplicationController
  before_action :authenticate_user!

  def index
    members = Member.where(user: current_user)
    workspaces = members.collect(&:workspace)
    render json: workspaces
  end

  def new
  end

  def create
    member = Member.new(role: :owner, user: current_user)
    workspace = Workspace.new name: params[:name],
                              description: params[:description],
                              members: [member]
    member.save!
    workspace.save!
    render json: workspace
  end
end
