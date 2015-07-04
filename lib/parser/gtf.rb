module Parser
  module Gtf
    class Record
      attr_accessor :seqid,
                    :source,
                    :type,
                    :start,
                    :end,
                    :score,
                    :strand,
                    :phase,
                    :attributes

      def self.ncol
        9
      end

      def initialize(options)
        options.each do |key, value|
          send "#{key}=", value
        end
      end
    end

    class Attribute
      attr_accessor :id,
                    :gene_id,
                    :transcript_id
    end

    def self.convert_type(value, callback = nil)
      if value == "."
        nil
      else
        if callback.nil?
          value
        else
          value.send callback
        end
      end
    end

    def self.parse(filename)
      File.open filename do |f|
        f.each do |line|
          line.strip!
          next if line.start_with?("#") || line.empty?
          data = line.split "\t"
          if data.length != Record.ncol
            fail "Wrong number of columns (#{data.length} for #{Record.ncol})."
          end

          attribute = Attribute.new
          data.last.split(";").each do |attr|
            key, value = attr.match(/(\w+) "(.+)"/).captures
            if attribute.respond_to? key.downcase
              attribute.send "#{key.downcase}=", value
            end
            attribute.id = value if key == "#{data[2].downcase}_id"
          end

          yield Record.new seqid: convert_type(data[0]),
                           source: convert_type(data[1]),
                           type: convert_type(data[2]),
                           start: convert_type(data[3], :to_i),
                           end: convert_type(data[4], :to_i),
                           score: convert_type(data[5], :to_f),
                           strand: convert_type(data[6]),
                           phase: convert_type(data[7], :to_i),
                           attributes: attribute
        end
      end
    end
  end
end
