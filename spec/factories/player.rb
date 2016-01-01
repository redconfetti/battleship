FactoryGirl.define do
  factory :player, aliases: [:player1] do
    email 'johndoe@example.com'
    password 'someP@$$word'
  end

  factory :player2, class: Player do
    email 'jane@example.com'
    password '$3cr3tP@$$w0rD'
  end

  factory :player3, class: Player do
    email 'killroy@example.com'
    password 'killroywuzhere'
  end
end
