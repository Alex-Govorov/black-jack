require_relative 'deck'
require_relative 'player'

class BlackJack
  attr_accessor :player, :dealer, :deck, :bank

  PERMITED_ACTIONS ||= %i[dealer_turn add_card_to_player showdown start exit].freeze

  def initialize
    @player = Player.new
    @dealer = Player.new
    @player.money = @dealer.money = 100
  end

  def start
    @showdown = false
    @bank = 0
    @winner = nil
    @board_state = {}
    @player.cards.clear
    @dealer.cards.clear
    @deck = Deck.new
    @deck.shuffle
    distribute_cards(@player, 2)
    distribute_cards(@dealer, 2)
    make_bet(@player)
    make_bet(@dealer)
    player_turn
  end

  def distribute_cards(player, number)
    number.times { player.cards << @deck.cards.shift }
  end

  def make_bet(player)
    player.money -= 10
    @bank += 10
  end

  def board_state
    @board_state[:bank] = @bank
    @board_state[:player_money] = @player.money
    @board_state[:dealer_money] = @dealer.money
    @board_state[:player_cards] = @player.cards.map { |card| { value: card.value.to_s, suit: card.suit } }
    @board_state[:player_cards_value] = @player.cards_value
    board_state_conditions
    @board_state
  end

  def board_state_conditions
    @board_state[:player_action] = @player_action if @player_action.any?

    if @winner
      @board_state[:winner] = @winner
      @board_state[:dealer_cards] = @dealer.cards.map { |card| { value: card.value.to_s, suit: card.suit } }
      @board_state[:dealer_cards_value] = @dealer.cards_value
    else
      @board_state[:dealer_cards] = @dealer.cards.map { |_card| { value: '*', suit: '*' } }
    end
  end

  def player_decision(key)
    raise 'Hack Attempt!!! Exiting!!!' unless PERMITED_ACTIONS.include?(key)

    @player_action.clear
    send key
  end

  def player_turn
    set_winner
    set_player_action
    bank_processing
    board_state
  end

  def dealer_turn
    distribute_cards(@dealer, 1) if @dealer.cards_value < 17
    player_turn
  end

  def showdown
    @showdown = true
    player_turn
  end

  def set_winner
    return unless (@player.cards.count & @dealer.cards.count == 3) || @showdown == true

    @winner = player_or_dealer
    @winner = 'draw' if @player.cards_value == @dealer.cards_value
    @winner = 'casino' if @player.cards_value & @dealer.cards_value > 21
  end

  def player_or_dealer
    players_score = { player: @player.cards_value, dealer: @dealer.cards_value }
    winner = players_score.select { |_key, value| value <= 21 }.max_by { |_key, value| value }
    winner.first.to_s if winner
  end

  def set_player_action
    if @winner
      @player_action = { action: 'Сыграем еще?: ', start: 'Да', exit: 'Нет' }
    else
      @player_action = { action: 'Ваш ход: ', dealer_turn: 'Пропустить', showdown: 'Открыть карты' }
      @player_action[:add_card_to_player] = 'Добавить карту' if @player.cards.count == 2
    end
  end

  def add_card_to_player
    distribute_cards(@player, 1)
    dealer_turn
  end

  def bank_processing
    return unless @winner

    @player.money += @bank if @winner == 'player'
    @dealer.money += @bank if @winner == 'dealer'
    if @winner == 'draw'
      @player.money += @bank / 2
      @dealer.money += @bank / 2
    end
    @bank = 0
  end
end
