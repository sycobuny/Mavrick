$:.unshift('.')
require 'deck'
require 'game'
require 'player'

g = Game.new
tie_results = {}
real_results = {}

10000.times do
    begin
        p = g.play
        real_results[p.hand_name] ||= 0
        real_results[p.hand_name] += 1
    rescue TieException => e
        max_score   = 0
        max_hand    = nil
        score_count = 0
        g.players.each do |player|
            if player.score > max_score
                max_score = player.score
                max_hand = player.hand_name
                score_count = 1
            elsif player.score == max_score
                score_count += 1
            end
        end
        tie_results[max_hand] ||= {}
        tie_results[max_hand][score_count] ||= 0
        tie_results[max_hand][score_count] += 1
    end
end

real_results.each do |key, value|
    puts "There were #{value} winning hands with #{key}"
end

tie_results.each do |key, value|
    total = 0
    value.each { |k, v| total += v }

    puts "There were #{total} tied hands with #{key}"
    value.each do |k, v|
        puts "    #{v} with #{k} players in a tie"
    end
end
