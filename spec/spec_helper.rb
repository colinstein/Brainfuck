require "bundler/setup"
require "simplecov"

SimpleCov.start do
  add_filter '/spec/'
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "brainfuck"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Random order ensures there's no inter-test dependencies
  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def mock_program_string(program, instructions)
    instructions.chars.each.with_index do |instruction, index|
      allow(program).to receive(:instruction).with(index).and_return(instruction)
    end
  end

end
