# frozen_string_literal: true

require 'logger'

require_relative 'reinforce/attributes/base'

require_relative 'reinforce/attributes/ability'
require_relative 'reinforce/attributes/entity'
require_relative 'reinforce/attributes/squad'
require_relative 'reinforce/attributes/upgrade'

require_relative 'reinforce/attributes/collection'

require_relative 'reinforce/command'
require_relative 'reinforce/factory'

require_relative 'reinforce/version'

module Reinforce
  def self.root
    File.expand_path('../', File.dirname(__FILE__))
  end

  def self.logger
    @logger ||= Logger.new($stdout).tap do |logger|
      logger.progname = name
    end
  end

  # Takes a Vault Player and generates a build order
  def self.build_for(player, build_number, with_cancellations: false)
    Factory.new(player, build_number).build(with_cancellations:)
  end

  # Parses data into structures for build order generation
  def self.generate(pretty: false)
    [
      Attributes::Ability,
      Attributes::Entity,
      Attributes::Squad,
      Attributes::Upgrade
    ].each do |klass|
      Attributes::Collection.generate_for(klass, pretty:)
    end
  end
end
