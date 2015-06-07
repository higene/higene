require 'cequel'

module CQL
  def self.quote(value)
    if value.nil?
      'null'
    else
      Cequel::Type.quote(value)
    end
  end
end
