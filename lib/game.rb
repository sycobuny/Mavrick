class TieException < Exception; end

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

        max_score = 0
        max_score_player = nil
        tied = false
        @players.each do |player|
            if (score = player.score) > max_score
                max_score        = score
                max_score_player = player
                tied             = false
            elsif score == max_score
                tied = true
            end
        end

        raise TieException if tied
        max_score_player
    end
end
