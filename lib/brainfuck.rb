require "brainfuck/bounds_checker"
require "brainfuck/input"
require "brainfuck/memory"
require "brainfuck/output"
require "brainfuck/program"
require "brainfuck/machine"
require "brainfuck/version"

module Brainfuck
  # Creates a new interpreter.
  # Example:
  #
  #   # from a file
  #   bf = Brainfuck.interpreter(file: "Foo.bf")
  #   bf.run
  #
  #   # from a string
  #   bf = Brainfuck.interpreter(source: "+++++++++++."
  #   bf.run
  #
  # This can raise some exceptoins if the arugments don't make sense. It is
  # possible to generate an interpreter with invalid source which will raise an
  # exception when you attempt to run the interpreter.
  #
  # Example:
  #
  #   bf = Brainfuck.new(source: "++[") # invalid program: unmatched jump
  #   bf.run                            # => StandardError
  def self.interpreter(file: nil, source: nil)
    raise ArgumentError.new("must pass only one of filename or source string") if file && source
    raise ArgumentError.new("must pass filename or source string") unless file || source
    program = file ? Program.from_file(file) : Program.from_string(source)
    return Machine.new(program: program)
  end

end
