#
# Mavrick: poker game creation/management
# lib/game.rb: Game object - drives the library
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

# An error class representing an attempt to start a new round during a previous.
class RoundStartedError < Exception; end

class Game
    # The default ante with which a round starts.
    Ante = 10

    attr_reader   :deck, :table, :players, :pot
    attr_accessor :ante

    #
    # Basic +Game+ object setup.
    # ---
    # players:: +Array+ of +String+ objects - player names
    # num_decks:: +Integer+ - The number of decks used for playing.
    # ante:: +Integer+ - The starting ante, good for the first round.
    # starting_chips:: +Hash+ The chip count with which players start.
    # returns:: +Game+
    #
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

    #
    # Sets up a new round of play.
    # ---
    # new_ante:: +Integer+ - The new value players must put down to play.
    # players:: +Array+ of +Player+ objects - the people who want to play.
    # raises:: +RoundStartedError+ if there's a round already in session.
    # returns:: +nil+
    #
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

        nil
    end
end

end # module Mavrick