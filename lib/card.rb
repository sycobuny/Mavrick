#
# Mavrick: poker game creation/management
# lib/card.rb: Card object - handles comparisons/suits/faces
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

class Card
    include Comparable

    Suits  = %w(Hearts Diamonds Spades Clubs)
    Values = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)

    attr_reader :deck, :suit, :value

    def initialize(deck, value, suit)
        @deck, @suit, @value = deck, suit, value
    end

    ######
    public
    ######

    ##
    # spaceship operator, enables all other comparisons and sorting.
    def <=>(other)
        self.index <=> other.index
    end

    ##
    # the index of the card, since we can't rely on string comparison.
    def index
        Values.index(@value)
    end

    ##
    # the index of any old card
    def Card.index(value)
        Values.index(value)
    end
end

end # module Mavrick