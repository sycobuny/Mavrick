#
# Mavrick: poker game creation/management
# lib/card.rb: Card object - handles comparisons/suits/faces
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

class CardInvalidError < Exception; end

class Card
    include Comparable

    # The list of face values that a +Card+ can be.
    Values = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)

    # The list of suits that a +Card+ can be.
    Suits  = %w(Hearts Diamonds Spades Clubs)

    attr_reader :deck, :suit, :value

    #
    # Basic +Card+ object setup.
    # ---
    # deck:: The +Deck+ to which this card belongs.
    # value:: The face value of this card, see Card::Values.
    # suit:: The suit of this card, see Card::Suits.
    # returns:: +Card+
    #
    def initialize(deck, value, suit)
        unless Values.include?(value) and Suits.include?(suit)
            raise CardInvalidError, "The #{value} of #{suit} is not a valid " +
                                    "card"
        end

        @deck, @suit, @value = deck, suit, value
    end

    ######
    public
    ######

    #
    # Compares a card to another hand to see which is better.
    # ---
    # returns:: +Integer+ - standard spaceship operator returns
    #
    def <=>(other)
        self.index <=> other.index
    end

    #
    # The card's index value - where it falls in its suit.
    # ---
    # returns:: +Integer+
    #
    def index
        Values.index(@value)
    end

    #
    # The card's name.
    # ---
    # returns:: +String+
    #
    def to_s
        "%s of %s" % [@value, @suit]
    end

    #
    # See Card#index.  Performs the same function, but on a given face value.
    # ---
    # returns:: +Integer+
    #
    def Card.index(value)
        Values.index(value)
    end
end

end # module Mavrick