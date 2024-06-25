require_relative 'card'

class Deck
  attr_accessor :cards

  SUITS ||= ['+', '<3', '^', '<>'].freeze
  VALUES ||= Array(2..10).concat(%w[J Q K A])

  def initialize
    @cards = []
    generate
  end

  def shuffle
    cards.shuffle!
  end

  private

  def generate
    VALUES.product(SUITS) { |value, suit| cards << Card.new(value, suit) }
  end
end
