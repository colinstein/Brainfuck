require "spec_helper"

describe Brainfuck::Program do
  let(:filename) { "example.bf" }
  let(:instructions) { %w(+ - +) }
  let(:source) { instructions.join }
  subject { Brainfuck::Program.new(source) }

  context "class methods" do
    subject { Brainfuck::Program }

    describe ".from_file" do
      it "has a from_file method" do
        expect(subject).to respond_to(:from_file)
      end
      context "with a valid path" do
        it "reads the provided file" do
          # NOTE: mocking the internals is fragile
          expect(File).to receive(:read).with(filename) { source }
          expect(subject.from_file(filename)).to be_instance_of(Brainfuck::Program)
        end
      end
      context "with an invalid path" do
        it "raises an exception" do
          allow(File).to receive(:read).with(filename) { raise(Errno::ENOENT) }
          expect{ subject.from_file(filename) }.to raise_exception(ArgumentError)
        end
      end
    end

    describe ".from_string" do
      it "has a from_string method" do
        expect(subject).to respond_to(:from_string)
      end
      it "instantiates with the contents of the string" do
        expect(subject.from_string(source)).to be_instance_of(Brainfuck::Program)
      end
    end
  end

  describe "#initialize" do
    it "has an initializer" do
      expect(Brainfuck::Program).to respond_to(:new).with(1).argument
    end
    it "stores the source" do
      expect(subject.instance_variable_get(:@source)).to eq(source)
    end
  end

  describe "#source" do
    it "has a source method" do
      expect(subject).to respond_to(:source)
    end
    it "returns the source" do
      expect(subject.source).to eq(source)
    end
  end

  describe "#instructions" do
    it "has a instrunctions method" do
      expect(subject).to respond_to(:instructions)
    end
    context "with only instructions in the source" do
      it "returns only executable symbols" do
        expect(subject.instructions).to eq(instructions)
      end
    end
    context "with 'comments' in the source" do
      let(:source) { (instructions + [" # This is a comment"]).join }
      it "returns only executable symbols" do
        expect(subject.instructions).to eq(instructions)
      end
    end
  end

  describe "#valid?" do
    it "has a valid? method" do
      expect(subject).to respond_to(:valid?)
    end
    context "when source is valid" do
      it "returns true" do
        expect(subject.valid?).to be(true)
      end
    end
    context "when source has matched jumps" do
      let(:instructions) { %w([++][--]) }
      it "returns true" do
        expect(subject.valid?).to be(true)
      end
    end
    context "when source has nested jumps" do
      let(:instructions) { %w([++[--[]]][]) }
      it "returns true" do
        expect(subject.valid?).to be(true)
      end
    end
    context "when source is too empty" do
      let(:instructions) { [] }
      it "returns false" do
        expect(subject.valid?).to be(false)
      end
    end
    context "when source is has missing close jumps" do
      let(:instructions) { %w([ +) }
      it "returns false" do
        expect(subject.valid?).to be(false)
      end
    end
    context "when source is has missing open jumps" do
      let(:instructions) { %w(] +) }
      it "returns false" do
        expect(subject.valid?).to be(false)
      end
    end
    context "when source is has missing nested jumps" do
      let(:instructions) { %w([[][[]]) }
      it "returns false" do
        expect(subject.valid?).to be(false)
      end
    end
  end

  describe "#read" do
    it "has a read method" do
      expect(subject).to respond_to(:read).with(1).argument
    end
    it "returns an read" do
      expect(subject.read(0)).to eq("+")
      expect(subject.read(1)).to eq("-")
      expect(subject.read(2)).to eq("+")
    end
    it "raises an exception if index too small" do
      expect{ subject.read(-1) }.to raise_exception(ArgumentError)
    end
    it "raises an exception if index too big" do
      expect{ subject.read(instructions.length + 1) }.to raise_exception(ArgumentError)
    end
  end

end
