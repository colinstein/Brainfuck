require "forwardable"

module Brainfuck
  # Models the application code for the virtual machine / interpreter.
  # Example:
  #
  #   require "program"
  #
  #   program = Brainfuck::Program.from_file("foo.bf")
  #   bf = Brainfuck::Machine.new(program: program)
  #   bf.run
  #
  #   program = Brainfuck::Program.from_string("++++++++++.")
  #   bf = Brainfuck::Machine.new(program: program)
  #   bf.run
  #
  # You can check to see if hte program is valid and able to be run by using the
  # .valid? method. Note that the program will store the full source but it is
  # expected that you itterate over the 'instructions' using the 'read' method.
  # as this will not contain superflous bytes like comments.
  class Program
    extend BoundsChecker                 # Ensure that memory access is 'sane'
    extend Forwardable                   # Outsource parts of the interface.

    INSTRUCTIONS = /[\<\>\+\-\[\]\,\.]/  # All 8 valid brainfuck instructions

    attr_reader :source                  # The 'unprocessed' program source

    def_delegators :instructions, :size  # Number of executable instructions

    # Ensure that you cannot read outside of the defined instructions
    check_bounds :read, proc: ->(i) { (0..size).include? i }

    # Create a new program by parsing the contents of a file. The filename
    # should contain a valid brianfuck program however anything can be loaded.
    # An exception will be raised if the file is inaccessible but not if it is
    # invalid.
    def self.from_file(filename)
      source = File.read(filename)
      new(source)
    rescue Errno::ENOENT
      raise ArgumentError.new("no such file")
    end

    # Create a new program by parsing a string containing a valid brainfuck
    # program. An exception will not be thrown if the source is invalid.
    def self.from_string(source)
      new(source)
    end

    # The initialize method can be used directly but it is more-correct
    # to use either one of hte class methods: `.from_file` or `.from_string`
    def initialize(source)
      @source = source.to_s
    end

    # Fetch an instruction stored at a particular index in the program. The
    # index is not the same as it's byte in the source as comments are stripped
    # and ignored.
    def read(index)
      instructions.fetch(index)
    end

    # Detect if the program is valid. A program must be at least one instruction
    # and must have all 'jumps' as matched pairs.
    def valid?
      not (instructions.empty? || unmatched_jumps?)
    end

    # The eecutable instructions inside of the source used to initialize the
    # the program. This is source without comments or whitespace.
    def instructions
      @instructions ||= source.scan(INSTRUCTIONS)
    end

  private

    # Detects if there are any "["s without matching "]"s or vice-versa in the
    # instruction sequence. While it is technically possible for the program to
    # run correctly (e.g. if there is an unmatched '[' but the data pointer is
    # never zero) this is considered a fatal error.
    def unmatched_jumps?
      jumps = instructions.join.scan(/[\[\]]/).join  # matches any jump char
      jumps.gsub!("[]","") while(jumps =~ /\[\]/)    # matches 'paired' jumps
      !jumps.empty?
    end

  end

end
