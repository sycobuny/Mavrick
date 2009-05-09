#
# Mavrick: poker game creation/management
# lib/chip.rb: Chip object - how we bet
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

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

end # module Mavrick