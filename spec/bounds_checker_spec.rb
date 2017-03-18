require "spec_helper"

describe Brainfuck::BoundsChecker do
  subject { Class.new.extend(Brainfuck::BoundsChecker) }

  describe "#check_bounds" do
    it "has a check_bounds method" do
      expect(subject).to respond_to(:check_bounds)
    end
    it "wraps a methods" do
      expect(subject.check_bounds(:foo, :bar, proc: ->{true})).to eq(%i(foo bar))
    end
    it "raises exception without hash containing 'proc' key" do
      expect{ subject.check_bounds(:foo, bar: false) }.to raise_exception(ArgumentError)
    end
    it "raises exception if proc: isn't callable" do
      expect{ subject.check_bounds(:foo, proc: true) }.to raise_exception(ArgumentError)
    end

    context "wrapped method calls" do
      subject do
        Class.new do
          extend(Brainfuck::BoundsChecker)
          check_bounds(:foo, proc: ->i{ (1..10).include? i })
          define_method(:foo, ->i{ i**2 })
        end.new
      end
      it "lets properly bounded methods be call" do
        expect(subject.foo(5)).to eq(25)
      end
      it "wrapped function fails if first argument is too big" do
        expect{ subject.foo(11) }.to raise_exception(ArgumentError)
      end
      it "wrapped function fails if first argument is too small" do
        expect{ subject.foo(-1) }.to raise_exception(ArgumentError)
      end
    end
  end

end
