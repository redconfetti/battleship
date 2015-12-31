require 'rails_helper'

RSpec.describe Game, type: :model do
  subject { Game.create(created_at: '2015-01-26 04:15:32') }

  describe '#as_json' do
    it 'returns json representation' do
      result = subject.as_json
      expect(result).to be_an_instance_of Hash
    end

    it 'includes start date in json' do
      result = subject.as_json
      expect(result['startDate']).to eq '01/26/15 04:15 AM'
    end

    it 'includes start date timestamp in json' do
      result = subject.as_json
      expect(result['startDateUnixTimestamp']).to eq 1422245732
    end
  end
end
