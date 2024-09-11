# frozen_string_literal: true

module Reinforce
  module Attributes
    class Ability < Base
      AUTOBUILDS = %w[
        abilities/races/american/battlegroups/infantry/infantry_left_2a_medical_tent
      ].freeze

      SPAWNERS = %w[
        armored_support_flame_p3_ak
        armored_support_command_p4_ak
        italian_combined_arms_bersaglieri_ak
        italian_combined_arms_semovente_ak
        italian_combined_arms_m13_40_ak
        italian_infantry_double_l640_ak
        italian_infantry_guastatori_ak
        italian_infantry_cannone_da_105_ak
        infiltration_left_1_vampire_ht_goliath_ak
        british_air_and_sea_left_2a_centaur_cs_uk
        british_air_and_sea_right_1_commandos_uk
        british_air_and_sea_right_2a_pack_howitzer_team_uk
        british_air_and_sea_right_2b_commando_lmg_team_uk
        british_armored_right_2_crusader_aa_uk
        british_armored_left_2_churchill
        british_armored_left_3b_churchill_black_prince_uk
        artillery_gurkhas_uk
        artillery_4_2_inch_heavy_mortar_uk
        artillery_bl_5_5_heavy_artillery_uk
        australian_defense_archer_tank_destroyer_call_in_uk
        australian_defense_australian_light_infantry_uk
        australian_defense_2pdr_at_gun_uk
        airborne_right_1a_pathfinders_us
        airborne_right_1b_paradrop_hmg_us
        airborne_right_2_paratrooper_us
        airborne_right_3_paradrop_at_gun_us
        armored_left_2b_recovery_vehicle_us
        armored_right_2a_scott_us
        armored_right_3_easy_8_task_force_us
        special_operations_left_1a_m29_weasal_us
        special_operations_left_1b_m29_weasal_with_pack_howitzer
        special_operations_left_3_whizbang_us
        special_operations_right_2_devils_brigade_us
        infantry_left_1_rifleman_convert_to_ranger_us
        infantry_right_1a_artillery_observers_us
        infantry_right_2_105mm_howitzer_us
        breakthrough_right_3a_assault_group_ger
        breakthrough_left_1b_truck_2_5_ger
        breakthrough_left_2b_panzer_iv_cmd_ger
        breakthrough_left_3_tiger_ger
        luftwaffe_right_2_fallschirmjagers_ger
        luftwaffe_left_1b_fallschirmpioneers_ger
        luftwaffe_left_2b_combat_group_ger
        luftwaffe_left_2a_weapon_drop_ger
        luftwaffe_left_3_88mm_at_gun_ger
        mechanized_right_2a_stug_assault_group_ger
        mechanized_left_2b_8_rad_ger
        mechanized_right_3_panther_ger
        mechanized_left_3a_wespe_ger
        coastal_left_1_coastal_reserve_ger
        coastal_artillery_officer_ger
        coastal_obice_ger
        halftrack_deployment_panzerjager_inf_1_ak
        halftrack_deployment_assault_grenadier_1_ak
        halftrack_deployment_at_gun_1_ak
        halftrack_deployment_leig_1_ak
        halftrack_deployment_piv_tank_hunter_group_ak
        halftrack_deployment_stug_assault_group_ak
        halftrack_deployment_panzer_iii_assault_group_ak
        halftrack_deployment_tiger_ak
      ].to_set

      FILENAME = 'abilities.json'

      attr_reader :builds

      def initialize(path:, pbgid:, locstring:, icon_name:, builds:)
        super(path:, pbgid:, locstring:, icon_name:)
        @builds = builds
      end

      class << self
      private

        def parse(data)
          parse_subtree(data, %w[abilities])
        end

        def parse_subtree(data, key)
          data.flat_map do |k, tree|
            new_key = key + [k]
            if tree.key?('ability_bag')
              parse_ability_bag(tree, new_key)
            else
              parse_subtree(tree, new_key)
            end
          end.compact
        end

        def parse_ability_bag(data, path)
          locstring = data.dig('ability_bag', 'ui_info', 'screen_name', 'locstring', 'value')

          return if locstring.nil? || locstring == '0'

          icon_name = data.dig('ability_bag', 'ui_info', 'icon_name')
          builds = data.dig('ability_bag', 'cursor_ghost_ebp', 'instance_reference')

          new(locstring:,
              icon_name:,
              builds: builds == '' ? nil : builds,
              path:,
              pbgid: data['pbgid'])
        end
      end

      def autobuild?
        @path.include?('auto_build') || @path.include?('autobuild') || AUTOBUILDS.include?(path)
      end

      def production_building?
        %r{ebps/races/.+/buildings/production/.+}.match?(@builds)
      end

      def spawner?
        SPAWNERS.include?(@path.last)
      end

      def ==(other)
        super && @builds == other.builds
      end

      def as_json(_options)
        super.merge(builds:)
      end
    end
  end
end
