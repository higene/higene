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
    slice_size = 5000
    n = 1
    records = []

    Gff.parse params[:file].path do |record|
      records << record
    end

    records.each_slice(slice_size) do |slice|
      Sequence.connection.batch do
        slice.each do |record|
          if record.attributes.id.nil?
            record.attributes.id = [record.type, n].join "."
            n += 1
          end

          Location.create workspace_id: @current_workspace.id,
                          query: record.attributes.id,
                          source: record.source,
                          start: record.start,
                          end: record.end,
                          score: record.score,
                          strand: record.strand,
                          phase: record.phase,
                          reference: record.seqid

          unless record.attributes.parent.nil?
            Sequence.connection.execute(%(
              UPDATE sequences
                 SET children = children + {'#{record.attributes.id}'}
               WHERE workspace_id = '#{@current_workspace.id}'
                 AND name = '#{record.attributes.parent}'
            ))
            Sequence.connection.execute(%(
              UPDATE sequences
                 SET parents = parents + {'#{record.attributes.parent}'}
               WHERE workspace_id = '#{@current_workspace.id}'
                 AND name = '#{record.attributes.id}'
            ))
          end
        end
      end
    end
    render json: {}
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
