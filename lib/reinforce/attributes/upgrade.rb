# frozen_string_literal: true

module Reinforce
  module Attributes
    class Upgrade < Base
      FILENAME = 'upgrade.json'

      class << self
      private

        def parse(data)
          parse_subtree(data, %w[upgrade])
        end

        def parse_subtree(data, key)
          return unless data.is_a?(Hash)

          data.flat_map do |k, tree|
            if tree.is_a?(Hash)
              new_key = key + [k]
              if tree.key?('upgrade_bag')
                parse_upgrade_bag(tree, new_key)
              else
                parse_subtree(tree, new_key)
              end
            end
          end.compact
        end

        def parse_upgrade_bag(data, path)
          locstring = data.dig('upgrade_bag', 'ui_info', 'screen_name', 'locstring', 'value')
          icon_name = data.dig('upgrade_bag', 'ui_info', 'icon_name')

          new(locstring:,
              icon_name:,
              path:,
              pbgid: data['pbgid'])
        end
      end
    end
  end
end
