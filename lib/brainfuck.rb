require "brainfuck/bounds_checker"
require "brainfuck/input"
require "brainfuck/memory"
require "brainfuck/output"
require "brainfuck/program"
require "brainfuck/machine"
require "brainfuck/version"

module Brainfuck
  def self.interpreter(file: nil, source: nil)
    raise ArgumentError.new("must pass only one of filename or source string") if file && source
    raise ArgumentError.new("must pass filename or source string") unless file || source
    program = file ? Program.from_file(file) : Program.from_string(source)
    return Machine.new(program: program)
  end
end
