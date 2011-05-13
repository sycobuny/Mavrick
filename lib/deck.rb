class Deck
    def initialize
        @cards = []

        Card::Suits.each do |suit|
            Card::FaceValues.each do |value|
                @cards << Card.new(suit, value)
            end
        end
    end

    def shuffle!
        @cards = @cards.sort_by { rand }
    end

    def deal(player)
        player.receive_card(@cards.shift)
    end

    def retrieve_cards(player)
        cards = player.retrieve_cards
        cards.each { |card| @cards << card }
    end

    class Card
        include Comparable
        attr_reader :suit, :face_value

        Suits = [:clubs, :spades, :diamonds, :hearts]
        FaceValues = [:'2', :'3', :'4', :'5', :'6', :'7', :'8', :'9', :'10',
                      :jack, :queen, :king, :ace]

        @@face_lookups = {}
        FaceValues.each_with_index { |fv, i| @@face_lookups[fv] = i }

        def initialize(suit, face_value)
            @suit, @face_value = suit, face_value
        end

        def index
            @index ||= @@face_lookups[@face_value]
        end

        def <=>(other)
            self.index <=> other.index
        end
    end
end
