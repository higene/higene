require 'parser/gff'
require 'cql'

class SequencesController < ApplicationController
  before_action :authenticate_user!
  before_action :current_workspace, only: [:index, :create]

  def index
    sequence = Sequence.where(workspace: @current_workspace)
    render json: sequence[0..10]
  end

  def new
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
