class Bank
    def mint(this_many = 1)
        Chips.new(this_many)
    end

    class InsufficientValueError < Exception; end

    class Chips
        attr_reader :value

        def initialize(value = 1)
            @value = value
        end

        def merge!(other_chips)
            @value += other_chips.devalue!
        end

        def split!(value)
            raise InsufficientValueError unless @value >= value
            @value -= value
            Chips.new(value)
        end

        def devalue!
            value = @value
            @value = 0
            value
        end
    end
end
