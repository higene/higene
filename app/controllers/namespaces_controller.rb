class NamespacesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_namespace, only: [:show, :update, :destroy]
  before_action :find_namespaces, only: [:index]
  before_action :find_workspace, only: [:create]
  respond_to :json

  def create
    @namespace = Namespace.new workspace: @workspace,
                               name: params[:name]
    if @namespace.valid?
      @namespace.save!
      render json: @namespace and return
    end

    render json: error(@namespace.errors), status: :bad_request
  end

  def show
    render json: @namespace
  end

  def update
    if @namespace.update name: params[:name]
      render json: @namespace and return
    end

    render json: error(@namespace.errors), status: :bad_request
  end

  def destroy
    if @namespace.update trashed: true
      render json: @namespace and return
    end

    render json: error(@namespace.errors), status: :bad_request
  end

  def index
  end

  private

  def find_workspace
    @member = Member.find_by user: current_user,
                             workspace_id: params[:workspace_id]
    if @member
      @workspace = @member.workspace
    else
      render json: error("invalid workspace"),
             status: :bad_request and return
    end
  end

  def find_namespace
    find_workspace
    return unless @workspace

    @namespace = Namespace.find_by(id: params[:id],
                                   workspace: @workspace,
                                   trashed: false)
    unless @namespace
      render(json: error("invalid namespace"),
             status: :bad_request) and return
    end
  end

  def find_namespaces
    find_workspace
    @namespaces = Namespace.where(workspace: @workspace,
                                  trashed: false)
  end
end
