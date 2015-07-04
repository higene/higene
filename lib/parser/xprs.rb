module Parser
  module Xprs
    class Record
      attr_accessor :bundle_id,
                    :target_id,
                    :length,
                    :eff_length,
                    :tot_counts,
                    :uniq_counts,
                    :est_counts,
                    :eff_counts,
                    :ambig_distr_alpha,
                    :ambig_distr_beta,
                    :fpkm,
                    :fpkm_conf_low,
                    :fpkm_conf_high,
                    :solvable,
                    :tpm

      def self.ncol
        15
      end

      def initialize(options)
        options.each do |key, value|
          send "#{key}=", value
        end
      end
    end

    def self.parse(filename)
      File.open filename do |f|
        f.each do |line|
          line.strip!
          next if line.start_with? "#"
          data = line.split "\t"
          if data.length < Record.ncol - 1
            fail "At least #{GffRecord.ncol - 1} columns is required (current #{data.length})."
          end

          record = Record.new bundle_id: data[0].to_i,
                              target_id: data[1],
                              length: data[2].to_i,
                              eff_length: data[3].to_f,
                              tot_counts: data[4].to_i,
                              uniq_counts: data[5].to_i,
                              est_counts: data[6].to_f,
                              eff_counts: data[7].to_f,
                              ambig_distr_alpha: data[8].to_f,
                              ambig_distr_beta: data[9].to_f,
                              fpkm: data[10].to_f,
                              fpkm_conf_low: data[11].to_f,
                              fpkm_conf_high: data[12].to_f
          if data[13] == 'T'
            record.solvable = true
          else
            record.solvable = false
          end
          record.tpm = data[14].to_f unless data[14].nil?

          yield record
        end
      end
    end
  end
end
