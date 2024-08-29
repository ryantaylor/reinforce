# frozen_string_literal: true

require 'json'

module Reinforce
  module Attributes
    class Base
      attr_reader :locstring, :icon_name

      def initialize(path:, pbgid:, locstring:, icon_name:)
        @path = path
        @pbgid = pbgid
        @locstring = locstring
        @icon_name = icon_name
      end

      class << self
        def load_from_file(path)
          File.open(path) do |file|
            data = JSON.parse(file.read)
            parse(data)
          end
        end

      private

        def parse(_data)
          raise NotImplementedError
        end
      end

      def path
        @path.join('/')
      end

      def pbgid
        @pbgid.to_i
      end

      def ==(other)
        return false unless other.is_a?(self.class)

        path == other.path &&
          pbgid == other.pbgid &&
          locstring == other.locstring &&
          icon_name == other.icon_name
      end

      def as_json(_options)
        {
          path: @path,
          pbgid:,
          locstring:,
          icon_name:
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end
  end
end
