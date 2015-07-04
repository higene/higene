require 'parser'
require 'cql'

class SequencesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_workspace, only: [:new, :index, :create]
  before_action :find_workspaces, only: [:new]
  before_action :pager_params, only: [:index]
  before_action :find_sequence, only: [:show, :download]

  def index
    @type = params[:type]
    q = { workspace_id: @current_workspace.id }
    q.update type: @type if @type

    if !@before.nil?
      @sequences = Sequence.where(q).before(@before).limit(@limit).reverse.to_a.reverse
    elsif !@after.nil?
      @sequences = Sequence.where(q).after(@after).limit(@limit).to_a
    else
      @sequences = Sequence.where(q).first(@limit).to_a
    end

    unless @sequences.empty?
      unless Sequence.where(q).before(@sequences.first.name).limit(1).to_a.empty?
        @previous_url = "#{workspace_sequences_url}?" \
                        "limit=#{@limit}&" \
                        "before=#{CGI.escape(@sequences.first.name)}"
        @previous_url << "&type=#{@type}" if @type
      end
      unless Sequence.where(q).after(@sequences.last.name).limit(1).to_a.empty?
        @next_url = "#{workspace_sequences_url}?" \
                    "limit=#{@limit}&" \
                    "after=#{CGI.escape(@sequences.last.name)}"
        @next_url << "&type=#{@type}" if @type
      end
    end

    cmd = %(
      SELECT type
      FROM sequences
      WHERE workspace_id = #{CQL.quote(@current_workspace.id.to_s)}
    ;).squish

    @type_summary = {}

    records = Sequence.connection.execute(cmd)
    loop do
      records.collect { |x| x["type"] }.each do |type|
        if @type_summary.key? type
          @type_summary[type] += 1
        else
          @type_summary[type] = 1
        end
      end
      if records.last_page?
        break
      else
        records = records.next_page
      end
    end
  end

  def new
    @formats = {
      gff: "Generic Feature Format (gff)",
      gtf: "General Transfer Format (gtf)",
      fasta: "FASTA Format (fasta)",
      xprs: "eXpress Target Abundances (xprs)"
    }

    @workspaces
  end

  def show
    if @sequence.nil?
      flash.alert = "#{@name} does not exist."
      redirect_to :back
    end
  end

  def create
    format = params[:format].downcase

    if respond_to? "create_#{format}", true
      send "create_#{format}"
    else
      fail "Unsupport format."
    end
    flash.notice = "The file #{params[:file].original_filename} was imported successfully."
    redirect_to workspace_sequences_url
  end

  def download
    respond_to do |format|
      format.fasta do
        if @sequence.description.nil?
          data = ">#{@sequence.name}\n#{@sequence.sequence}\n"
        else
          data = ">#{@sequence.name} #{@sequence.description}\n#{@sequence.sequence}\n"
        end
        send_data data, filename: "#{@sequence.name}.fasta"
      end
    end
  end

  private

  def create_gff
    slice_size = 1000
    records = []

    Parser::Gff.parse params[:file].path do |record|
      if record.attributes.id.nil?
        record.attributes.id = [
          record.type,
          record.start,
          record.end,
          record.seqid
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
            #{CQL.quote(record.attributes.parent)},
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

        cmd << %(
          INSERT INTO #{Sequence.table_name}
            (workspace_id, name, type)
          VALUES (
            #{CQL.quote(@current_workspace.id.to_s)},
            #{CQL.quote(record.seqid)},
            'chromosome'
          )
        ;).squish
      end
      cmd << "APPLY BATCH;"
      Sequence.connection.execute(cmd.join)
    end
  end

  def create_gtf
    slice_size = 1000
    records = []

    Parser::Gtf.parse params[:file].path do |record|
      if record.attributes.id.nil?
        record.attributes.id = [
          record.type,
          record.start,
          record.end,
          record.seqid
        ].join "."
      end
      records << record
    end

    transcript_child_types = %w(start_codon stop_codon exon CDS intron)
    records.each_slice(slice_size) do |slice|
      cmd = ['BEGIN BATCH ']
      slice.each do |record|
        if transcript_child_types.include?(record.type) && record.attributes.transcript_id
          parent = record.attributes.transcript_id
        else
          parent = nil
        end

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
            #{CQL.quote(parent)},
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

        cmd << %(
          INSERT INTO #{Sequence.table_name}
            (workspace_id, name, type)
          VALUES (
            #{CQL.quote(@current_workspace.id.to_s)},
            #{CQL.quote(record.seqid)},
            'chromosome'
          )
        ;).squish
      end
      cmd << "APPLY BATCH;"
      Sequence.connection.execute(cmd.join)
    end
  end

  def create_fasta
    slices = []
    slice = []
    slice_max_seqlen = 4 * 1024 * 1024
    slice_seqlen = 0
    Parser::Fasta.parse params[:file].path do |record|
      slice << record
      slice_seqlen += record.sequence.length
      if slice_seqlen > slice_max_seqlen
        slices << slice
        slice_seqlen = 0
        slice = []
      end
    end
    slices << slice unless slice.empty?

    slices.each do |s|
      cmd = ['BEGIN BATCH ']
      s.each do |record|
        cmd << %(
          INSERT INTO #{Sequence.table_name}
            (workspace_id, name, description, sequence)
          VALUES (
            #{CQL.quote(@current_workspace.id.to_s)},
            #{CQL.quote(record.name)},
            #{CQL.quote(record.description)},
            #{CQL.quote(record.sequence)}
          )
        ;).squish
      end
      cmd << "APPLY BATCH;"
      Sequence.connection.execute(cmd.join)
    end
  end

  def create_xprs
    slice_size = 1000
    records = []

    Parser::Xprs.parse params[:file].path do |record|
      records << record
    end

    records.each_slice(slice_size) do |slice|
      cmd = ['BEGIN BATCH ']
      slice.each do |record|
        cmd << %(
          INSERT INTO #{Expression.table_name} (
            workspace_id,
            source,
            condition,
            target,
            fpkm,
            tot_counts,
            uniq_counts,
            eff_counts
          ) VALUES (
            #{CQL.quote(@current_workspace.id.to_s)},
            'eXpress',
            #{CQL.quote(params[:condition_name])},
            #{CQL.quote(record.target_id)},
            #{CQL.quote(record.fpkm)},
            #{CQL.quote(record.tot_counts)},
            #{CQL.quote(record.uniq_counts)},
            #{CQL.quote(record.eff_counts)}
          )
        ;).squish

        cmd << %(
          INSERT INTO #{Sequence.table_name} (
            workspace_id, name
          ) VALUES (
            #{CQL.quote(@current_workspace.id.to_s)},
            #{CQL.quote(record.target_id)}
          )
        ;).squish
      end
      cmd << "APPLY BATCH;"
      Expression.connection.execute(cmd.join)
    end
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

  def pager_params
    @limit = params[:limit].to_i
    @limit = 10 if @limit <= 0 || @limit > 100
    @after = params[:after]
    @before = params[:before]
  end

  def find_sequence
    @name = params[:name] || params[:sequence_name]
    @sequence = Sequence.where(workspace_id: params[:workspace_id], name: @name)
                .limit(1).first
  end
end
