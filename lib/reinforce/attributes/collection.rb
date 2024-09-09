# frozen_string_literal: true

module Reinforce
  module Attributes
    class Collection
      LATEST_BUILD = -1

      def initialize
        @pbgid_keyed = {}
        @path_keyed = {}
      end

      class << self
        def generate_for(klass)
          collection = load_from_data(klass)

          collection.rehash_all

          generation_path = File.join(Reinforce.root, 'generated', klass::FILENAME)
          File.write(generation_path, JSON.pretty_generate(collection))

          true
        end

        def instance
          return @instance if defined?(@instance)

          @instance = new

          [Ability, Entity, Squad, Upgrade].each do |klass|
            generated_path = File.join(Reinforce.root, 'generated', klass::FILENAME)
            File.open(generated_path) do |file|
              data = JSON.parse(file.read)
              data.each do |build, attributes|
                @instance.populate(build, attributes.map { |a| klass.new(**a.transform_keys(&:to_sym)) }, rehash: false)
              end
            end
          end

          @instance.rehash_all
          @instance
        end

        def load_for(klass)
          collection = new
          generated_path = File.join(Reinforce.root, 'generated', klass::FILENAME)
          File.open(generated_path) do |file|
            data = JSON.parse(file.read)
            data.each do |build, attributes|
              collection.populate(build, attributes.map { |a| klass.new(**a.transform_keys(&:to_sym)) }, rehash: false)
            end
          end

          collection.rehash_all
          collection
        end

      private

        def load_from_data(klass)
          collection = new
          data_path = File.join(Reinforce.root, 'data')

          Dir.chdir(data_path) do
            Dir.glob('*').select { |f| File.directory?(f) }.each do |dir|
              file_path = File.join(dir, klass::FILENAME)
              next unless File.exist?(file_path)

              data = klass.load_from_file(file_path)
              collection.populate(dir, data, rehash: false)
            end
          end

          collection
        end
      end

      def get_by_pbgid(pbgid, build: LATEST_BUILD)
        return nil if build.nil?

        build = last_build if build == LATEST_BUILD
        @pbgid_keyed.dig(build, pbgid) || get_by_pbgid(pbgid, build: previous_build_for(build))
      end

      def get_by_path(path, build: LATEST_BUILD)
        return nil if build.nil?

        build = last_build if build == LATEST_BUILD
        @path_keyed.dig(build, path) || get_by_path(path, build: previous_build_for(build))
      end

      def populate(build, data, rehash: true)
        populate_pbgid_hash(build, data)
        populate_path_hash(build, data)

        rehash_all if rehash
        true
      end

      def rehash_all
        rehash(@pbgid_keyed)
        rehash(@path_keyed)
      end

      def as_json(_options)
        @pbgid_keyed.transform_values(&:values)
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end

    private

      def populate_pbgid_hash(build, data)
        @pbgid_keyed[build.to_i] ||= {}
        @pbgid_keyed[build.to_i] = @pbgid_keyed[build.to_i].merge(data.to_h { |o| [o.pbgid, o] })
      end

      def populate_path_hash(build, data)
        @path_keyed[build.to_i] ||= {}
        @path_keyed[build.to_i] = @path_keyed[build.to_i].merge(data.to_h { |o| [o.path, o] })
      end

      def first_build
        @pbgid_keyed.keys.min
      end

      def last_build
        @pbgid_keyed.keys.max
      end

      def previous_build_for(build)
        @pbgid_keyed.keys.sort.reverse.find { |b| b < build }
      end

      def rehash(hash)
        previous = nil

        hash.keys.sort.each do |build|
          next previous = build if previous.nil?

          hash[build].each do |key, value|
            hash[build].delete(key) if value == hash[previous][key]
          end

          hash[build] = hash[previous].merge(hash[build])

          previous = build
        end
      end
    end
  end
end
