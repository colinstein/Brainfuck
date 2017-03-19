require "forwardable"

module Brainfuck

  class Program
    extend BoundsChecker
    extend Forwardable

    INSTRUCTIONS = /[\<\>\+\-\[\]\,\.]/ # all 8 valid brainfuck instructions

    attr_reader :source

    def_delegators :instructions, :size

    check_bounds :instruction, proc: ->(i) { (0..size).include? i }

    def self.from_file(filename)
      source = File.read(filename)
      new(source)
    rescue Errno::ENOENT
      raise ArgumentError.new("no such file")
    end

    def self.from_string(source)
      new(source)
    end

    def initialize(source)
      @source = source.to_s
    end

    def instruction(index)
      instructions.fetch(index)
    end

    def valid?
      validate
    rescue StandardError => e
      raise e unless ["empty program", "unmatched jumps"].include?(e.message)
      false
    end

    def instructions
      @instructions ||= source.scan(INSTRUCTIONS)
    end

  private

    def validate
      raise StandardError.new("empty program") if instructions.empty?
      raise StandardError.new("unmatched jumps") if unmatched_jumps?
      true
    end

    def unmatched_jumps?
      jumps = instructions.join.scan(/[\[\]]/).join # matches any jump char
      while(jumps =~ /\[\]/) do jumps.gsub!("[]","") end #matches 'paired' jumps
      !jumps.empty?
    end

  end

end
