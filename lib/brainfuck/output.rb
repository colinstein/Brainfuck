module Brainfuck
  BYTE_VALUE_RANGE = (0..255)

  class Output

    def initialize
      @destination = STDOUT
    end

    def write(data)
      raise ArgumentError.new("must write exactly byte") unless BYTE_VALUE_RANGE.include?(data)
      @destination.write(data.chr)
    end

  end

end
