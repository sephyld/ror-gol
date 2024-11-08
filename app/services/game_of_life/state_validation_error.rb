module GameOfLife
  class StateValidationError < StandardError
    def initialize(msg = "Game Of Life invalid state")
      super(msg)
    end
  end
end
