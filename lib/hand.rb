class Hand
    attr_reader :name, :ranked, :kickers

    @@hands = {}
    @@tie_breakers = {}
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

    def resolve_tie(other_hand)
        block = @@tie_breakers[@name]
        instance_exec(other_hand, &block)
    end

    #######
    private
    #######

    def self.hand(name)
        @@rankings << name
        @@hand = name

        yield

        @@hand = nil
    end

    def self.match(&block)
        method = (hand = @@hand).to_s.+('?').to_sym
        @@hands[hand] = block

        define_method(method) do
            calculate_hand(hand)
        end
    end

    def self.resolve_tie(&block)
        @@tie_breakers[@@hand] = block
    end

    def calculate_hand(name)
        return false unless (block = @@hands[name])

        if @calculate_score
            @cards.sort! { |a, b| a.index <=> b.index }
            @ranked  = []
            @kickers = []

            instance_eval(&block)

            unless @ranked.empty?
                @kickers = @cards - @ranked
                @name = name
                true
            else
                false
            end
        else
            @name == name
        end
    end

    hand :high_card do
        match { @ranked = @cards }

        resolve_tie do |other_hand|
            sort = 0

            @ranked.each_index do |x|
                sort = @ranked[x] <=> other_hand.ranked[x]
                break unless sort == 0
            end

            sort
        end
    end

    hand :one_pair do
        match do
            (0..3).find do |x|
                value = @cards[x].face_value
                cards = @cards.find_all { |card| card.face_value == value }

                if cards.length == 2
                    @ranked  = cards
                    @kickers = @cards - @ranked
                end
            end
        end

        resolve_tie do |other_hand|
            if (sort = @ranked[0] <=> other_hand.ranked[0]) == 0
                @kickers.each_index do |x|
                    sort = @kickers[x] <=> other_hand.kickers[x]
                    break unless sort == 0
                end
            end
            sort
        end
    end

    hand :two_pair do
        match do
            (0..3).each do |x|
                value = @cards[x].face_value
                cards = @cards.find_all { |card| card.face_value == value }

                if cards.length == 2
                    @ranked = cards
                    break
                end
            end

            found = false
            if @ranked.length > 0
                (2..4).each do |x|
                    value = @cards[x].face_value
                    next if value == @ranked[0].face_value

                    cards = @cards.find_all { |card| card.face_value == value }
                    if cards.length == 2
                        @ranked += cards
                        found = true
                        break
                    end
                end
            end

            @ranked.clear unless found
        end

        resolve_tie do |other_hand|
            if (sort = @ranked[0] <=> other_hand.ranked[0]) == 0
                if (sort = @ranked[2] <=> other_hand.ranked[2]) == 0
                    sort = @kickers[0] <=> other_hand.kickers[0]
                end
            end

            sort
        end
    end

    hand :three_of_a_kind do
        match do
            (0..2).find do |x|
                value = @cards[x].face_value
                cards = @cards.find_all { |card| card.face_value == value }

                if cards.length == 3
                    @ranked = cards
                    break
                end
            end
        end

        resolve_tie do |other_hand|
            if (sort = @ranked[0] <=> other_hand.ranked[0]) == 0
                @kickers.each_index do |x|
                    sort = @kickers[x] <=> other_hand.kickers[x]
                end
            end
            sort
        end
    end

    hand :steel_wheel do
        match do
            if (@cards[0].index == (@cards[1].index - 1)) and
               (@cards[1].index == (@cards[2].index - 1)) and
               (@cards[2].index == (@cards[3].index - 1)) and
               (@cards[4].face_value == :ace) and
               (@cards[0].face_value == :'2')
                @ranked = @cards.dup
            end
        end

        resolve_tie { 0 } # can't
    end

    hand :straight do
        match do
            if (@cards[0].index == (@cards[1].index - 1)) and
               (@cards[1].index == (@cards[2].index - 1)) and
               (@cards[2].index == (@cards[3].index - 1)) and
               (@cards[3].index == (@cards[4].index - 1))
                @ranked = @cards.dup
            end
        end

        resolve_tie do |other_hand|
            @ranked[4] <=> other_hand.ranked[4]
        end
    end

    hand :flush do
        match do
            if (@cards[0].suit == @cards[1].suit) and
               (@cards[0].suit == @cards[2].suit) and
               (@cards[0].suit == @cards[3].suit) and
               (@cards[0].suit == @cards[4].suit)
                @ranked = @cards.dup
            end
        end

        resolve_tie do |other_hand|
            @ranked.each_index do |x|
                sort = @ranked[x] <=> other_hand.ranked[x]
                break unless sort == 0
            end
        end
    end

    hand :full_house do
        match do
            ranked = nil

            ranked = @ranked.dup if three_of_a_kind?
            if one_pair?
                @ranked = ranked + @ranked
            end if ranked
        end

        resolve_tie do |other_hand|
            if (sort = @ranked[0] <=> other_hand.ranked[0]) == 0
                sort = @ranked[3] <=> other_hand.ranked[3]
            end
            sort
        end
    end

    hand :four_of_a_kind do
        match do
            (0..1).each do
                value = @cards[0].face_value
                cards = @cards.find_all { |card| card.face_value == value }

                if cards.length == 4
                    @ranked = cards
                    break
                end
            end
        end

        resolve_tie do |other_hand|
            if (sort = @ranked[0] <=> other_hand.ranked[0]) == 0
                sort = @kickers[0] <=> other_hand.kickers[0]
            end
            sort
        end
    end

    hand :straight_flush do
        match { straight? and flush? }

        resolve_tie do |other_hand|
            @ranked[4] <=> other_hand.ranked[4]
        end
    end

    hand :royal_flush do
        match do
            if straight_flush?
                @ranked.clear unless @ranked[4].face_value == :ace
            end
        end

        resolve_tie { 0 } # can't
    end
end
