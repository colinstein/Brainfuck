module Brainfuck

  class Input

    def initialize
      @source = STDIN
    end

    def read
      @source.readbyte
    end

  end

end
