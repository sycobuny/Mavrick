require 'hand'

class Player
    attr_reader :name, :hand, :chips

    def initialize(name, chips)
        @hand  = Hand.new
        @name  = name
        @chips = chips
    end

    def receive_card(card)
        @hand << card
    end

    def retrieve_cards
        @hand.clear
    end

    def score
        @hand.score
    end

    def hand_name
        @hand.name
    end
end
