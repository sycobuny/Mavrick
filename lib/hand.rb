#
# Mavrick: poker game creation/management
# lib/hand.rb: Hand object - tells us what kind of hand someone's holding
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

class HandCompleteError   < Exception; end # these two juxtaposed is humorous.
class HandIncompleteError < Exception; end
class HandUnknownError    < Exception; end
class Hand
    include Comparable

    Names = ['High Card', 'Pair', 'Two Pair', 'Three of a Kind', 'Straight',
             'Flush', 'Full House', 'Four of a Kind', 'Straight Flush',
             'Royal Flush']
    attr_accessor :cards

    def initialize
        @cards = []

        @two, @three, @four = nil, nil, nil
    end

    #########
    protected
    #########
    attr_reader :two, :three, :four, :other

    ######
    public
    ######

    def complete?
        @cards.length == 5
    end

    def name
        raise HandIncompleteError unless complete?
        @cards.sort!

        suit_matches = ! @cards.find { |c| c.suit != @cards[0].suit }

        ##
        # for some reason when we assign the boolean result it's the opposite
        # of what we'd expect, so we do it the old-fashioned way.
        if  (@cards[1].index == (@cards[0].index + 1)) and
            (@cards[2].index == (@cards[1].index + 1)) and
            (@cards[3].index == (@cards[2].index + 1)) and
            (@cards[4].index == (@cards[3].index + 1))
            in_order = true
        else
            in_order = false
        end

        matches = {}
        @cards.each { |c| matches[c.value] ||= 0; matches[c.value] += 1 }

        @four  = matches.keys.find     { |v| matches[v] == 4 }
        @three = matches.keys.find     { |v| matches[v] == 3 }
        @two   = matches.keys.find_all { |v| matches[v] == 2 }
        @two   = [] if @two.length == 2 and @two[0] == @two[1]
        @other = matches.keys.find_all { |v| matches[v] == 1 }
        @two.sort!   { |a, b| Card.index(a) <=> Card.index(b) } # for <=> later
        @other.sort! { |a, b| Card.index(a) <=> Card.index(b) } # for <=> later

        #
        # the logic could be condensed here but I'm basically going from high
        # hands to low hands. also, I use Names[-x] because of DRY.
        #  - sycobuny
        #

        # straight flush and royal flush
        if suit_matches and in_order
            return Names[-1] if high_card.value == 'Ace'
            return Names[-2]
        end

        # four of a kind
        return Names[-3] if @four

        # full house
        return Names[-4] if @three and not @two.empty?

        # flush
        return Names[-5] if suit_matches

        # straight
        return Names[-6] if in_order

        # three of a kind
        return Names[-7] if @three

        # two pair
        return Names[-8] if @two.length == 2

        # pair
        return Names[-9] if not @two.empty?

        # high card
        return Names[-10] # don't need return but it matches styles.
    end

    def to_s
        @cards.sort.collect do |card|
            "#{card.value} of #{card.suit}"
        end.join(', ')
    end

    def <<(card)
        raise HandCompleteError if @cards.length == 5
        @cards << card
    end

    def <=>(other)
        sname = name
        oname = other.name

        sindex = Names.index(sname)
        oindex = Names.index(oname)

        cmp = sindex <=> oindex
        return cmp unless cmp == 0

        case sname
        when Names[-1] # Royal Flush
            return 0
        when Names[-2], Names[-5], Names[-6], Names[-10] # Straight Flush,
                                                         # Flush, Straight,
                                                         # High Card
            return high_card <=> other.high_card
        when Names[-3] # Four of a Kind
            return Card.index(@four) <=> Card.index(other.four)
        when Names[-4] # Full House
            cmp = Card.index(@three) <=> Card.index(other.three)
            return cmp unless cmp == 0

            return Card.index(@two[0]) <=> Card.index(other.two[0])
        when Names[-7] # Three of a Kind
            cmp = Card.index(@three) <=> Card.index(other.three)
            return cmp unless cmp == 0

            self.other.each_index do |i|
                cmp = Card.index(self.other[i]) <=> Card.index(other.other[i])
                return cmp unless cmp == 0
            end
            return 0
        when Names[-8] # Two Pair
            @two.each_index do |i|
                cmp = Card.index(@two[i]) <=> Card.index(other.two[i])
                return cmp unless cmp == 0
            end

            return Card.index(self.other[0]) <=> Card.index(other.other[0])
        when Names[-9] # Pair
            cmp = Card.index(@two[0]) <=> Card.index(other.two[0])
            return cmp unless cmp == 0

            self.other.each_index do |i|
                cmp = Card.index(self.other[i]) <=> Card.index(other.other[i])
                return cmp unless cmp == 0
            end
            return 0
        when Names[-10] # High Card
            self.other.each_index do |i|
                cmp = Card.index(self.other[0]) <=> Card.index(other.other[0])
                return cmp unless cmp == 0
            end
            return 0
        else # Some other hand?
            raise HandUnknownError, "Don't know this hand: #{sname}"
        end
    end

    def high_card
        @cards.sort[-1]
    end
end

end # module Mavrick