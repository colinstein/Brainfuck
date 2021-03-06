# BrainFuck Interpreter [![CircleCI](https://circleci.com/gh/colinstein/Brainfuck/tree/master.svg?style=shield)](https://circleci.com/gh/colinstein/Brainfuck/tree/master) [![codecov](https://codecov.io/gh/colinstein/Brainfuck/branch/master/graph/badge.svg)](https://codecov.io/gh/colinstein/Brainfuck)
BrainFuck is an esoteric programming language, this is a Ruby interpreter for
that language.

## Getting Started
### Installation
If you are using bundler then add the following to your application's `Gemfile`:

        gem "brainfuck"

Then run `bundle install`. Otherwise, you can install this by running:

        gem install brainfuck

### Use as a Binary
This runs a single BrainFuck file specified as a command-line parameter. Can
also be used to interpret a string containing brainfuck source. Standard in and
out are passed to the interpreter.

  * `brainfuck hello_world.bf`: runs the "hello_world.bf" brainfuck program
  * `brainfuck -s '++--'`: interpret the program `++--`.
  * `brainfuck -v`: display version information.
  * `brainfuck -h`: display help.

### Use as a Library
  1. Add brainfuck to your Gemfile
  2. Bundle install
  3. Add the following code:
  ```ruby
  require "brainfuck"
  bfi = Brainfuck::Interpreter.new(file: "somefile.bf")
  bfi.run
  ```
In this example `somefile.bf` would be a file containing a valid BrainFuck
program. Alternatively, you can interpret seom arbitrary string of Brainfuck
code by doing the following:
```ruby
require "brainfuck"
bfi = Brainfuck::Interpreter.new(source: "++++++++++.....")
bfi.run
```
You may want to explore `Brainfuck::Machine.new` class to manually build an
interpter with specific input/output or custom memory layouts/behaviour.

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

### Running Tests
  1. `bundle install`
  2. `rspec`

#### Integration Tests
Integration tests consist of loading the full source of applications from a file
on disk, running them, and ensuring that the output is as expected (appropriate
values in memory, written to stdout or read from stdin).

**Integration tests are run by default** however you may run them explicitly and
in isolation with:
```
rspec --tag integration
```

The integration tests consist of example programs gathered from around the web
but they appear to be under a Creative Commons license:

  * [primes_count.bf](http://esoteric.sange.fi/brainfuck/bf-source/prog/)
  * [add_values.bf, hello_world.bf, and math_to_seven.bf](https://en.wikipedia.org/wiki/Brainfuck)

Alternatively, you can run the specs with the command line interpeter:
```
brainfuck spec/integration/src/primes_count.bf
```

### Contributing
Bug reports and pull requests are welcome on
[GitHub](https://github.com/colinstein/brainfuck).


## About BrainFuck
[The BrainFuck description](http://www.muppetlabs.com/~breadbox/bf/) comes from
muppet labs, however the key points are listed here:

  * `>` Increment the pointer.
  * `<` Decrement the pointer.
  * `+` Increment the byte at the pointer.
  * `-` Decrement the byte at the pointer.
  * `.` Output the byte at the pointer.
  * `,` Input a byte and store it in the byte at the pointer.
  * `[` Jump forward past the matching ] if the byte at the pointer is zero.
  * `]` Jump backward to the matching [ unless the byte at the pointer is zero.

All other characters are treated as comments and ignored. Input is read from
standard in, and written to standard out however the usual UNIX redirection
tricks can be used to change that. This interpreter follows a few common
common patterns that are not part of the specification but are still common to
many implementations.

  1. There are 30,000 memory cells.
  2. When the data or instruction pointer is incremented or decremented past
     the "end" of the data or program then it wraps around.
  3. The maximum value of a memory cell is 255. If a cell holding 255 or 0 is
      incremented or decremented respectively, then it wraps around.
  4. All "non-brainfuck" characters are stripped before execution. That
     means that only `><+-.,[]` are used. All other characters are ignored.

## License
This code is relesed under the MIT license.
The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
