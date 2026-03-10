# frozen_string_literal: true

module Reinforce
  module Attributes
    class Upgrade < Base
      FILENAME = 'upgrade.json'

      class << self
        def load_from_file(path)
          battlegroups = load_battlegroups(path)

          File.open(path) do |file|
            data = JSON.parse(file.read)
            parse(data, battlegroups)
          end
        end

      private

        def load_battlegroups(path)
          dir = File.dirname(path)
          bg_path = File.join(dir, ::Reinforce::Attributes::Battlegroup::FILENAME)
          ::Reinforce::Attributes::Battlegroup.load_from_file(bg_path)
                                              .to_h { |bg| [bg.activation_upgrade, bg.locstring] }
        end

        def parse(data, battlegroups)
          parse_subtree(data, battlegroups, %w[upgrade])
        end

        def parse_subtree(data, battlegroups, key)
          return unless data.is_a?(Hash)

          data.flat_map do |k, tree|
            if tree.is_a?(Hash)
              new_key = key + [k]
              if tree.key?('upgrade_bag')
                parse_upgrade_bag(tree, battlegroups, new_key)
              else
                parse_subtree(tree, battlegroups, new_key)
              end
            end
          end.compact
        end

        def parse_upgrade_bag(data, battlegroups, path)
          locstring = data.dig('upgrade_bag', 'ui_info', 'screen_name', 'locstring', 'value')
          locstring = battlegroups[path.join('/')] if locstring.nil? || locstring.empty? || locstring == '0'
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
