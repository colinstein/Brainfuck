require "spec_helper"

RSpec.describe Brainfuck do
  let(:machine) { class_double("Brainfuck::Machine").as_stubbed_const }
  let(:program) { class_double("Brainfuck::Program").as_stubbed_const }
  let(:program_instance) { instance_double("Brainfuck::Program") }
  let(:machine_instance) { instance_double("Brainfuck::Machine") }

  subject { Brainfuck }

  it "has a version constant" do
    expect(subject::VERSION).not_to be_nil
  end

  describe ".interpreter" do
    it "has an .interpreter method" do
      expect(subject).to respond_to(:interpreter).with_keywords(:source, :file)
    end
    context "when passed source" do
      subject { Brainfuck.interpreter(source: "++--") }
      it "returns a new brainfuck machine with a program from the source" do
        expect(program).to receive(:from_string).with("++--").and_return(program_instance)
        expect(machine).to receive(:new).with(program: program_instance).and_return(machine_instance)
        expect(subject).to eq(machine_instance)
      end
    end
    context "when passed file" do
      subject { Brainfuck.interpreter(file: "foo.bf") }
      it "returns a new brainfuck machine with a program from the file" do
        expect(program).to receive(:from_file).with("foo.bf").and_return(program_instance)
        expect(machine).to receive(:new).with(program: program_instance).and_return(machine_instance)
        expect(subject).to eq(machine_instance)
      end
    end
    context "when passed source and file" do
      subject { Brainfuck.interpreter(source: ?a, file: ?b) }
      it "raises an exception" do
        expect{ subject }.to raise_exception(ArgumentError)
      end
    end
    context "when passed neither source no file" do
      subject { Brainfuck.interpreter }
      it "raises an exception" do
        expect{ subject }.to raise_exception(ArgumentError)
      end
    end
  end

end
