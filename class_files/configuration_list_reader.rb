class ConfigurationListReader

  require 'json'
  require 'ostruct'

  attr_reader :configurations

  def self.from_file(file_path, node_name)
    file = File.read(file_path)
    data_hash = JSON.parse(file)
    parsed_list = data_hash[node_name]

    config_list = parsed_list.map do |data|
      if data.is_a?(Hash)
        OpenStruct.new(data)
      else
        data
      end
    end

    new(config_list)
  end

  def initialize(config_list)
    @configurations = config_list
  end
end
