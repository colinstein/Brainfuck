require "forwardable"

module Brainfuck

  class Memory
    extend BoundsChecker
    extend Forwardable

    MIN_VALUE = 0
    MAX_VALUE = 255
    DEFAULT_SIZE = 30_000

    def_delegator :@value_range, :min, :minimum_value
    def_delegator :@value_range, :max, :maximum_value
    def_delegators :@cells, :size, :[]

    check_bounds :[], :[]=, proc: ->(i) { (0..size).include? i }

    def initialize(size: DEFAULT_SIZE, minimum: MIN_VALUE, maximum: MAX_VALUE, default: MIN_VALUE)
      size, min, max, default = [size, minimum, maximum, default].map(&:to_i)
      raise ArgumentError.new("invalid memory size") unless size > 0
      raise ArgumentError.new("invalid minimum memory value") unless min <= max
      raise ArgumentError.new("invalid default memory value") unless (min..max).include?(default)
      @value_range = (min..max)
      @cells = Array.new(size, default)
    end

    def []=(index, value)
      raise ArgumentError.new("Invalid value for cell") unless @value_range.include?(value)
      @cells[index] = value
    end

  end

end
