#
# Mavrick: poker game creation/management
# lib/chip.rb: Chip object - how we bet
#
# Copyright (c) 2009 Stephen Belcher <sycobuny@malkier.net>
#

module Mavrick

class Chip
    # The +Chip+ types and their values.
    Types = {:white => 1, :red => 10, :blue => 25, :green => 50, :black => 100}

    attr_reader :type

    #
    # Basic +Chip+ object setup.
    # ---
    # type:: The +Chip+ type.  See Chip::Types.
    # returns:: +Chip+
    #
    def initialize(type)
        @type = type
    end

    ######
    public
    ######

    #
    # The list of +Chip+ types in ascending order of value.
    # ---
    # returns:: +Array+ of +Symbol+ objects.
    #
    def Chip.ascending
        Types.keys.sort { |a, b| Types[a] <=> Types[b] }
    end

    #
    # The list of +Chip+ types in descending order of value.
    # ---
    # returns:: +Array+ of +Symbol+ objects.
    #
    def Chip.descending
        ascending.reverse
    end

    #
    # Calculates the numeric value of a +Array+ of +Chip+ objects.
    # ---
    # array:: +Array+ of +Chip+ objects to be calculated.
    # returns:: +Integer+
    #
    def Chip.value_of(array)
        value = 0
        array.each { |chip| value += chip.value }
        value
    end

    # XXX - Need a way to run a bank, here.
    def Chip.exchange(from, count, to)
    end

    #
    # The chip type's numeric value.
    # ---
    # returns:: +Integer+
    #
    def value
        Types[@type]
    end

    #
    # See Chip#name.  Performs the same function, but on a given chip type.
    # ---
    # type:: +Symbol+.  See Chip::Types.
    def Chip.value(type)
        Types[type]
    end
end

end # module Mavrick