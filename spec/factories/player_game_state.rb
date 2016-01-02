FactoryGirl.define do
  factory :player_game_state, :class => PlayerGameState do
    game
    player
  end

  factory :player1_game_state, :class => PlayerGameState do
    game
    association :player, factory: :player1
  end

  factory :player2_game_state, :class => PlayerGameState do
    game
    association :player, factory: :player2
  end
end
