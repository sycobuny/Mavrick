class TieException < Exception
    attr_reader :players

    def initialize(players)
        @players = players
    end
end

class Game
    attr_reader :deck, :players

    def self.play(player_count = 4)
        Game.new(player_count).play
    end

    def initialize(player_count = 4)
        @deck = Deck.new
        @players = Range.new(1, player_count).collect do |x|
            Player.new("Player #{x}")
        end
    end

    def play
        @players.each { |p| @deck.retrieve_cards(p) }
        @deck.shuffle!

        5.times do
            @players.each { |p| @deck.deal(p) }
        end

        max_score = -1
        tied = []
        @players.each do |player|
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
        tied[0]
    end
end
