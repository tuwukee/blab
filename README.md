# blab
[![Gem Version](https://badge.fury.io/rb/blab.svg)](https://badge.fury.io/rb/blab)

A debugging tool.

The gem allows to trace local variables and memory usage for Ruby code. \
It's intended for use in a development environment only. \
Blab is inspired by [PySnooper](https://github.com/cool-RR/PySnooper).


## Installation

Put this line in your Gemfile

```ruby
gem "blab", group: :development
```

Then run

```
bundle install
```

## Usage

Use the `blab` decorator in front of a method defenition.

```ruby
require "blab"

class Test
  blab def longest_rep(str)
    max = str.chars.chunk(&:itself).map(&:last).max_by(&:size)
    max ? [max[0], max.size] : ["", 0]
  end
end

Test.new.longest_rep("cbaaabb")

```

The output to STDOUT:

```
Var......... str="cbaaabb"
18:17:26.042 call   test/support/test.rb:46        blab def longest_rep(str)
18:17:26.042 line   test/support/test.rb:47          max = str.chars.chunk(&:itself).map(&:last).max_by(&:size)
Var......... max=["a", "a", "a"]
18:17:26.043 line   test/support/test.rb:48          max ? [max[0], max.size] : ["", 0]
18:17:26.043 return test/support/test.rb:49        end
```

The gem allows to wrap only a piece of code in a block:

```ruby
class Test
  def shuffle(arr)
    for n in 0...arr.size
      targ = n + rand(arr.size - n)
      arr[n], arr[targ] = arr[targ], arr[n] if n != targ
    end
  end

  def pairs(a, b)
    with_blab do
      a << "Insane"
      shuffle(b)
    end
    b.each { |x| shuffle(a); a.each { |y| print y, " ", x, ".\n" } }
  end
end

Test.new.pairs(["Bored", "Curious"], ["cat", "frog"])
```

The output:

```
Var......... a=["Bored", "Curious"]
Var......... b=["cat", "frog"]
18:38:15.188 line   test/support/test.rb:54                   a << "Insane"
18:38:15.188 line   test/support/test.rb:55                   shuffle(b)
Var......... arr=["cat", "frog"]
18:38:15.188 call   test/support/test.rb:45               def shuffle(arr)
18:38:15.189 line   test/support/test.rb:46                 for n in 0...arr.size
Var......... n=0
18:38:15.189 line   test/support/test.rb:47                   targ = n + rand(arr.size - n)
Var......... targ=0
18:38:15.189 line   test/support/test.rb:48                   arr[n], arr[targ] = arr[targ], arr[n] if n != targ
Var......... n=1
18:38:15.189 line   test/support/test.rb:47                   targ = n + rand(arr.size - n)
Var......... targ=1
18:38:15.189 line   test/support/test.rb:48                   arr[n], arr[targ] = arr[targ], arr[n] if n != targ
18:38:15.189 return test/support/test.rb:50               end
```

## Configuration

Output to a file:

```ruby
Blab::Config.log_output = "log/blab.log"
```

Datetime format:

```ruby
Blab::Config.datetime_format = "%H:%M:%S.%L"
```

Custom logger:

```ruby
Blab::Config.logger = MyCustomLogger.new
```

Trace C calls your program makes from Ruby:

```ruby
Blab::Config.trace_c_calls = true
```

Trace only within the original scope. \
It means that the trace will be showed only for the current method and it will skip all external call's traces.

```ruby
Blab::Config.original_scope_only = true
```

Format output. Available config is:

```ruby
output_order = [
  { type: :time, order: 1, width: 12 },
  { type: :event, order: 2, width: 6 },
  { type: :file_lines, order: 3, width: 30 },
  { type: :class_name, order: 4, width: 10 },
  { type: :method_name, order: 5, width: 12 },
  { type: :code_lines, order: 7, width: 120 }
]

Blab::Config.output_order = output_order
```
By default it doesn't show current class name and method name. You can adjust the width, change the order, skip/add the desired output info.

## Contribution

Fork & Pull Request. \
Run the tests via `rake`.

## License

MIT

