module Brainfuck

  class Machine

    FORWARD = 1
    BACKWARD = -FORWARD
    INSTRUCTION_MAPPING = {
      ?> => :increment_data_pointer,
      ?< => :decrement_data_pointer,
      ?+ => :increment_data_at_data_pointer,
      ?- => :decrement_data_at_data_pointer,
      ?, => :read_byte_from_stdin_to_data_pointer_cell,
      ?. => :write_byte_from_data_pointer_cell_to_stdout,
      ?[ => :jump_forward_on_zero_at_data_pointer,
      ?] => :jump_backward_on_non_zero_at_data_pointer,
    }

    attr_reader :data_pointer, :instruction_pointer, :program, :memory

    def initialize(memory: Memory.new, input: Input.new, output: Output.new, program:)
      @instruction_pointer = 0
      @data_pointer = 0
      @program = program
      @memory = memory
      @input = input
      @output = output
    end

    def run
      raise StandardError.new("invalid program cannot be run") unless program.valid?
      !(run_loop until at_last_instruction?)
    end

    private

    def run_loop
      instruction = fetch
      decoded_instruction = decode(instruction)
      dispatch(decoded_instruction)
      increment_instruction_pointer
    end

    def at_last_instruction?
      instruction_pointer >= program.size
    end

    def fetch
      program.read(instruction_pointer)
    end

    def increment_instruction_pointer
      @instruction_pointer += 1
    end

    def decrement_instruction_pointer
      @instruction_pointer -= 1
    end

    def decode(instruction)
      INSTRUCTION_MAPPING.fetch(instruction.to_s, nil)
    end

    def dispatch(instruction)
      raise ArgumentError.new("cannot execute nil") if instruction.nil?
      raise ArgumentError.new("cannot execute invalid instruction") unless respond_to?(instruction, true)
      send(instruction)
    end

    def increment_data_pointer
      value = @data_pointer + 1
      value = 0 unless (0...memory.size).include?(value)
      @data_pointer = value
    end

    def decrement_data_pointer
      value = @data_pointer - 1
      value = (memory.size - 1) unless (0...data_pointer).include?(value)
      @data_pointer = value
    end

    def increment_data_at_data_pointer
      value = memory.read(data_pointer) + 1
      value = memory.minimum_value unless (memory.minimum_value..memory.maximum_value).include?(value)
      memory.write(data_pointer, value)
    end

    def decrement_data_at_data_pointer
      value = memory.read(data_pointer) - 1
      value = memory.maximum_value unless (memory.minimum_value..memory.maximum_value).include?(value)
      memory.write(data_pointer, value)
    end

    def read_byte_from_stdin_to_data_pointer_cell
      value = @input.read until (memory.minimum_value..memory.maximum_value).include?(value)
      memory.write(data_pointer, value)
    end

    def write_byte_from_data_pointer_cell_to_stdout
      @output.write(memory.read(data_pointer))
    end

    def jump_forward_on_zero_at_data_pointer
      return unless memory.read(data_pointer).zero?
      @instruction_pointer += calculate_jump_distance(FORWARD)
    end

    def jump_backward_on_non_zero_at_data_pointer
      return if memory.read(data_pointer).zero?
      @instruction_pointer += calculate_jump_distance(BACKWARD)
    end

    def calculate_jump_distance(direction)
      distance, jumps = 0, 0
      loop do
        instruction = program.read(@instruction_pointer + distance)
        jumps += { ?[ => direction, ?] => -direction }.fetch(instruction, 0)
        return distance if jumps.zero?
        distance += direction
      end
    end

  end

end
