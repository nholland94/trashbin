class Hangman
  def initialize
    prompt_players
  end

  #Prompts the person running the program
  #for the number of players (to determine
  #how to instantiate the player variables)
  def prompt_players
    puts "How many people are playing (0 for Computer vs. Computer)"
    case gets.chomp.to_i
    when 0
      @master_player = ComputerPlayer.new
      @master_player.create_dictionary
      @guessing_player = ComputerPlayer.new
      @guessing_player.create_dictionary
    when 1
      puts "Would you like to guess? (Y/N)"
      if gets.chomp.downcase == "y"
        @master_player = ComputerPlayer.new
        @master_player.create_dictionary
        @guessing_player = HumanPlayer.new
      else
        @master_player = HumanPlayer.new
        @guessing_player = ComputerPlayer.new
        @guessing_player.create_dictionary
      end
    when 2
      @master_player = HumanPlayer.new
      @guessing_player = HumanPlayer.new
    end
  end

  #The main run loop
  def run
    board = Board.new(@master_player.get_word)
    board.print
    until board.won? || board.full?
      guess = @guessing_player.get_guess(board)
      board.guesses << guess
      board.reveal(@master_player.confirm_guess(guess, board), guess)
      board.print
    end
  end
end

class HumanPlayer
  def get_guess(board)
    puts "Please make a guess:"
    guess = gets.chomp.downcase
    unless ("a".."z").to_a.include?(guess)
      puts "Invalid guess. Must be a letter."
      return get_guess(board)
    elsif board.guesses.include?(guess)
      puts "That has already been guessed."
      return get_guess(board)
    end
    guess
  end

  def get_word
    puts "How long is your word?"
    gets.chomp.to_i
  end

  def confirm_guess(guess, board)
    puts "The player guessed: #{guess}"
    puts "Where does that letter appear in your word?"
    puts "(separate by commas please)"
    filtered = gets.chomp
    filtered.delete(" ")
    filtered.split(",").map { |loc| loc.to_i }
  end
end

class ComputerPlayer
  def create_dictionary
    @dictionary = []
    File.new("dictionary-no-hyphens.txt").readlines.each do |line|
      @dictionary << line.chomp
    end
  end

  def get_guess(board)
    ("a".."z").to_a.sample
  end

  def get_word
    word = @dictionary.sample
    until word > 3 && word < 10
      word = @dictionary.sample
    end
    @word = word
    word.length
  end

  def confirm_guess(guess, board)
    correct_positions = []
    word.to_a.each_with_index do |letter, index|
      if guess == letter
        correct_positions << index
      end
    end
    correct_positions
  end
end

class Board
  attr_reader :word, :guesses

  def initialize(word_length)
    @word = ["_"]*word_length
    @guesses = []
  end

  def print
    print_helper
    puts "\# #{@word.join(" ")} \#"
    puts "\# #{(1..@word.legnth).to_a.join(" ")} \#"
    print_helper
    puts "Already guessed: #{@guesses.join(", ")}"
  end

  def print_helper
    (@word.length+3).times { printf "\#"}
    printf "\n"
  end

  def reveal(positions, letter)
    positions.each { |pos| word[pos] = letter }
  end
end