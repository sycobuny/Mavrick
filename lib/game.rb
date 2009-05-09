#
# Mavrick: poker game creation/management
# lib/game.rb: Game object - drives the library
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

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

end # module Mavrick