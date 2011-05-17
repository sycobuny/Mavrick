class TieException < Exception
    attr_reader :players

    def initialize(players)
        @players = players
    end
end

class Game
    attr_reader :winner, :pot, :deck, :players, :losers

    def self.play(player_count = 4, player_chips = 1)
        Game.new(player_count, player_chips).play
    end

    def initialize(player_count = 4, player_chips = 250)
        @bank   = Bank.new
        @deck   = Deck.new

        @pot    = @bank.mint(0)
        @winner = nil

        @players = Range.new(1, player_count).collect do |x|
            Player.new("Player #{x}", @bank.mint(player_chips))
        end
        @losers = []
    end

    def play
        distribute_winnings!

        @players.each { |p| @deck.retrieve_cards(p) }
        @deck.shuffle!

        5.times do
            @players.each { |p| @deck.deal(p) }
        end

        max_score = -1
        tied = []
        @players.each do |player|
            @pot.merge!(player.chips.split!(1))

            if (score = player.score) > max_score
                max_score = score
                tied      = [player]
            elsif score == max_score
                tied << player
            end
        end

        if tied.length > 1
            still_tied = [first = tied.shift]
            while (second = tied.shift)
                if (resolution = first.hand.resolve_tie(second.hand)) == 0
                    still_tied << second
                elsif resolution == 1
                    still_tied = [first = second]
                end
            end

            tied = still_tied
        end

        raise TieException.new(tied) if tied.length > 1
        @winner = tied[0]
    end

    def distribute_winnings!
        @winner.chips.merge!(@pot) if @winner
        @winner = nil

        losers = @players.find_all { |player| player.chips.value == 0 }
        @players.delete_if { |player| player.chips.value == 0 }

        @losers += losers
    end
end
