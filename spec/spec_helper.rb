require "bundler/setup"
require "brainfuck"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def mock_program_string(program, instructions)
    instructions.chars.each.with_index do |instruction, index|
      allow(program).to receive(:[]).with(index).and_return(instruction)
    end
  end

end
