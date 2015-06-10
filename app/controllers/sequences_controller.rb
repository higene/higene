require 'parser/gff'
require 'cql'

class SequencesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_workspace, only: [:new, :index, :create]
  before_action :find_workspaces, only: [:new]

  def index
    limit = params[:limit] || 10
    after = params[:after]

    if after.nil?
      @sequences = Sequence.where(workspace_id: @current_workspace.id)
                   .first(limit)
    else
      @sequences = Sequence.where(workspace_id: @current_workspace.id)
                   .after(after).first(limit)
    end
  end

  def new
    @formats = {
      gff: "Generic Feature Format (gff)",
      gtf: "General Transfer Format (gtf)",
      fasta: "FASTA Format (fasta)"
    }

    @workspaces
  end

  def create
    slice_size = 1000
    records = []

    Gff.parse params[:file].path do |record|
      if record.attributes.id.nil?
        record.attributes.id = [
          record.seqid,
          record.type,
          record.start,
          record.end
        ].join "."
      end
      records << record
    end

    records.each_slice(slice_size) do |slice|
      cmd = ['BEGIN BATCH ']
      slice.each do |record|
        cmd << %(
          INSERT INTO #{Location.table_name}
            (#{Location.column_names.join(',')})
          VALUES (
            #{CQL.quote(@current_workspace.id.to_s)},
            #{CQL.quote(record.seqid)},
            #{CQL.quote(record.type)},
            #{CQL.quote(record.start)},
            #{CQL.quote(record.end)},
            #{CQL.quote(record.source)},
            #{CQL.quote(record.attributes.id)},
            #{CQL.quote(record.score)},
            #{CQL.quote(record.strand)},
            #{CQL.quote(record.phase)}
          )
        ;).squish

        cmd << %(
          INSERT INTO #{Sequence.table_name}
            (workspace_id, name, type)
          VALUES (
            #{CQL.quote(@current_workspace.id.to_s)},
            #{CQL.quote(record.attributes.id)},
            #{CQL.quote(record.type)}
          )
        ;).squish

        unless record.attributes.parent.nil?
          cmd << %(
            UPDATE #{Sequence.table_name}
            SET parents = parents + {#{CQL.quote(record.attributes.parent)}}
            WHERE workspace_id = '#{@current_workspace.id}'
            AND name = #{Cequel::Type.quote(record.attributes.id)}
          ;).squish

          cmd << %(
            UPDATE #{Sequence.table_name}
            SET children = children + {#{CQL.quote(record.attributes.id)}}
            WHERE workspace_id = #{CQL.quote(@current_workspace.id.to_s)}
            AND name = #{CQL.quote(record.attributes.parent)}
          ;).squish
        end
      end
      cmd << "APPLY BATCH;"
      Sequence.connection.execute(cmd.join)
    end
    redirect_to workspace_sequences_url
  end

  def find_workspace
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

  def find_workspaces
    @workspaces = Member.where(user: current_user).collect(&:workspace)
  end
end
