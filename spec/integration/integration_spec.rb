require "spec_helper"

describe Brainfuck, integration: true do
  let(:interpreter) { Brainfuck.interpreter(file: program) }
  subject { interpreter.run }

  describe "add_values" do
    # This is a minimal program that ensures basic parsing works. Our only test
    # insures that it clocks the instruction pointer fully through the program
    # and then halts
    let(:program) { integration_source "add_values.bf" }
    it "runs to the end of the program" do
      expect{ subject }.to change(interpreter, :instruction_pointer).to(6)
    end
  end

  describe "echo" do
    # This minimal program tests that input can be read and then written back
    # out. It can be thought of as the minial test of input/output
    let(:program) { integration_source "echo.bf" }
    it "Reads in a character" do
      expect(STDIN).to receive(:readbyte).and_return(?Z.ord)
      expect(STDOUT).to receive(:write).with(?Z.chr).and_return(1)
      expect(subject).to be_truthy
    end
  end

  describe "math_to_seven" do
    # This program does some simple mathematics to calculate the ASCII value for
    # the character '7' and then sends it to STDOUT. There are also slightly
    # more complex uses of the various operators to perform the aritmetic and
    # some comments to ensure they're properly ignored.
    let(:program) { integration_source "math_to_seven.bf" }
    it "calculates the correct value and outputs a single byte" do
      expect(STDOUT).to receive(:write).with(?7).and_return(1)
      expect{ subject }.to change{interpreter.memory.read(0)}.to(?7.ord)
    end
  end

  describe "hello_world" do
    # This program outputs several bytes to standard out and makes some uses of
    # jumps along with increment/decrement of data pointer and cells to
    # construct a message. The source is well commented too.
    let(:program) { integration_source "hello_world.bf" }
    it "outputs 'Hello World!'" do
      "Hello World!\n".chars do |c|
        expect(STDOUT).to receive(:write).with(c).and_return(1)
      end
      expect(subject).to be_truthy
    end
  end

  describe "primes_count" do
    # This program puts it all together. It displays a prompt asking for some
    # arbitrary digit (up to 255 due to cell vlaue size limitations) and then
    # calculates all primes between 0 and that digit and displays them. This
    # program is well commented and makes use of all the major features of the
    # language that don't depend on 'quirks' like wrapping values on overflow
    # or incrementing pointers past the end of memory. Those features are not
    # defined and so vary between implimentations.
    let(:program) { integration_source "primes_count.bf" }
    it "Displays the primes between 1 and 14" do
      # The output order is a little messed up. We expect to see these bytes but
      # not in this order
      "\nPrimesupto:     2357  ".chars do |c|
        expect(STDOUT).to receive(:write).with(c).and_return(1)
      end
      expect(STDIN).to receive(:readbyte).and_return(55, 10)
      expect(subject).to be_truthy
    end
  end

end
