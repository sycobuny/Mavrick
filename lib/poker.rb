module Poker

class RoundStartedError < Exception; end
class Game
    Ante = 10
    attr_reader   :deck, :table, :players, :pot
    attr_accessor :ante

    def initialize(players, num_decks = 1, ante = Ante,
                   starting_chips = Player::StartingChips)
        players.each do |player|
            (@table ||= []) << Player.new(self, player, starting_chips)
        end 

        @deck = Deck.new(num_decks)
        @ante = ante

        @pot = nil
    end

    ######
    public
    ######

    def start_round(new_ante = nil, players = @table)
        raise RoundStartedError if @pot

        @ante = new_ante if new_ante
        @pot = []
        @deck.shuffle!
        @table.push(@table.shift) # rotate the first player

        @players = @table.collect do |player|
            next unless players.include?(player)
            begin
                @pot.concat(player.ante_up(@ante))
                player.new_hand
            rescue PlayerCantAnteError
                next
            end

            player.new_hand
        end

        1.upto(5) do
            @players.each { |player| player.hand << @deck.deal }
        end
    end
end

class ChipNoMatchError < Exception; end
class Chip
    Types = {:white => 1, :red => 10, :blue => 25, :green => 50, :black => 100}
    attr_reader :type

    def initialize(type)
        @type = type
    end

    ######
    public
    ######

    def Chip.ascending
        Types.keys.sort { |a, b| Types[a] <=> Types[b] }
    end

    def Chip.descending
        ascending.reverse
    end

    def Chip.value_of(array)
        value = 0
        array.each { |chip| value += chip.value }
        value
    end

    # XXX - Need a way to run a bank, here.
    def Chip.exchange(from, count, to)
    end

    def value
        Types[@type]
    end

    def Chip.value(type)
        Types[type]
    end
end

class PlayerCantAnteError < Exception; end
class Player
    StartingChips = {:white => 25, :red => 10, :blue => 5, :green => 5,
                     :black => 5}
    attr_reader   :game, :chips, :hand
    attr_accessor :ident

    def initialize(game, ident, starting_chips = StartingChips)
        @game  = game
        @ident = ident

        @chips = {}
        starting_chips.each do |k, v|
            @chips[k] = []
            1.upto(v) { @chips[k] << Chip.new(k) }
        end
    end

    ######
    public
    ######

    def new_hand
        @hand = Hand.new
    end
    
    def worth
        Chip.value_of(all_chips)
    end

    def all_chips
        chips.values.flatten
    end

    def ante_up(ante)
        chips = {}
        Chip.descending.each do |type|
            while Chip.value(type) <= ante
                chips[type] ||= 0
                chips[type] += 1
                ante -= Chip.value(type)
            end
        end

        raise PlayerCantAnteError if ante > 0

        chips.keys.collect do |type|
            1.upto(chips[type]).collect { @chips[type].shift }
        end.flatten
    end

    def add_to_worth(chips)
        chips.each { |chip| @chips[chip.type] << chip }
    end

    def bet(chips)

    end
end

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

end # module Poker
