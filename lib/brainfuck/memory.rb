require "forwardable"

module Brainfuck
  # Models the RAM or ROM for the virtual machine / interpreter.
  # Example:
  #
  #   require "memory"
  #
  #   mem = Brainfuck::Memory.new
  #   bf = Brainfuck::Machine.new(program: program, memory: mem)
  #   bf.run
  #
  # You can optionally specify the minimum and maximum values that can go into
  # a memory cell, the number of cells in the memory, and the default value for
  # an uninitialized cell. Cells will need to respond to the '#next' and '#pred'
  # methods and be representable as a byte in order to properly work with the
  # virtual machine.
  class Memory
    extend BoundsChecker  # Ensure that memory access is 'sane'
    extend Forwardable    # Allows Array/Range to supply part of the interface

    MIN_VALUE = 0         # The minimum value that can be stored in a cell
    MAX_VALUE = 255       # The maximum value that can be stored in a cell
    DEFAULT_SIZE = 30_000 # The number of memory cells

    def_delegator :@value_range, :min, :minimum_value  # "#min" interface
    def_delegator :@value_range, :max, :maximum_value  # "#max" interface
    def_delegator :@cells, :size                       # "#size" interface

    # Ensure that you cannot read or write outside of the pre-declared size
    check_bounds :read, :write, proc: ->(i) { (0..size).include? i }

    # Create a new memory. By default the values for minimum and maximum value,
    # default value, and number of cells are consistent with most common
    # Brainfuck implementations but these can be overwritten. Will raise an
    # exception if an invalid combination of values is passed in.
    def initialize(size: DEFAULT_SIZE, minimum: MIN_VALUE, maximum: MAX_VALUE, default: MIN_VALUE)
      size, min, max, default = [size, minimum, maximum, default].map(&:to_i)
      raise ArgumentError.new("invalid memory size") unless size > 0
      raise ArgumentError.new("invalid minimum memory value") unless min <= max
      raise ArgumentError.new("invalid default memory value") unless (min..max).include?(default)
      @value_range = (min..max)
      @cells = Array.new(size, default)
    end

    # Fetch the value stored at a particular memory cell.
    def read(index)
      @cells.fetch(index)
    end

    # Replace the value stored in a particular memory cell.
    def write(index, value)
      raise ArgumentError.new("Invalid value for cell") unless @value_range.include?(value)
      @cells[index] = value
    end

  end

end
