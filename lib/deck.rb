class Deck
    def initialize
        @cards = []

        Card::Suits.each do |suit|
            Card::FaceValues.each do |value|
                @cards << Card.new(suit, value)
            end
        end
    end

    def shuffle! # (this_many = 1)
#        this_many.times { @cards.sort! { rand <=> rand } }
        @cards.sort! { rand <=> rand }
    end

    def deal(player)
        player.receive_card(@cards.shift)
    end

    def retrieve_cards(player)
        cards = player.retrieve_cards
        cards.each { |card| @cards << card }
    end

    class Card
        attr_reader :suit, :face_value

        Suits = [:clubs, :spades, :diamonds, :hearts]
        FaceValues = [:'2', :'3', :'4', :'5', :'6', :'7', :'8', :'9', :'10',
                      :jack, :queen, :king, :ace]

        def initialize(suit, face_value)
            @suit, @face_value = suit, face_value
        end

        def index
            FaceValues.find_index { |value| value == @face_value }
        end
    end
end
