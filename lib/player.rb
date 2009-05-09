#
# Mavrick: poker game creation/management
# lib/player.rb: Player object - someone who is playing. duh.
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

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

end # module Mavrick