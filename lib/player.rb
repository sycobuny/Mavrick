#
# Mavrick: poker game creation/management
# lib/player.rb: Player object - someone who is playing. duh.
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

# An error class representing an attempt by a +Player+ to bet when they can't.
class PlayerCantBetError  < Exception; end

# An error class representing an attempt by a +Player+ to ante when they can't.
class PlayerCantAnteError < Exception; end

class Player
    # The default number of chips with which a +Player+ starts.
    StartingChips = {:white => 25, :red => 10, :blue => 5, :green => 5,
                     :black => 5}

    attr_reader   :game, :chips, :hand
    attr_accessor :ident

    #
    # Basic +Player+ object setup.
    # ---
    # game:: +Game+ - The table at which this +Player+ is sitting.
    # ident:: +String+ - The name of the +Player+.
    # starting_chips:: +Hash+ - The chips with which the player starts.
    # returns:: +Player+
    #
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

    #
    # Clears the current +Hand+ the +Player+ is holding and starts a new one.
    # ---
    # returns:: +Hand+
    #
    def new_hand
        @hand = Hand.new
    end

    #
    # The total amount of all the chips that the player has.
    # ---
    # returns:: +Integer+
    #
    def worth
        Chip.value_of(all_chips)
    end

    #
    # Returns a list of all the +Chip+ objects that the +Player+ has.
    # ---
    # returns:: +Array+ of +Chip+ objects.
    #
    def all_chips
        chips.values.flatten
    end

    #
    # Removes a set of chips from the player to throw in to ante up for a round.
    # ---
    # ante:: +Integer+ - the amount to ante.
    # returns:: +Array+ of +Chip+ objects - The chips removed from the player.
    #
    def ante_up(ante)
        raise PlayerCantAnteError if ante > worth

        chips = {}
        Chip.descending.each do |type|
            while Chip.value(type) <= ante
                chips[type] ||= 0
                chips[type] += 1
                ante -= Chip.value(type)
            end
        end

        chips.keys.collect do |type|
            1.upto(chips[type]).collect { @chips[type].shift }
        end.flatten
    end

    #
    #
    # ---
    # chips:: +Array+ of +Chip+ objects - The chips to add to the players worth.
    # returns:: +Hash+ of +Chip+ objects - The new value.
    #
    def add_to_worth(chips)
        chips.each { |chip| @chips[chip.type] << chip }
        @chips
    end

    #
    # Does whatever is necessary to ensure the +Player+ bets a certain value, if
    # it's possible.
    # ---
    # value:: +Integer+ - The value the +Player+ wishes to bet.
    # raises:: +PlayerCantBetError+ if the +Player+ isn't worth +value+ amount.
    # returns:: XXX - huh.
    #
    def bet_by_value(value)
        raise PlayerCantBetError if value > worth

        chips = {}
        Chip.descending.each do |type|
            while Chip.value(type) <= value
                chips[type] ||= 0
                chips[type] += 1
                ante -= Chip.value(type)
            end
        end

        bet(chips.keys.collect do |type|
            1.upto(chips[type]).collect { @chips[type].shift }
        end.flatten)
    end

    # XXX - Need to figure out what this does.
    def bet(chips)

    end
end

end # module Mavrick