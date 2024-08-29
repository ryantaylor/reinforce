# frozen_string_literal: true

module Reinforce
  module Attributes
    class Entity < Base
      FILENAME = 'ebps.json'

      attr_reader :spawns, :upgrades

      def initialize(path:, pbgid:, locstring:, icon_name:, spawns:, upgrades:)
        super(path:, pbgid:, locstring:, icon_name:)
        @spawns = spawns
        @upgrades = upgrades
      end

      class << self
      private

        def parse(data)
          parse_subtree(data, %w[ebps])
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
          ext_data = data['extensions'].find { |ext| ext['exts'].key?('screen_name') }
          locstring = ext_data&.dig('exts', 'screen_name', 'locstring', 'value')

          return if locstring.nil? || locstring == '0'

          icon_name = ext_data.dig('exts', 'icon_name')

          ext_spawns = data['extensions'].find { |ext| ext['exts'].key?('spawn_items') }
          spawns = (ext_spawns&.dig('exts', 'spawn_items') || []).map { |item| item.dig('spawn_item', 'squad', 'instance_reference') }

          ext_upgrades = data['extensions'].find { |ext| ext['exts'].key?('standard_upgrades') }
          upgrades = (ext_upgrades&.dig('exts', 'standard_upgrades') || []).map { |item| item.dig('upgrade', 'instance_reference') }

          new(locstring:,
              icon_name:,
              path:,
              spawns:,
              upgrades:,
              pbgid: data['pbgid'])
        end
      end

      def produces?(path)
        @spawns.include?(path) || @upgrades.include?(path)
      end

      def ==(other)
        super && @spawns == other.spawns && @upgrades == other.upgrades
      end

      def as_json(_options)
        super.merge(spawns:, upgrades:)
      end
    end
  end
end
