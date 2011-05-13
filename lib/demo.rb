$:.unshift('.')
require 'deck'
require 'game'
require 'player'

g = Game.new(1)
tie_results = {}
real_results = {}

10_000_000.times do
    begin
        p = g.play
        real_results[p.hand_name] ||= 0
        real_results[p.hand_name] += 1
    rescue TieException => e
        max_hand    = e.players[0].hand.name
        score_count = e.players.length

        tie_results[max_hand] ||= {}
        tie_results[max_hand][score_count] ||= 0
        tie_results[max_hand][score_count] += 1
    end
end

real_results.sort { |a, b| a[1] <=> b[1] }.each do |key, value|
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
