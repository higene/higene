module Parser
  module Fasta
    class Record
      attr_accessor :name,
                    :description,
                    :sequence

      def initialize(options)
        options.each do |key, value|
          send("#{key}=", value)
        end
      end
    end

    def self.parse(filename)
      File.open filename do |f|
        name = nil
        description = nil
        sequence = []
        loop do
          line = f.gets
          if line.nil?
            unless name.nil? || sequence.empty?
              s = sequence.join
              yield Record.new name: name,
                               description: description,
                               sequence: s
            end
            break
          end
          line.chomp!
          next if line == ""
          if line.start_with? ">"
            unless name.nil? || sequence.empty?
              s = sequence.join
              yield Record.new name: name,
                               description: description,
                               sequence: s
            end
            name, description = line[1..-1].split("\s", 2)
            sequence.clear
          else
            sequence << line
          end
        end
      end
    end
  end
end
