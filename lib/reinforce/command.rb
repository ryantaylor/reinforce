# frozen_string_literal: true

module Reinforce
  class Command
    attr_reader :action_type, :tick, :pbgid, :source, :index, :details

    # rubocop:disable Metrics/AbcSize
    def initialize(command_hash, build_number)
      @action_type = command_hash.keys.first
      @tick = command_hash.values.first[:tick]
      @pbgid = command_hash.values.first[:pbgid]
      @source = command_hash.values.first[:source_identifier]
      @index = command_hash.values.first[:queue_index]
      @details = Attributes::Collection.instance.get_by_pbgid(@pbgid, build: build_number)
      @cancelled = false
      @suspect_from_tick = nil
    end
    # rubocop:enable Metrics/AbcSize

    def cancelled?
      @cancelled
    end

    def cancel
      @cancelled = true
    end

    def suspect?
      !@suspect_from_tick.nil?
    end

    def mark_suspect(tick)
      @suspect_from_tick = tick
    end

    def mark_legit
      @suspect_from_tick = nil
    end

    def suspect_since
      @suspect_from_tick
    end

    def as_json(_options)
      {
        action: action_type,
        tick:,
        pbgid:,
        locstring: @details.locstring,
        icon_name: @details.icon_name
      }
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end
  end
end
