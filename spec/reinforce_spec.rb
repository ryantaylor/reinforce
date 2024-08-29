# frozen_string_literal: true

RSpec.describe Reinforce do
  it 'has a version number' do
    expect(Reinforce::VERSION).not_to be nil
  end

  describe '.build_for' do
    subject(:build_for) { Reinforce.build_for(player, replay.version).map(&:details).map(&:path) }

    let(:bytes) { File.read(path).unpack('C*') }
    let(:replay) { VaultCoh::Replay.from_bytes(bytes) }

    context 'basic USF Airborne build' do
      let(:path) { "#{Reinforce.root}/spec/fixtures/replays/usf_airborne_build.rec" }
      let(:player) { replay.players.first }
      let(:build) do
        %w[sbps/races/american/infantry/engineer_us
           abilities/races/american/auto_build/auto_build_barracks
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
           abilities/races/american/auto_build/auto_build_triage_center_us]
      end

      it 'generates the correct build' do
        expect(build_for).to eq(build)
      end
    end
  end
end
