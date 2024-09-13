# frozen_string_literal: true

module Reinforce
  module Attributes
    class Squad < Base
      FILENAME = 'sbps.json'

      class << self
      private

        def parse(data)
          parse_subtree(data, %w[sbps])
        end

        def parse_subtree(data, key)
          data.flat_map do |k, tree|
            new_key = key + [k]
            if tree.key?('extensions')
              parse_extensions(tree, new_key)
            else
              parse_subtree(tree, new_key)
            end
          end.compact
        end

        def parse_extensions(data, path)
          squad_data = squad_data_from(data)
          locstring = squad_data&.dig('race_data', 'info', 'screen_name', 'locstring', 'value')
          icon_name = squad_data&.dig('race_data', 'info', 'icon_name')

          new(locstring:,
              icon_name:,
              path:,
              pbgid: data['pbgid'])
        end

        def squad_data_from(data)
          race_ext = data['extensions'].find do |ext|
            ext['squadexts'].key?('race_list')
          end

          race_ext&.dig('squadexts', 'race_list')&.find do |entry|
            !entry.dig('race_data', 'info', 'screen_name').nil?
          end
        end
      end
    end
  end
end
