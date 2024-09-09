# frozen_string_literal: true

RSpec.describe Reinforce do
  it 'has a version number' do
    expect(Reinforce::VERSION).not_to be_nil
  end

  describe '.build_for' do
    subject(:build_for) { described_class.build_for(player, replay.version) }

    let(:bytes) { File.read(path).unpack('C*') }
    let(:replay) { VaultCoh::Replay.from_bytes(bytes) }
    let(:paths) { build_for.map { |command| command.details.path } }

    context 'basic USF Airborne build' do
      let(:path) { "#{described_class.root}/spec/fixtures/replays/usf_airborne_build.rec" }
      let(:player) { replay.players.first }
      let(:build) do
        %w[sbps/races/american/infantry/engineer_us
           abilities/races/american/auto_build/auto_build_barracks
           abilities/races/american/auto_build/auto_build_barracks
           abilities/races/american/auto_build/auto_build_weapon_support_center
           upgrade/american/research/infantry_support_center_us
           upgrade/american/battlegroups/airborne/airborne
           upgrade/american/battlegroups/airborne/airborne_right_1a_pathfinders_us
           upgrade/american/battlegroups/airborne/airborne_right_2_paratrooper_us
           upgrade/american/battlegroups/airborne/airborne_right_3_paradrop_at_gun_us
           abilities/races/american/battlegroups/airborne/airborne_right_2_paratrooper_us
           abilities/races/american/battlegroups/airborne/airborne_right_3_paradrop_at_gun_us
           upgrade/american/battlegroups/airborne/airborne_left_1b_recon_loiter_us
           upgrade/american/battlegroups/airborne/airborne_left_2a_supply_drop_us
           upgrade/american/battlegroups/airborne/airborne_left_3b_carpet_bombing_run_us
           upgrade/american/research/infantry_support_center/field_support_us
           abilities/races/american/auto_build/auto_build_triage_center_us
           abilities/races/american/auto_build/auto_build_triage_center_us]
      end

      it 'generates the correct build' do
        expect(paths).to eq(build)
      end

      it 'marks some buildings as suspect' do
        suspects = build_for.select(&:suspect?).map(&:details).map(&:path)
        expected = %w[
          abilities/races/american/auto_build/auto_build_barracks
          abilities/races/american/auto_build/auto_build_weapon_support_center
          abilities/races/american/auto_build/auto_build_triage_center_us
        ]
        expect(suspects).to match_array(expected)
      end
    end

    context 'basic USF Armoured build with suspect triage' do
      let(:path) { "#{described_class.root}/spec/fixtures/replays/usf_armoured_build.rec" }
      let(:player) { replay.players.first }
      let(:build) do
        %w[abilities/races/american/auto_build/auto_build_barracks
           abilities/races/american/auto_build/auto_build_weapon_support_center
           upgrade/american/research/air_support_center_us
           upgrade/american/research/weapon_support_center/super_bazookas_us
           abilities/races/american/auto_build/auto_build_triage_center_us
           abilities/races/american/auto_build/auto_build_triage_center_us
           upgrade/american/battlegroups/armored/armored
           upgrade/american/battlegroups/armored/armored_left_1a_assault_engineers_us
           upgrade/american/battlegroups/armored/armored_left_2b_recovery_vehicle_us
           upgrade/american/battlegroups/armored/armored_left_3_war_machine_us
           abilities/races/american/battlegroups/armored/armored_left_2b_recovery_vehicle_us
           abilities/races/american/auto_build/auto_build_tank_depot
           upgrade/american/battlegroups/armored/armored_right_1a_fast_deploy_us
           upgrade/american/battlegroups/armored/armored_right_2a_scott_us
           upgrade/american/battlegroups/armored/armored_right_3_sherman_easy_8_us
           abilities/races/american/battlegroups/armored/armored_right_2a_scott_us
           abilities/races/american/battlegroups/armored/armored_right_3_easy_8_task_force_us
           sbps/races/american/infantry/assault_engineer_us
           upgrade/american/research/air_support_center/advanced_air_recon_us
           upgrade/american/research/air_support_center/air_supply_us
           upgrade/american/research/air_support_center/double_sortie_us]
      end

      it 'generates the correct build' do
        expect(paths).to eq(build)
      end

      it 'marks some buildings as suspect' do
        suspects = build_for.select(&:suspect?).map(&:details).map(&:path)
        expected = %w[
          abilities/races/american/auto_build/auto_build_barracks
          abilities/races/american/auto_build/auto_build_tank_depot
          abilities/races/american/auto_build/auto_build_triage_center_us
          abilities/races/american/auto_build/auto_build_triage_center_us
        ]
        expect(suspects).to match_array(expected)
      end
    end

    context 'basic USF Advanced Infantry build with suspect clearing over time test' do
      let(:path) { "#{described_class.root}/spec/fixtures/replays/usf_advanced_inf_build.rec" }
      let(:player) { replay.players.first }
      let(:build) do
        %w[abilities/races/american/auto_build/auto_build_barracks
           upgrade/american/battlegroups/infantry/infantry
           upgrade/american/battlegroups/infantry/infantry_left_1_convert_rifleman_to_ranger_us
           abilities/races/american/auto_build/auto_build_weapon_support_center
           sbps/races/american/infantry/ranger_us
           sbps/races/american/infantry/riflemen_us
           upgrade/american/battlegroups/infantry/infantry_left_2a_frontline_medical_tent_us
           abilities/races/american/battlegroups/infantry/infantry_left_1_rifleman_convert_to_ranger_us
           sbps/races/american/infantry/engineer_us
           upgrade/american/battlegroups/infantry/infantry_left_3b_infantry_assault_us
           upgrade/american/battlegroups/infantry/infantry_right_1a_artillery_observers_us
           upgrade/american/battlegroups/infantry/infantry_right_2_howitzer_105mm_us
           upgrade/american/battlegroups/infantry/infantry_right_3a_off_map_artillery_us
           abilities/races/american/auto_build/auto_build_triage_center_us]
      end

      it 'generates the correct build' do
        expect(paths).to eq(build)
      end

      it 'marks some buildings as suspect' do
        suspects = build_for.select(&:suspect?).map(&:details).map(&:path)
        expected = %w[
          abilities/races/american/auto_build/auto_build_weapon_support_center
          abilities/races/american/auto_build/auto_build_triage_center_us
        ]
        expect(suspects).to match_array(expected)
      end
    end
  end
end
