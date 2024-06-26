require_relative 'blackjack'

class TextInterface
  UNICODE_SUITS ||= { '+' => '♣', '<3' => '♥', '^' => '♠', '<>' => '♦' }.freeze
  WINNER ||= { 'player' => 'Побеждает игрок, вы молодец!',
               'dealer' => 'Побеждает дилер =P',
               'draw' => 'Ничья, деньги возвращаются игрокам',
               'casino' => 'Никто не выиграл, деньги забирает казино' }.freeze
  def initialize
    @blackjack = BlackJack.new
    enter_your_name
    start
  end

  private

  def enter_your_name
    puts 'Как вас зовут?'
    @name = gets.chomp.to_s
  end

  def start
    show_board(@blackjack.start)
  end

  def show_board(board_state)
    board_state[:player_cards] = format_cards_to_str(board_state[:player_cards])
    board_state[:dealer_cards] = format_cards_to_str(board_state[:dealer_cards])
    player_info(board_state)
    dealer_info(board_state)
    winner(board_state[:winner])
    player_action(board_state[:player_action])
  end

  def player_action(action)
    return unless action

    puts action[:action]
    action.each_with_index { |(_key, value), index| puts "#{index}. #{value}" unless index.zero? }
    input = gets.chomp.to_i
    validate_input(action, input)
    show_board(@blackjack.player_decision(action.keys[input]))
  end

  def format_cards_to_str(cards)
    cards.map { |card| "|#{card[:value]}#{UNICODE_SUITS[(card[:suit])]}|" }.join(' ')
  end

  def validate_input(action, input)
    raise 'Ошибка ввода' unless (Array 1..action.keys.count - 1).include?(input)
  rescue StandardError
    puts 'Выбран не существующий пункт меню, попробуйте еще раз'
    player_action(action)
  end

  def winner(winner)
    puts WINNER[winner] if winner
  end

  def player_info(board_state)
    puts "
    Банк: #{board_state[:bank]}$

    #{@name} #{board_state[:player_money]}$
    #{board_state[:player_cards]} #{board_state[:player_cards_value]}"
  end

  def dealer_info(board_state)
    puts "
    Дилер #{board_state[:dealer_money]}$
    #{board_state[:dealer_cards]} #{board_state[:dealer_cards_value]}"
  end
end
