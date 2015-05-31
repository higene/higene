require 'parser/gff'

class SequencesController < ApplicationController
  before_action :authenticate_user!
  before_action :current_workspace, only: [:index, :create]
  include Gff

  def index
    sequence = Sequence.where(workspace: @current_workspace)
    render json: sequence[0..10]
  end

  def new
  end

  def create
    Gff.parse params[:file].path do |record|
      sequence = Sequence.find_or_initialize_by workspace: @current_workspace,
                                                name: record.attributes.id
      sequence.type = record.type
      sequence.update!
      reference = Sequence.find_or_create_by workspace: @current_workspace,
                                             name: record.seqid

      location = Location.find_or_initialize_by source: record.source,
                                                start: record.start,
                                                end: record.end,
                                                score: record.score,
                                                strand: record.strand,
                                                phase: record.phase,
                                                sequence: sequence,
                                                reference: reference

      if record.attributes.parent.nil?
        location.save!
      else
        parent = Sequence.find_or_initialize_by workspace: @current_workspace,
                                                name: record.attributes.parent
        location.parents.push(parent)
        parent.children.push(location)
      end
    end
  end

  def current_workspace
    workspace = Workspace.where(id: params[:workspace_id]).first
    unless workspace.nil?
      member = Member.where(user: current_user, workspace: workspace)
      unless member.nil?
        @current_workspace = workspace
        return
      end
    end

    fail "Invalid workspace ID: #{params[:workspace_id]}."
  end
end
