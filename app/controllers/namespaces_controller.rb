class NamespacesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_namespace, only: [:show, :edit, :update, :destroy]
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

    render json: { errors: @namespace.errors }, status: :bad_request
  end

  def show
    render json: @namespace
  end

  def update
    if @namespace.update name: params[:name]
      render json: @namespace and return
    end

    render json: { errors: @namespace.errors }, status: :bad_request
  end

  def destroy
    if @namespace.update trashed: true
      render json: @namespace and return
    end

    render json: { errors: @namespace.errors }, status: :bad_request
  end

  def index
  end

  private

  def find_workspace
    @member = Member.find_by user: current_user,
                             workspace_id: params[:workspace_id]
    @workspace = @member.workspace
  end

  def find_namespace
    find_workspace
    @namespace = Namespace.find_by id: params[:id],
                                   workspace: @workspace
  end

  def find_namespaces
    find_workspace
    @namespaces = Namespace.where(workspace: @workspace)
  end
end
