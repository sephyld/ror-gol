module GameOfLife
  class GameState
    attr_accessor :generation, :rows, :columns, :grid

    def initialize *args
      raise ArgumentError, "Wrong number of arguments. Expected 1..4, given #{args.length}" unless args.length > 0 and args.length < 5

      if args[0].kind_of? File or args[0].kind_of? Tempfile then
        init_with_file args[0]
        return
      end

      if args[0].kind_of? String then
        init_with_file_name args[0]
        return
      end

      raise ArgumentError, "Wrong number of arguments. Expected 4, given #{args.length}" unless args.length == 4
      init_with_arguments args
      validate_self
    end

    def self.random
      g = 1
      r = rand(20..70)
      c = rand(20..70)
      grid = []
      r.times do
        row = []
        c.times do
          row << Cell.make_random
        end
        grid << row
      end
      GameState.new(g, r, c, grid)
    end

    def [](row, col)
      @grid[row][col]
    end

    def []=(row, col, value)
      raise StateValidationError, "Value type invalid. Only accepting type Cell" unless value.kind_of? Cell
      @grid[row][col] = value
    end

    def get_cells_nearby(row, col)
      cells = []

      cells << @grid[row - 1][col - 1]  if row > 0 and col > 0
      cells << @grid[row - 1][col]      if row > 0
      cells << @grid[row - 1][col + 1]  if row > 0 and col < (@columns - 1)

      cells << @grid[row][col - 1]      if  col > 0
      cells << @grid[row][col + 1]      if  col < (@columns - 1)

      cells << @grid[row + 1][col - 1]  if row < (@rows - 1) and col > 0
      cells << @grid[row + 1][col]      if row < (@rows - 1)
      cells << @grid[row + 1][col + 1]  if row < (@rows - 1) and col < (@columns - 1)

      cells
    end

    def count_dead_cells_nearby(row, col)
      cells_nearby = get_cells_nearby row, col
      cells_nearby.count { |c| c.is_dead? }
    end

    def count_alive_cells_nearby(row, col)
      cells_nearby = get_cells_nearby row, col
      cells_nearby.count { |c| c.is_alive? }
    end

    # overloading pretty_print causes argument error `#inspect raises #<ArgumentError: wrong number of arguments (given 1, expected 0)` when in step debugging
    # so I'm using custom_pretty_print as method name
    def custom_pretty_print
      puts "Generation #{@generation}:"
      puts "#{@rows} #{@columns}"
      @grid.each do |r|
        puts r.join
      end
      nil
    end

    def lay_down_grid
      grid = []
      @grid.each do |row|
        grid << (row.map { |cell| cell.state }).join
      end
      grid.join ";"
    end

    def next_generation
      generation = @generation + 1
      grid = []
      @grid.each_with_index do |row, i|
        new_row = []
        row.each_with_index do |cell, j|
          count_alive = count_alive_cells_nearby i, j
          if cell.is_alive? then
            should_die = count_alive < 2 || count_alive > 3
            new_row << should_die ? Cell.make_dead : Cell.make_alive
          else
            new_row << count_alive == 3 ? Cell.make_alive : Cell.make_dead
          end
        end
        grid << new_row
      end

      World.new generation, @rows, @columns, grid
    end

    def next_generation!
      @generation += 1
      indexes_to_switch = []
      @grid.each_with_index do |row, i|
        row.each_with_index do |cell, j|
          count_alive = count_alive_cells_nearby i, j
          if cell.is_alive? then
            should_die = count_alive < 2 || count_alive > 3
            indexes_to_switch << [ i, j ] if should_die
          else
            should_spawn = count_alive == 3
            indexes_to_switch << [ i, j ] if should_spawn
          end
        end
      end
      indexes_to_switch.each { |i, j| @grid[i][j].switch! }

      self
    end


    private

    def init_with_file(file)
      count_lines = file.count
      file.rewind

      first_file_row = file.readline.strip.strip
      validate_first_file_row first_file_row
      generation = first_file_row[0..-1].split(" ")[1].to_i

      second_file_row = file.readline.strip.strip
      validate_second_file_row second_file_row
      r, c = second_file_row.split.map { |n| n.to_i }

      validate_grid_rows_number(count_lines - 2, r)

      grid = file.map do |line|
        l = line.strip
        validate_grid_file_row l, c
        l.strip.chars.map { |ch| Cell.new ch }
      end

      init_with_arguments [ generation, r, c, grid ]
    end

    def init_with_file_name(file_name)
      file = File.open(file_name) do |f|
        init_with_file f
        f
      end
      file.close unless file.closed?
    end

    def init_with_arguments(args)
      @generation, @rows, @columns, @grid = args
    end

    def validate_self
      raise StateValidationError, "First argument mut be an Integer" unless @generation.kind_of? Integer
      raise StateValidationError, "Second argument mut be an Integer" unless @rows.kind_of? Integer
      raise StateValidationError, "Third argument mut be an Integer" unless @columns.kind_of? Integer
      raise StateValidationError, "Fourth argument mut be an Array" unless @grid.kind_of? Array
      raise StateValidationError, "The grid must contain exactly #{@rows} rows, as per second argument" unless @grid.length == @rows
      @grid.each do |row|
        raise StateValidationError, "The grid must contain exactly #{@columns} columns as per third argument" unless row.length == @columns
        if row.kind_of? String then
          validate_grid_file_row row, @columns
        else
          row.each do |cell|
            raise StateValidationError, "Value type invalid. Only accepting type Cell" unless cell.kind_of? Cell
          end
        end
      end
    end

    def validate_first_file_row(first_file_row)
      raise FileValidationError, "Validation error. String #{first_file_row} is not a valid first row" unless /^Generation \d+:/.match? first_file_row
    end

    def validate_second_file_row(second_file_row)
      raise FileValidationError, "Validation error. String #{second_file_row} is not a valid second row" unless /^\d+ \d+$/.match? second_file_row
    end

    def validate_grid_rows_number(grid_rows_number, rows)
      raise FileValidationError, "Validation error. Number of rows in file and declared number of rows don't match" unless grid_rows_number == rows
    end

    def validate_grid_file_row(grid_file_row, cols)
      raise FileValidationError, "Validation error. Row #{grid_file_row} is not a valid grid row" unless /^(\.|\*){#{cols}}$$/.match? grid_file_row
    end
  end
end
