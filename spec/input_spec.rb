require "spec_helper"

describe Brainfuck::Input do
  subject { Brainfuck::Input.new }

  describe "#read" do
    it "has a read method" do
      expect(subject).to respond_to(:read)
    end
    it "returns one byte at a time from standard in" do
      expect(STDIN).to receive(:readbyte).and_return(65, 90, 10)
      expect(subject.read).to eq(65)
      expect(subject.read).to eq(90)
      expect(subject.read).to eq(10)
    end
  end

end
