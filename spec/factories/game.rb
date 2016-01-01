FactoryGirl.define do
  factory :game do
    created_at '2015-01-26 04:15:32'
    updated_at '2015-01-26 04:15:32'

    factory :game_with_player do
      after(:create) do |game|
        create(:player1_game_state, game: game)
      end
    end

    factory :game_with_players do
      after(:create) do |game|
        create(:player1_game_state, game: game)
        create(:player2_game_state, game: game)
      end
    end
  end

end
