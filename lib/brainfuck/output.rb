module Brainfuck
  # Presents an output-stream of data to an interpreter.
  # 
  # Example:
  #
  #   require "brainfuck/output"
  #
  #   input = Brainfuck::Output.new
  #   output.read("a")
  #
  # This class is intended to be used more as a template to describe the
  # interfae you'd impliement if creating your own output sink (e.g. that
  # always writes to /dev/null for testing or that always writes to a named pipe
  # instead instead of allowing one to be passed by shell-redirection.
  class Output

    # The range of accecptable values that your output source will allow you
    # to write. The stream only accepts one byte at a time but other
    # implementations may further restirct the range to 'printable ascii' or
    # some other subset.
    BYTE_VALUE_RANGE = (0..255)

    # Create a new output stream
    def initialize
      @destination = STDOUT
    end

    # Write a single byte of data to the output stream. This may raise an
    # exception like ENOENT if the output stream is invalid and that should be
    # handled by the caller.
    def write(data)
      raise ArgumentError.new("must write exactly byte") unless BYTE_VALUE_RANGE.include?(data)
      @destination.write(data.chr)
    end

  end

end
