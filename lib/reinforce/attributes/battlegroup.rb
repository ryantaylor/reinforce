# frozen_string_literal: true

module Reinforce
  module Attributes
    class Battlegroup < Base
      FILENAME = 'battlegroup.json'

      attr_reader :activation_upgrade

      def initialize(path:, pbgid:, locstring:, icon_name:, activation_upgrade:)
        super(path:, locstring:, pbgid:, icon_name:)
        @activation_upgrade = activation_upgrade
      end

      class << self
        def load_from_file(path)
          File.open(path) do |file|
            data = JSON.parse(file.read)
            parse(data)
          end
        rescue Errno::ENOENT
          []
        end

      private

        def parse(data)
          parse_subtree(data, %w[battlegroup])
        end

        def parse_subtree(data, key)
          return unless data.is_a?(Hash)

          data.flat_map do |k, tree|
            if tree.is_a?(Hash)
              new_key = key + [k]
              if tree.key?('techtree_bag')
                parse_techtree_bag(tree, new_key)
              else
                parse_subtree(tree, new_key)
              end
            end
          end.compact
        end

        def parse_techtree_bag(data, path)
          locstring = data.dig('techtree_bag', 'name', 'locstring', 'value')
          activation_upgrade = data.dig('techtree_bag', 'activation_upgrade', 'instance_reference')

          new(locstring:,
              icon_name: nil,
              path:,
              activation_upgrade:,
              pbgid: data['pbgid'])
        end
      end

      def ==(other)
        super && @activation_upgrade == other.activation_upgrade
      end

      def as_json(_options)
        super.merge(activation_upgrade:)
      end
    end
  end
end
