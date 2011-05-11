class Hand
    attr_reader :name

    @@hands = {}
    @@rankings = []

    def initialize(cards = [])
        @cards = cards
        @score = 0
        @name = :high_card
        @calculate_score = false
    end

    def cards
        @cards.dup
    end

    def <<(card)
        @cards << card
        @calculate_score = true
    end

    def clear
        cards = @cards.dup
        @cards.clear
        @calculate_score = true

        cards
    end

    def score
        return @score unless @calculate_score
        @score = @@rankings.reverse.find_index do |hand|
            send(hand.to_s.+('?'))
        end

        @score = @score ? @@rankings.length - @score : 0
    end

    def to_s
        @cards.collect do |card|
            "#{card.face_value.to_s} of #{card.suit.to_s}"
        end.join(', ')
    end

    #######
    private
    #######

    def self.hand(name, &block)
        @@hands[name] = block
        @@rankings << name

        define_method(name.to_s.+('?').to_sym) do
            calculate_hand(name)
        end
    end

    def calculate_hand(name)
        return false unless (block = @@hands[name])

        if @calculate_score
            @cards.sort! { |a, b| a.index <=> b.index }
            if instance_eval(&block)
                @name = name
                true
            else
                false
            end
        else
            @name == name
        end
    end

    hand :one_pair do
        (0..3).find do |x|
            value = @cards[x].face_value
            true if (@cards.count { |c| c.face_value == value }) == 2
        end
    end

    hand :two_pair do
        first     = nil
        first_pos = nil

        (0..3).each do |x|
            value = @cards[x].face_value
            if (@cards.count { |c| c.face_value == value }) == 2
                first     = value
                first_pos = x
                break
            end
        end

        if first and first_pos
            Range.new(first_pos, 4).find do |x|
                value = @cards[x].face_value
                next if value == first
                true if (@cards.count { |c| c.face_value == value }) == 2
            end
        else
            false
        end
    end

    hand :three_of_a_kind do
        (0..2).find do |x|
            value = @cards[x].face_value
            true if (@cards.count { |c| c.face_value == value }) == 3
        end
    end

    hand :steel_wheel do
        true if
            (@cards[0].index == (@cards[1].index - 1)) and
            (@cards[1].index == (@cards[2].index - 1)) and
            (@cards[2].index == (@cards[3].index - 1)) and
            (@cards[4].face_value == :ace) and
            (@cards[0].face_value == :'2')
    end

    hand :straight do
        true if
            (@cards[0].index == (@cards[1].index - 1)) and
            (@cards[1].index == (@cards[2].index - 1)) and
            (@cards[2].index == (@cards[3].index - 1)) and
            (@cards[3].index == (@cards[4].index - 1))
    end

    hand :flush do
        true if
            (@cards[0].suit == @cards[1].suit) and
            (@cards[0].suit == @cards[2].suit) and
            (@cards[0].suit == @cards[3].suit) and
            (@cards[0].suit == @cards[4].suit)
    end

    hand :full_house do
        true if three_of_a_kind? and one_pair?
    end

    hand :four_of_a_kind do
        value = @cards[0].face_value
        t = true if (@cards.count { |c| c.face_value == value }) == 4

        value = @cards[1].face_value
        t = true if (@cards.count { |c| c.face_value == value }) == 4

        t
    end

    hand :straight_flush do
        true if straight? and flush?
    end

    hand :royal_flush do
        true if straight_flush? and (@cards[4].face_value == :ace)
    end
end
