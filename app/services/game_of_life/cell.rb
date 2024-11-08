module GameOfLife
  class Cell
    attr_reader :state

    def initialize(state)
      raise TypeError, "Cell must be initialized with a CellState" unless state == CellState::DEAD || CellState::ALIVE
      @state = state
    end

    def is_alive?
      @state == CellState::ALIVE
    end

    def is_dead?
      @state == CellState::DEAD
    end

    def switch
      Cell.new(is_alive? ? CellState::DEAD : CellState::ALIVE)
    end

    def switch!
      @state = is_alive? ? CellState::DEAD : CellState::ALIVE
    end

    def state=(state)
      raise TypeError, "Cell state must be a valid CellState" unless state == CellState::DEAD || CellState::ALIVE
      @state = state
    end

    def self.make_random
      rand(2) == 0 ? Cell.make_alive : Cell.make_dead
    end

    def self.make_alive
      Cell.new CellState::ALIVE
    end

    def self.make_dead
      Cell.new CellState::DEAD
    end

    def to_s
      @state
    end
  end
end
