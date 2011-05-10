class Player
    attr_reader :hand_name

    def initialize
        @hand = []
        @score = 0
        @hand_name = :high_card
        @calculate_score = false
    end

    def receive_card(card)
        @hand << card
        @calculate_score = true
    end

    def retrieve_cards
        cards = @hand.dup
        @hand.clear
        @calculate_score = true

        cards
    end

    def score
        return @score unless @calculate_score

        @score =
            if    royal_flush?;     10
            elsif straight_flush?;  9
            elsif four_of_a_kind?;  9
            elsif full_house?;      7
            elsif flush?;           6
            elsif straight?;        5
            elsif steel_wheel?;     4
            elsif three_of_a_kind?; 3
            elsif two_pair?;        2
            elsif one_pair?;        1
            else;                   0
            end
    end

    def hand
        @hand.dup
    end

    def royal_flush?
        calculate_hand(:royal_flush) do
            true if straight_flush? and (@hand[4].face_value == :ace)
        end
    end

    def straight_flush?
        calculate_hand(:straight_flush) do
            true if straight? and flush?
        end
    end

    def four_of_a_kind?
        calculate_hand(:four_of_a_kind) do
            value = @hand[0].face_value
            t = true if (@hand.count { |c| c.face_value == value }) == 4

            value = @hand[1].face_value
            t = true if (@hand.count { |c| c.face_value == value }) == 4

            t
        end
    end

    def full_house?
        calculate_hand(:full_house) do
            true if three_of_a_kind? and one_pair?
        end
    end

    def flush?
        calculate_hand(:flush) do
            true if
                (@hand[0].suit == @hand[1].suit) and
                (@hand[0].suit == @hand[2].suit) and
                (@hand[0].suit == @hand[3].suit) and
                (@hand[0].suit == @hand[4].suit)
        end
    end

    def straight?
        calculate_hand(:straight) do
            true if
                (@hand[0].index == (@hand[1].index - 1)) and
                (@hand[1].index == (@hand[2].index - 1)) and
                (@hand[2].index == (@hand[3].index - 1)) and
                (@hand[3].index == (@hand[4].index - 1))
        end
    end

    def steel_wheel?
        calculate_hand(:steel_wheel) do
            true if
                (@hand[0].index == (@hand[1].index - 1)) and
                (@hand[1].index == (@hand[2].index - 1)) and
                (@hand[2].index == (@hand[3].index - 1)) and
                (@hand[4].face_value == :ace) and
                (@hand[0].face_value == :'2')
        end
    end

    def three_of_a_kind?
        calculate_hand(:three_of_a_kind) do
            (0..2).find do |x|
                value = @hand[x].face_value
                true if (@hand.count { |c| c.face_value == value }) == 3
            end
        end
    end

    def two_pair?
        calculate_hand(:two_pair) do
            first     = nil
            first_pos = nil

            (0..3).each do |x|
                value = @hand[x].face_value
                if (@hand.count { |c| c.face_value == value }) == 2
                    first     = value
                    first_pos = x
                    break
                end
            end

            return false unless first

            Range.new(first_pos, 4).find do |x|
                value = @hand[x].face_value
                next if value == first
                true if (@hand.count { |c| c.face_value == value }) == 2
            end
        end
    end

    def one_pair?
        calculate_hand(:one_pair) do
            (0..3).find do |x|
                value = @hand[x].face_value
                true if (@hand.count { |c| c.face_value == value }) == 2
            end
        end
    end

    #######
    private
    #######

    def calculate_hand(hand_name)
        if @calculate_score
            @hand.sort! { |a, b| a.index <=> b.index }
            if yield
                @hand_name = hand_name
                true
            else
                false
            end
        else
            @hand_name == hand_name
        end
    end
end
