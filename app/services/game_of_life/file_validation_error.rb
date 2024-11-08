module GameOfLife
  class FileValidationError < StandardError
    def initialize(msg = "File format error")
      super(msg)
    end
  end
end
