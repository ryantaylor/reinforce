# frozen_string_literal: true

module Reinforce
  class Factory
    BUILDING_COMMANDS = %w[UseAbility].freeze
    PRODUCTION_COMMANDS = %w[BuildSquad BuildGlobalUpgrade].freeze
    BATTLEGROUP_COMMANDS = %w[SelectBattlegroup SelectBattlegroupAbility UseBattlegroupAbility].freeze
    CANCEL_COMMANDS = %w[CancelConstruction CancelProduction].freeze
    AI_COMMANDS = %w[AITakeover].freeze
    ALL_COMMANDS = BUILDING_COMMANDS + PRODUCTION_COMMANDS + BATTLEGROUP_COMMANDS + CANCEL_COMMANDS + AI_COMMANDS

    def initialize(player, build_number)
      @player = player.to_h
      @build_number = build_number
      @buildings = []
      @productions = {}
      @battlegroup = []
      @takeover = []
    end

    def build(with_cancellations: false)
      commands.each { |c| break if classify_command(c) == false }
      result = consolidate
      result = rectify_suspects(result)
      result = result.reject(&:cancelled?) unless with_cancellations
      result
    end

  private

    def commands
      @commands ||= @player[:commands].filter { |c| ALL_COMMANDS.include?(c.keys.first) }
                                      .map { |c| Command.new(c, @build_number) }
    end

    def classify_command(command)
      if BUILDING_COMMANDS.include?(command.action_type)
        classify_building_command(command)
      elsif PRODUCTION_COMMANDS.include?(command.action_type)
        classify_production_command(command)
      elsif BATTLEGROUP_COMMANDS.include?(command.action_type)
        classify_battlegroup_command(command)
      elsif CANCEL_COMMANDS.include?(command.action_type)
        process_cancellation(command)
      elsif AI_COMMANDS.include?(command.action_type)
        process_takeover(command)
      end
    end

    def classify_building_command(command)
      @buildings << command if command.details&.autobuild?

      true
    end

    def classify_production_command(command)
      @productions[command.source] ||= []
      @productions[command.source] << command

      true
    end

    def classify_battlegroup_command(command)
      if command.details.respond_to?(:autobuild?) && command.details.autobuild?
        @buildings << command
      else
        @battlegroup << command
      end

      true
    end

    def process_cancellation(command)
      if command.action_type == 'CancelConstruction'
        @buildings.reject(&:suspect?).each { |building| building.mark_suspect(command.tick) }
      else
        @productions[command.source][command.index - 1].cancel
      end

      true
    end

    def process_takeover(command)
      return true unless @player[:human]

      @takeover << command

      false
    end

    def consolidate
      build = @buildings + @battlegroup + @takeover + @productions.values.flatten
      build.sort_by(&:tick)
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    def rectify_suspects(commands)
      commands.each_with_index do |command, idx|
        next unless command.suspect?

        building_details = Attributes::Collection.instance.get_by_path(command.details&.builds, build: @build_number)
        remaining = commands[(idx + 1)..]
        relevant = remaining.take_while { |c| c.pbgid != command.pbgid }

        used = relevant.any? do |c|
          building_details&.produces?(c.details.path)
        end

        command.mark_legit if used
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize
  end
end
