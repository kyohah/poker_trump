module PokerTrump
  class Cards < Array
    include Comparable
    DeleteError = Class.new(StandardError)

    class << self
      def new_deck
        cards = PokerTrump::Card::RANKS.product(PokerTrump::Card::SUITS).map do |rank, suit|
          PokerTrump::Card.new(rank: rank, suit: suit)
        end

        new(cards)
      end

      def from_string(string)
        cards = string.scan(/[AKQJT2-9][shdc]/).map { |s| PokerTrump::Card.from_string(s) }

        new(cards)
      end

      def from_json(json)
        cards = JSON.parse(json).map { |c| PokerTrump::Card.new(rank: c['rank'], suit: c['suit'].to_sym) }

        new(cards)
      end
    end

    def delete_card!(card)
      i = index(card)
      raise DeleteError if i.nil?

      delete_at(i)
      self
    end

    def delete_card(card)
      i = index(card)
      raise DeleteError if i.nil?

      clone_cards = clone
      clone_cards.delete_at(i)

      clone_cards
    end

    def delete_cards!(cards)
      cards.each { |t| delete_card!(t) }
      self
    end

    def delete_cards(cards)
      clone_cards = clone
      cards.each { |t| clone_cards.delete_card!(t) }
      clone_cards
    end

    def add_card(card)
      clone_cards = clone
      clone_cards.push(card)
    end

    def add_card!(card)
      push(card)
    end

    def add_cards(cards)
      clone_cards = clone

      cards.each { |card| clone_cards.add_card!(card) }
      clone_cards
    end

    def add_cards!(cards)
      cards.each { |card| add_card!(card) }
      self
    end

    def sort_by_suit
      self.class.new(sort_by { |card| [card.suit, card.rank_value] }.reverse)
    end

    def sort_by_rank
      @sort_by_rank ||= self.class.new(sort_by { |card| [card.rank_value, card.suit] }.reverse)
    end

    def to_s
      map(&:to_s).join(' ')
    end

    def group_by_suit
      @group_by_suit ||= group_by(&:suit).each_with_object({}) { |(k, v), h| h[k] = self.class.new(v) }
    end

    def royal_flush_rate
      [10, 0, 0, 0, 0, 0] if /A(.) K\1 Q\1 J\1 T\1/.match?(sort_by_suit.to_s)
    end

    def straight_flush_rate
      group_by_suit.each do |_k, v|
        next if v.size < 5

        a = v.straight_rate
        return [9, a[1], a[2], a[3], a[4], a[5]] if a
      end
      nil
    end

    def four_of_a_kind_rate
      a = sort_by_rank.to_s.match(/(.). \1. \1. \1./)

      if a
        b = (a.pre_match + a.post_match).match(/(\S)/).to_s

        [8, PokerTrump::Card::RANK_VALUE[a[1]], PokerTrump::Card::RANK_VALUE[b.to_s], 0, 0, 0]
      end
    end

    def full_house_rate
      case sort_by_rank.to_s
      when /(.). \1. \1. (.*)(.). \3./
        [7, PokerTrump::Card::RANK_VALUE[Regexp.last_match(1)], PokerTrump::Card::RANK_VALUE[Regexp.last_match(3)], 0,
         0, 0]
      when /((.). \2.) (.*)((.). \5. \5.)/
        [7, PokerTrump::Card::RANK_VALUE[Regexp.last_match(5)], PokerTrump::Card::RANK_VALUE[Regexp.last_match(2)], 0,
         0, 0]
      end
    end

    def flush_rate
      group_by_suit.each do |_k, v|
        next if v.size < 5

        z = v.sort_by_rank
        return [6, z[0].rank_value, z[1].rank_value, z[2].rank_value, z[3].rank_value, z[4].rank_value]
      end

      nil
    end

    def straight_rate
      a = sort_by_rank.to_s.match(/(?<_A>A.+K.+Q.+J.+T)|(?<_K>K.+Q.+J.+T.+9)|(?<_Q>Q.+J.+T.+9.+8)|(?<_J>J.+T.+9.+8.+7)|(?<_T>T.+9.+8.+7.+6)|(?<_9>9.+8.+7.+6.+5)|(?<_8>8.+7.+6.+5.+4)|(?<_7>7.+6.+5.+4.+3)|(?<_6>6.+5.+4.+3.+2)|(?<_5>A.+5.+4.+3.+2)/)

      if a
        case
        when a.send(:[], :_A)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('A', 'K', 'Q', 'J', 'T')]
        when a.send(:[], :_K)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('K', 'Q', 'J', 'T', '9')]
        when a.send(:[], :_Q)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('Q', 'J', 'T', '9', '8')]
        when a.send(:[], :_J)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('J', 'T', '9', '8', '7')]
        when a.send(:[], :_T)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('T', '9', '8', '7', '6')]
        when a.send(:[], :_9)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('9', '8', '7', '6', '5')]
        when a.send(:[], :_8)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('8', '7', '6', '5', '4')]
        when a.send(:[], :_7)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('7', '6', '5', '4', '3')]
        when a.send(:[], :_6)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('6', '5', '4', '3', '2')]
        when a.send(:[], :_5)
          [5, *PokerTrump::Card::RANK_VALUE.values_at('5', '4', '3', '2', 'A')]
        end
      end
    end

    def three_of_a_kind_rate
      md = sort_by_rank.to_s.match(/(.). \1. \1./)

      if md
        arranged_hand = (md.pre_match + md.post_match).strip.squeeze(' ')

        [4, PokerTrump::Card::RANK_VALUE[md[1]], PokerTrump::Card::RANK_VALUE[arranged_hand[0]],
         PokerTrump::Card::RANK_VALUE[arranged_hand[3]], 0, 0]
      end
    end

    def two_pair_rate
      md = sort_by_rank.to_s.match(/(.). \1.(.*?) (.). \3./)

      if md
        arranged_hand = (md.pre_match + ' ' + md[2] + ' ' + md.post_match).strip.squeeze(' ')
        [3, PokerTrump::Card::RANK_VALUE[md[1]], PokerTrump::Card::RANK_VALUE[md[3]],
         PokerTrump::Card::RANK_VALUE[arranged_hand[0]], 0, 0]
      end
    end

    def one_pair_rate
      md = sort_by_rank.to_s.match(/(.). \1./)

      if md
        arranged_hand = (md.pre_match + ' ' + md.post_match).strip.squeeze(' ')

        [2, PokerTrump::Card::RANK_VALUE[md[1]], PokerTrump::Card::RANK_VALUE[arranged_hand[0]],
         PokerTrump::Card::RANK_VALUE[arranged_hand[3]], PokerTrump::Card::RANK_VALUE[arranged_hand[6]], 0]
      end
    end

    def high_card_rate
      arranged_hand = sort_by_rank.to_s

      [1, PokerTrump::Card::RANK_VALUE[arranged_hand[0]], PokerTrump::Card::RANK_VALUE[arranged_hand[3]],
       PokerTrump::Card::RANK_VALUE[arranged_hand[6]], PokerTrump::Card::RANK_VALUE[arranged_hand[9]], PokerTrump::Card::RANK_VALUE[arranged_hand[12]]]
    end

    def score
      @score ||= royal_flush_rate || straight_flush_rate || four_of_a_kind_rate || full_house_rate || flush_rate || straight_rate || three_of_a_kind_rate || two_pair_rate || one_pair_rate || high_card_rate
    end

    def <=>(other)
      score <=> other.score
    end
  end
end
