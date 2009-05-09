#
# Mavrick: poker game creation/management
# lib/deck.rb: Deck object - that from which we deal
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

class Deck
    attr_reader :cards

    def initialize(num_decks = 1)
        @cards = []
        @deal  = nil

        1.upto(num_decks) do
            Card::Suits.each do |suit|
                Card::Values.each do |value|
                    @cards << Card.new(self, value, suit)
                end
            end
        end
    end

    ######
    public
    ######

    def shuffle!
        @deal = nil
        @cards.sort! { rand(65536) <=> rand(65536) }
        self
    end

    def deal
        (@deal ||= @cards.dup).shift
    end
end

end # module Mavrick