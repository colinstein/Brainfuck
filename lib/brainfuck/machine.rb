module Brainfuck

  class Machine

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
      program.instruction(instruction_pointer)
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

    def noop; end

    def increment_data_pointer
      if (0...memory.size).include?(data_pointer + 1)
        @data_pointer += 1
      else
        @data_pointer = 0
      end
    end

    def decrement_data_pointer
      if (0...data_pointer).include?(data_pointer - 1)
        @data_pointer -= 1
      else
        @data_pointer = (memory.size - 1)
      end
    end

    def increment_data_at_data_pointer
      if (memory.minimum_value...memory.maximum_value).include?(memory.read(data_pointer))
        new_value = memory.read(data_pointer) + 1
        memory.write(data_pointer,new_value)
      else
        memory.write(data_pointer, memory.minimum_value)
      end
    end

    def decrement_data_at_data_pointer
      if (memory.minimum_value.next...memory.maximum_value).include?(memory.read(data_pointer))
        new_value = memory.read(data_pointer) - 1
        memory.write(data_pointer, new_value)
      else
        memory.write(data_pointer, memory.maximum_value)
      end
    end

    def read_byte_from_stdin_to_data_pointer_cell
      value = nil
      until (memory.minimum_value..memory.maximum_value).include?(value)
        value = @input.read
      end
      memory.write(data_pointer, value)
    end

    def write_byte_from_data_pointer_cell_to_stdout
      @output.write(memory.read(data_pointer))
    end

    def jump_forward_on_zero_at_data_pointer
      return unless memory.read(data_pointer).zero?
      jump_forward_markers_seen = 1
      until jump_forward_markers_seen.zero? do
        increment_instruction_pointer
        case fetch
          when ?[; jump_forward_markers_seen += 1
          when ?]; jump_forward_markers_seen -= 1
        end
      end
    end

    def jump_backward_on_non_zero_at_data_pointer
      return if memory.read(data_pointer).zero?
      jump_backward_markers_seen = 1
      until jump_backward_markers_seen.zero? do
        decrement_instruction_pointer
        case fetch
          when ?[; jump_backward_markers_seen -= 1
          when ?]; jump_backward_markers_seen += 1
        end
      end
    end

  end

end
