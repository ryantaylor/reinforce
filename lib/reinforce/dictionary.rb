# frozen_string_literal: true

require 'forwardable'
require 'singleton'

module Reinforce
  class Dictionary
    include Singleton
    extend Forwardable

    def_delegators :@collection, :get_by_pbgid, :get_by_path

    def initialize
      @collection = Attributes::Collection.new

      [Attributes::Ability, Attributes::Entity, Attributes::Squad, Attributes::Upgrade].each do |klass|
        generated_path = File.join(Reinforce.root, 'generated', klass::FILENAME)
        File.open(generated_path) do |file|
          data = JSON.parse(file.read)
          data.each do |build, attributes|
            @collection.populate(build, attributes.map { |a| klass.new(**a.transform_keys(&:to_sym)) }, rehash: false)
          end
        end
      end

      @collection.rehash_all
    end
  end
end
