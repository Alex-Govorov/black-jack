class Player
  attr_accessor :cards, :money

  def initialize
    @cards = []
  end

  def cards_value
    cards_values = cards.map(&:value)
    cards_values.map! { |card_value| ace_to_eleven(card_value) }
    cards_values.map! { |card_value| pictures_to_ten(card_value) }
    cards_values.map! { |card_value| ace_to_one_if_needed(card_value, cards_values) }
    cards_values.sum
  end

  private

  def ace_to_eleven(card_value)
    card_value == 'A' ? 11 : card_value
  end

  def pictures_to_ten(card_value)
    card_value.is_a?(String) ? 10 : card_value
  end

  def ace_to_one_if_needed(card_value, cards_values)
    card_value == 11 && cards_values.sum > 21 ? 1 : card_value
  end
end
