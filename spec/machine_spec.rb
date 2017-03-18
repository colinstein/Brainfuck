require "spec_helper"

describe Brainfuck::Machine do
  let(:memory) { instance_double("Memory") }
  let(:program) { instance_double("Program") }
  let(:input) { instance_double("Input") }
  let(:output) { instance_double("output") }
  let(:machine) {  Brainfuck::Machine.new(memory: memory, program: program, input: input, output: output) }
  subject { machine }

  describe "class methods" do
    subject { Brainfuck::Machine }
  end

  describe "#run" do
    it "runs a valid program" do
      allow(program).to receive(:valid?) { true }
      allow(program).to receive(:[]).and_return(?+, nil)
      allow(program).to receive(:size).and_return(1)
      allow(memory).to receive(:minimum_value).and_return(0)
      allow(memory).to receive(:maximum_value).and_return(10)
      allow(memory).to receive(:[]).with(0).and_return(0)
      allow(memory).to receive(:[]=).with(0, 1).and_return(1)
      expect(subject.run).to eq(true)
    end
    context "with an invalid program" do
      it "raises an exception" do
        allow(program).to receive(:valid?) { false }
        expect{ subject.run }.to raise_exception(StandardError)
      end
    end
  end

  describe "private methods" do
    # NOTE: we're peaking into the internals which is fragile, but it makes
    # more sense to test this explicitly on its own.
    describe "#fetch" do
      let(:instruction) { ?+ }
      it "fetches an instruction" do
        allow(program).to receive(:[]).with(0).and_return(instruction)
        expect(subject.send(:fetch)).to eq(instruction)
      end
    end

    describe "#decode" do
      context "with valid instructions" do
        it "translates chars to symbols" do
          expect(subject.send(:decode, ?>)).to eq(:increment_data_pointer)
          expect(subject.send(:decode, ?<)).to eq(:decrement_data_pointer)
          expect(subject.send(:decode, ?+)).to eq(:increment_data_at_data_pointer)
          expect(subject.send(:decode, ?-)).to eq(:decrement_data_at_data_pointer)
          expect(subject.send(:decode, ?[)).to eq(:jump_forward_on_zero_at_data_pointer)
          expect(subject.send(:decode, ?])).to eq(:jump_backward_on_non_zero_at_data_pointer)
          expect(subject.send(:decode, ?,)).to eq(:read_byte_from_stdin_to_data_pointer_cell)
          expect(subject.send(:decode, ?.)).to eq(:write_byte_from_data_pointer_cell_to_stdout)
        end
      end
      context "with invalid instructions" do
        it "translates to nil" do
          expect(subject.send(:decode, ?x)).to be_nil
          expect(subject.send(:decode, nil)).to be_nil
        end
      end
    end

    describe "instruction implimentations" do
      describe "#increment_data_pointer '>'" do
        subject { machine.send(:dispatch, :increment_data_pointer) }
        it "increments the data pointer" do
          allow(memory).to receive(:size).and_return(10)
          machine.instance_variable_set(:@data_pointer, 5)
          expect{ subject }.to change(machine, :data_pointer).by(1)
        end
        context "at the end of the memory" do
          it "wraps to the begining" do
            allow(memory).to receive(:size).and_return(10)
            machine.instance_variable_set(:@data_pointer, 9)
            expect{ subject }.to change(machine, :data_pointer).to(0)
          end
        end
      end

      describe "#decrement_data_pointer '<'" do
        subject { machine.send(:dispatch, :decrement_data_pointer) }
        it "decrements the data pointer" do
          machine.instance_variable_set(:@data_pointer, 5)
          allow(memory).to receive(:size).and_return(10)
          expect{ subject }.to change(machine, :data_pointer).by(-1)
        end
        context "at the start of the memory" do
          it "wraps to the end" do
            machine.instance_variable_set(:@data_pointer, 0)
            allow(memory).to receive(:size).and_return(10)
            expect{ subject }.to change(machine, :data_pointer).to(9)
          end
        end
      end

      describe "#increment_data_at_data_pointer '+'" do
        subject { machine.send(:dispatch, :increment_data_at_data_pointer) }
        it "increments the value" do
          machine.instance_variable_set(:@data_pointer, 0)
          allow(memory).to receive(:minimum_value).and_return(0)
          allow(memory).to receive(:maximum_value).and_return(10)
          allow(memory).to receive(:[]).with(0).and_return(5)
          expect(memory).to receive(:[]=).with(0, 6).and_return(6)
          expect(subject).to eq(6)
        end
        context "when the value is at the maximimum" do
          it "wraps to the minimum" do
            machine.instance_variable_set(:@data_pointer, 0)
            allow(memory).to receive(:minimum_value).and_return(0)
            allow(memory).to receive(:maximum_value).and_return(10)
            allow(memory).to receive(:[]).with(0).and_return(10)
            expect(memory).to receive(:[]=).with(0, 0).and_return(0)
            expect(subject).to eq(0)
          end
        end
      end

      describe "#decrement_data_at_data_pointer '-'" do
        subject { machine.send(:dispatch, :decrement_data_at_data_pointer) }
        it "decrements the value" do
          machine.instance_variable_set(:@data_pointer, 0)
          allow(memory).to receive(:minimum_value).and_return(0)
          allow(memory).to receive(:maximum_value).and_return(10)
          allow(memory).to receive(:[]).with(0).and_return(5)
          expect(memory).to receive(:[]=).with(0, 4).and_return(4)
          expect(subject).to eq(4)
        end
        context "when the value is at the minimum" do
          it "wraps to the maximum" do
            allow(memory).to receive(:minimum_value).and_return(0)
            allow(memory).to receive(:maximum_value).and_return(10)
            allow(memory).to receive(:[]).with(0).and_return(0)
            expect(memory).to receive(:[]=).with(0, 10).and_return(10)
            expect(subject).to eq(10)
          end
        end
      end

      describe "#write_byte_from_data_pointer_cell_to_stdout '.'" do
        subject { machine.send(:dispatch, :write_byte_from_data_pointer_cell_to_stdout) }
        it "writes a byte" do
          allow(memory).to receive(:[]).with(0).and_return(120)
          expect(output).to receive(:write).with(120).and_return(1)
          expect(subject).to eq(1)
        end
      end

      describe "#read_byte_from_stdin_to_data_pointer_cell ','" do
        subject { machine.send(:dispatch, :read_byte_from_stdin_to_data_pointer_cell) }
        it "read a byte" do
          machine.instance_variable_set(:@data_pointer, 0)
          allow(memory).to receive(:minimum_value).and_return(0)
          allow(memory).to receive(:maximum_value).and_return(255)
          allow(input).to receive(:read).and_return(120)
          expect(memory).to receive(:[]=).with(0, 120).and_return(120)
          expect(subject).to eq(120)
        end
        context "when the value read is not in the value range" do
          it "it reads until it does fit in the range" do
            machine.instance_variable_set(:@data_pointer, 0)
            allow(memory).to receive(:minimum_value).and_return(10)
            allow(memory).to receive(:maximum_value).and_return(100)
            allow(input).to receive(:read).and_return( 1, 200, 50)
            expect(memory).to receive(:[]=).with(0, 50.ord).and_return(50)
            expect(subject).to eq(50)
          end
        end
      end

      describe "#jump_forward_on_non_zero_at_data_pointer '['" do
        subject { machine.send(:dispatch, :jump_forward_on_zero_at_data_pointer) }
        it "jumps forward to the next ']' instruction" do
          machine.instance_variable_set(:@data_pointer, 0)
          machine.instance_variable_set(:@instruction_pointer, 0)
          allow(memory).to receive(:[]).with(0).and_return(0)
          mock_program_string(program, "[+]")
          expect{ subject }.to change(machine, :instruction_pointer).by(2)
        end
        it "jumps forward to the next *matching* ']' instruction" do
          machine.instance_variable_set(:@data_pointer, 0)
          machine.instance_variable_set(:@instruction_pointer, 0)
          allow(memory).to receive(:[]).with(0).and_return(0)
          mock_program_string(program, "[+[[++]--][>><<]--++]>>++")
          expect{ subject }.to change(machine, :instruction_pointer).by(20)
        end
        context "when data pointer doesn't point to cell containing zero" do
          it "doesn't jump" do
            machine.instance_variable_set(:@data_pointer, 0)
            machine.instance_variable_set(:@instruction_pointer, 0)
            allow(memory).to receive(:[]).with(0).and_return(1)
            expect{ subject }.not_to change(machine, :instruction_pointer)
          end
        end
      end

      describe "#jump_backward_on_nonzero_at_data_pointer ']'" do
        subject { machine.send(:dispatch, :jump_backward_on_non_zero_at_data_pointer) }
        it "jumps backward to the last '['" do
          machine.instance_variable_set(:@data_pointer, 0)
          machine.instance_variable_set(:@instruction_pointer, 2)
          allow(memory).to receive(:[]).with(0).and_return(1)
          mock_program_string(program, "[+]")
          expect{ subject }.to change(machine, :instruction_pointer).by(-2)
        end
        it "jumps backward to the last *matching* '[' instruction" do
          machine.instance_variable_set(:@data_pointer, 1)
          machine.instance_variable_set(:@instruction_pointer, 20)
          allow(memory).to receive(:[]).with(1).and_return(1)
          mock_program_string(program, "[+[[++]--][>><<]--++]>>++")
          expect{ subject }.to change(machine, :instruction_pointer).by(-20)
        end
        context "when data pointer points to a cell that is zero" do
          it "doesn't jump" do
            machine.instance_variable_set(:@data_pointer, 0)
            machine.instance_variable_set(:@instruction_pointer, 1)
            allow(memory).to receive(:[]).with(0).and_return(0)
            expect{ subject }.not_to change(machine, :instruction_pointer)
          end
        end
      end
    end
  end

end
