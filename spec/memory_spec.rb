require "spec_helper"

describe Brainfuck::Memory do
  let(:minimum) { 0 }
  let(:maximum) { 5 }
  let(:default) { 1 }
  let(:size) { 3 }

  subject { Brainfuck::Memory.new(size: size, default: default, minimum: minimum, maximum: maximum) }

  describe "#initialize" do
    context "with custom initial values" do
      it "has the values" do
        expect(subject.size).to eq(size)
        expect(subject.maximum_value).to eq(maximum)
        expect(subject.minimum_value).to eq(minimum)
      end
      it "sets initializes all cells to the same value" do
        # NOTE: peeking into the internals is fragile
        expect(subject.instance_variable_get(:@cells).uniq.size).to eq(1)
        expect(subject.instance_variable_get(:@cells).first).to eq(default)
      end
      context "with invalid custom values" do
        it "size >= 0" do
          expect{Brainfuck::Memory.new(size: 0)}.to raise_exception(ArgumentError)
          expect{Brainfuck::Memory.new(size: -1)}.to raise_exception(ArgumentError)
        end
        it "ensures minimum is < maximim" do
          expect{Brainfuck::Memory.new(maximim: maximum, minimum: maximum.next)}.to raise_exception(ArgumentError)
        end
        it "ensures minimum ≤ default ≤ maximim" do
          expect{Brainfuck::Memory.new(maximum: maximum, default: maximum.next)}.to raise_exception(ArgumentError)
          expect{Brainfuck::Memory.new(minimum: minimum, default: minimum-1)}.to raise_exception(ArgumentError)
        end
      end
    end
    context "with default values" do
      subject { Brainfuck::Memory.new }
      it "has the default values" do
        expect(subject.size).to eq(Brainfuck::Memory::DEFAULT_SIZE)
        expect(subject.maximum_value).to eq(Brainfuck::Memory::MAX_VALUE)
        expect(subject.minimum_value).to eq(Brainfuck::Memory::MIN_VALUE)
      end
      it "all cells have the same intial value" do
        expect(subject.instance_variable_get(:@cells).uniq.size).to eq(1)
        expect(subject.instance_variable_get(:@cells).first).to eq(Brainfuck::Memory::MIN_VALUE)
      end
    end
  end

  describe "#size" do
    it "has a size" do
      expect(subject).to respond_to(:size)
    end
    it "retuns the size" do
      expect(subject.size).to eq(size)
    end
  end

  describe "#minimum_value" do
    it "has a minimum value " do
      expect(subject).to respond_to(:minimum_value)
    end
    it "retuns the minimum value" do
      expect(subject.minimum_value).to eq(minimum)
    end
  end

  describe "#maximum_value" do
    it "has a maximum value " do
      expect(subject).to respond_to(:maximum_value)
    end
    it "retuns the maximum value" do
      expect(subject.maximum_value).to eq(maximum)
    end
  end

  describe "#read" do
    it "responds to #read" do
      expect(subject).to respond_to(:read).with(1).argument
    end
    context "with index in range" do
      let(:index) { 1 }
      it "returns the value" do
        expect(subject.read(index)).to eq(default)
      end
    end
    context "with index out of range" do
      let(:small_index) { -1 }
      let(:big_index) { size.next }
      it "raises an exception" do
        expect{ subject.read(big_index) }.to raise_exception(ArgumentError)
        expect{ subject.read(small_index) }.to raise_exception(ArgumentError)
      end
    end
  end

  describe "#write" do
    it "responds to #write" do
      expect(subject).to respond_to(:write).with(2).arguments
    end
    context "with index in range" do
      let(:index) { 0 }
      context "with value in range" do
        it "sets the value" do
          expect(subject.write(index, default)).to eq(default)
          expect(subject.write(index, minimum)).to eq(minimum)
          expect(subject.write(index, maximum)).to eq(maximum)
        end
      end
      context "with value out of range" do
        let(:small_value) { minimum - 1 }
        let(:big_value) { maximum.next }
        it "sets the value" do
            expect{ subject.write(index, small_value) }.to raise_exception{ArgumentError}
            expect{ subject.write(index, big_value) }.to raise_exception{ArgumentError}
        end
      end
    end
    context "with index out of range" do
      let(:small_index) { -1 }
      let(:big_index) { size.next }
      it "raises an exception" do
        expect{ subject.write(big_index, default) }.to raise_exception(ArgumentError)
        expect{ subject.write(small_index, default) }.to raise_exception(ArgumentError)
      end
    end
  end

end
