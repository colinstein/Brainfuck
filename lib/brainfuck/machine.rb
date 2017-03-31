module Brainfuck
  # The main Brainfuck interpreter/virtual machine.
  # Example:
  #
  #   require "brainfuck"
  #
  #   prog = Brainfuck::Program.from_string("++++++++++.")
  #   bf = Brainfuck::Machine.new(program: program)
  #   bf.run
  #
  # You can optionally supply your own Memory, Input, Output so long as they
  # implement the appropriate read/write interface. See the respective classes
  # for details.
  class Machine

    # Distance to move the instruction pointer when moving forward 1 instruction
    INSTRUCTION_POINTER_FORWARD = 1

    # Dinstance to move instruction pointer when moving backward 1 instruction
    INSTRUCTION_POINTER_BACKWARD = -INSTRUCTION_POINTER_FORWARD

    # Distance to move the data pointer when moving forward 1 'value'
    DATA_POINTER_FORWARD = 1

    # Distance to move data pointer when moving backward 1 'value'
    DATA_POINTER_BACKWARD = -DATA_POINTER_FORWARD

    # The mappping of Brainfuck instructions to interperter methods. This
    # interpreter does not work by parsing the source and generating an AST,
    # instead, each instruction is read, decoded, and dispatched in a single
    # cycle of the main run loop sort of like how a CPU works.
    INSTRUCTION_MAPPING = {
      ?> => :increment_data_pointer,
      ?< => :decrement_data_pointer,
      ?+ => :increment_data_at_data_pointer,
      ?- => :decrement_data_at_data_pointer,
      ?, => :read_byte_from_input_to_data_pointer_cell,
      ?. => :write_byte_from_data_pointer_cell_to_output,
      ?[ => :jump_forward_on_zero_at_data_pointer,
      ?] => :jump_backward_on_non_zero_at_data_pointer,
    }

    attr_reader :data_pointer         # location in 'memory' where data is read/written
    attr_reader :instruction_pointer  # location of next instruction to dispatch
    attr_reader :program              # the list of instructions to run
    attr_reader :memory               # the working data set of the runnign program

    # Create a new Brainfuck virtual machine.
    def initialize(memory: Memory.new, input: Input.new, output: Output.new, program:)
      @instruction_pointer = 0
      @data_pointer = 0
      @program = program
      @memory = memory
      @input = input
      @output = output
    end

    # Start the interpreter. This will continue running until an exception is
    # raised (e.g. because of a faulty IO), or the compram halts. Attemptint to
    # run an invalid program 
    # Returns true if the program runs to completion.
    def run
      raise StandardError.new("invalid program cannot be run") unless program.valid?
      !(run_loop until at_last_instruction?)
    end

    private

    # The standard 'fetch/decode/dispatch/retire' cycle. This method will step
    # the virtual machine through one function.
    def run_loop
      instruction = fetch
      decoded_instruction = decode(instruction)
      dispatch(decoded_instruction)
      increment_instruction_pointer
    end

    # When the interpreter has dispatched the final instruction in the program
    def at_last_instruction?
      instruction_pointer >= program.size
    end

    # load the current instruction from the program
    def fetch
      program.read(instruction_pointer)
    end

    # Step the instruction pointer forward to the next instruction
    def increment_instruction_pointer
      @instruction_pointer += INSTRUCTION_POINTER_FORWARD
    end

    # Step the instruction pointer forward to the previous instruction
    def decrement_instruction_pointer
      @instruction_pointer += INSTRUCTION_POINTER_BACKWARD
    end

    # converts a program instruction into an action that can be run by the virtual machine
    def decode(instruction)
      INSTRUCTION_MAPPING.fetch(instruction.to_s, nil)
    end

    # Run a particular instruction - not any different from calling Machine#foo
    # but does provide a place to set special flags as a result of faults.
    def dispatch(instruction)
      raise ArgumentError.new("cannot execute nil") if instruction.nil?
      raise ArgumentError.new("cannot execute invalid instruction") unless respond_to?(instruction, true)
      send(instruction)
    end

    # Step the data pointer forward to the next memory address
    def increment_data_pointer
      value = @data_pointer + DATA_POINTER_FORWARD
      value = 0 unless (0...memory.size).include?(value)
      @data_pointer = value
    end

    # Step the data pointer backward to the previous memory address
    def decrement_data_pointer
      value = @data_pointer + DATA_POINTER_BACKWARD
      value = (memory.size - 1) unless (0...data_pointer).include?(value)
      @data_pointer = value
    end

    # Increase the value at the location in memory pointed to by the data
    # pointer to the next value. If the value overflows then the it will wrap
    # around to the minimum value.
    def increment_data_at_data_pointer
      value = memory.read(data_pointer).next
      value = memory.minimum_value unless (memory.minimum_value..memory.maximum_value).include?(value)
      memory.write(data_pointer, value)
    end

    # Decrease the value at the location in memory pointed to by the data
    # pointer to the previous value. If the value overflows then the it will
    # wrap around to the maximum value.
    def decrement_data_at_data_pointer
      value = memory.read(data_pointer).pred
      value = memory.maximum_value unless (memory.minimum_value..memory.maximum_value).include?(value)
      memory.write(data_pointer, value)
    end

    # Reads a single byte from the input and replaces the value in the memory at
    # the location pointed at by the data pointer. Input is a 'stream' interface
    # rather than an addressable source. The 'byte' returned by memory is going
    # to be able to fit in a single memory cell.
    def read_byte_from_input_to_data_pointer_cell
      value = @input.read until (memory.minimum_value..memory.maximum_value).include?(value)
      memory.write(data_pointer, value)
    end

    # Writes a byte of data from memory to the output. The output is a stream of
    # data rather than an addressable sink. The 'byte' of memory is written as
    # is, so the character 'a' is written as it's ordinal value to the output.
    def write_byte_from_data_pointer_cell_to_output
      @output.write(memory.read(data_pointer))
    end

    # If the data pointer is zero then this instruction will move the
    # instruction pointer forwards to through the source to the "]" character
    # which matches the "[" that the instruction pointer currently points to.
    # The Brainfuck language definition says the "[" goes to the instruction
    # 'after' the matching "]", instead of stopping on it: the next 'increment'
    # that happens in the run loop will make sure that the interpreter has the
    # correct behaviour. If you dispatch this instruction manually then be sure
    # to add one to the jump target.
    def jump_forward_on_zero_at_data_pointer
      return unless memory.read(data_pointer).zero?
      @instruction_pointer += calculate_jump_distance(INSTRUCTION_POINTER_FORWARD)
    end

    # If the data pointer is not zero then this instruction will move the
    # instruction pointer backards to through the source to the "[" character
    # which matches the "]" that the instruction pointer currently points to.
    # The Brainfuck language definition says the "]" goes to the instruction
    # 'after' the matching "[", instead of stopping on it: the next 'increment'
    # that happens in the run loop will make sure that the interpreter has the
    # correct behaviour. If you dispatch this instruction manually then be sure
    # to add one to the jump target.
    def jump_backward_on_non_zero_at_data_pointer
      return if memory.read(data_pointer).zero?
      @instruction_pointer += calculate_jump_distance(INSTRUCTION_POINTER_BACKWARD)
    end

    # Jumping moves the instruction pointer zero or more places. This method is
    # responsible for calculating that distance. There is an assumption that the
    # jump will be calculated from the current instruction pointer position.
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
