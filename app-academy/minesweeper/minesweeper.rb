# encodinng = UTF-8
require 'yaml'

class Tile
  COVERED = 1
  UNCOVERED = 2

  attr_accessor :type, :status, :bomb, :flagged, :output

  def initialize(board, pos)
    @board = board
    @status = COVERED
    @bomb = false
    @flagged = false
    @output = "X"
    @pos = pos
  end

  def reveal
    @status = UNCOVERED
    return false if @bomb
    adjacent = adjacent_tiles
    count = count_bombs(adjacent)
    if count == 0
      reveal_adjacent(adjacent)
    else
      @output = count.to_s
    end
    true
  end

  def reveal_adjacent(adjacent)
    adjacent.each do |pos|
      tile = @board.grid[pos[0]][pos[1]]
      tile.reveal unless tile.flagged || tile.status == UNCOVERED
      @output = " "
    end
  end

  def flag
    if @status == COVERED
      @flagged = true
      @output = "F"
    end
    true
  end

  def count_bombs(adjacent)
    count = 0
    adjacent.each do |pos|
      count += 1 if @board.grid[pos[0]][pos[1]].bomb
    end
    count
  end

  def adjacent_tiles
    adjacent = []
    (-1).upto(1) do |row_mod|
      (-1).upto(1) do |col_mod|
        adjacent << [@pos[0] + row_mod, @pos[1] + col_mod]
      end
    end

    filter_bounds(adjacent)
  end

  def filter_bounds(adjacent)
    adjacent.select! do |pos|
      offgrid = false
      offgrid = true unless pos[0] < @board.grid.length && pos[1] < @board.grid.length
      offgrid = true unless pos[0] >= 0 && pos[1] >= 0
      !offgrid
    end
    adjacent
  end

  def print
    printf @output
  end
end

class MineSweeper

  def play
    turns = 0

    if prompt("New game or load game? (N/L)").downcase == "l"
      @board = load
      @board.print
    else
      size = prompt("What size board?").to_i
      @board = Board.new(size)
      @board.print
    end

    until @board.won?
      turns += 1
      move_type, tile = get_move
      return if move_type.nil?
      make_first_move(tile) if turns == 1
      didnt_lose = make_move(move_type, tile)

      puts "\e[H\e[2J"
      @board.print
      break unless didnt_lose
    end

    @board.reveal_all
    @board.print
    if @board.won?
      puts "Congratulations!"
      highscores
    else
      puts "You lose!"
    end
    play if prompt("Do you want to play again? (Y/N)").downcase == "y"
  end

  def make_first_move(tile)
    @board.make_bombs(tile)
  end

  def highscores
    score = Time.now - @board.start_time
    highscores = nil
    if File.exists?("highscores")
      highscores = load_highscores
    else
      highscores = HighscoreList.new
    end

    if highscores.scores.empty?
      highscores.record(0, score)
    end
    highscores.scores.each_with_index do |old_score, index|
      if score < old_score
        highscores.record(index, score)
        break
      end
    end

    highscores.print

    save_highscores(highscores)
  end

  def load_highscores
    YAML::load(File.read("highscores"))
  end

  def save_highscores(scores)
    File.open("highscores","w") do |file|
      file.puts scores.to_yaml
    end
  end

  def get_move
    move_type = prompt("What kind of move (F = Flag, R = Reveal, or S to save and quit)").downcase
    if move_type != "f" && move_type != "r" && move_type != "s"
      puts "Invalid move type."
      return get_move
    end

    if move_type == "s"
      save
      return nil, nil
    end

    move_row = prompt("What row do you want to move in?").to_i - 1
    move_col = prompt("What column do you want to move in?").to_i - 1
    if move_row > @board.grid.length - 1 || move_col > @board.grid.length - 1
      puts "Invalid selection"
      return get_move
    end

    return move_type, @board.grid[move_row][move_col]
  end

  def make_move(type, tile)
    case type
    when "f"
      return tile.flag
    when "r"
      return tile.reveal unless tile.flagged
    end
  end

  def prompt(*args)
    puts args
    gets.chomp
  end


  def save
    File.open("saved_data","w") do |file|
      file.puts @board.to_yaml
    end
  end

  def load
    YAML::load(File.read("saved_data"))
  end
end

class Board
  attr_reader :grid, :start_time

  def initialize(size)
    @grid = []
    0.upto(size-1) do |row|
      layer = []
      0.upto(size-1) do |col|
        layer << Tile.new(self, [row, col])
      end
      @grid << layer
    end
    @start_time = Time.now
  end

  def reveal_all
    @grid.each do |row|
      row.each do |tile|
        if tile.bomb
          tile.output = "B"
        else
          tile.output = " "
        end
      end
    end
  end

  def make_bombs(tile)
    num = 10 if @grid.length == 9
    num = 40 if @grid.length == 16
    num.times do
      pos = [Random.rand(@grid.length), Random.rand(@grid.length)]
      while @grid[pos[0]][pos[1]].bomb && @grid[pos[0]][pos[1]] != tile
        pos = [Random.rand(@grid.length), Random.rand(@grid.length)]
      end
      @grid[pos[0]][pos[1]].bomb = true
    end
  end

  def won?
    won = true
    @grid.each do |row|
      row.each do |tile|
        won = false if tile.status == Tile::COVERED && !tile.bomb
      end
    end
    won
  end

  def first_row
    printf "    "
    1.upto(@grid.length) do |num|
      if num >= 10
        printf "1 "
      else
        printf num.to_s + " "
      end
    end
  end

  def second_row
    printf "\n    "
    1.upto(@grid.length) do |num|
      if num >= 10
        printf "#{num % 10}"
      else
        printf " "
      end
      printf " "
    end
  end

  def print_grid
    printf "\n"
    @grid.each_with_index do |row, row_num|
      print_separator
      printf (row_num+1).to_s
      printf " " if row_num < 9
      printf " "
      row.each do |tile|
        printf "|"
        tile.print
      end
      printf "|\n"
    end
  end

  def print
    first_row
    second_row
    print_grid
    print_separator
  end

  def print_separator
    printf "   |"
    (( @grid.length * 2) - 1).times { printf "-" }
    printf "|\n"
  end
end

class HighscoreList
  attr_reader :names, :scores

  def initialize
    @names = []
    @scores = []
  end

  def record(index, score)
    @scores.insert(index, score)
    puts "What is your name?"
    @names.insert(index, gets.chomp)
  end

  def print
    @scores.each_index do |index|
      puts "#{index+1}: #{@names[index]} - #{@scores[index]}"
      break if index == 9
    end
  end
end

MineSweeper.new.play