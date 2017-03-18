require "spec_helper"

describe Brainfuck::Output do
  let(:data) { 90 }
  subject { Brainfuck::Output.new }

  describe "#write" do
    it "has a write method" do
      expect(subject).to respond_to(:write).with(1).argument
    end
    it "write one byte (character) to standard out" do
      allow(STDOUT).to receive(:write).with(data.chr)
      expect{ subject.write(data) }.not_to raise_exception
    end
    context "when given a data that cannot be a single byte" do
      it "raises an exception" do
        expect{ subject.write(-1) }.to raise_exception(ArgumentError)
        expect{ subject.write(1024) }.to raise_exception(ArgumentError)
      end
    end
  end

end
