module Brainfuck
  # Presents an input-stream of data to an interpreter.
  # 
  # Example:
  #
  #   require "brainfuck/input"
  #
  #   input = Brainfuck::Input.new
  #   input.read
  #
  # This class is intended to be used more as a template to describe the
  # interfae you'd impliement if creating your own input source (e.g. that
  # always returns the same stream of bytes for testing, or that wraps a named
  # pipe instead instead of allowing one to be passed by shell-redirection.
  class Input

    # Create an input stream.
    def initialize
      @source = STDIN
    end

    # Read a single byte of input from the source. This may raise errors such
    # as ENOENT if the source is invalid and should be handled by the collar.
    def read
      @source.readbyte
    end

  end

end
