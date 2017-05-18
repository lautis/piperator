# Piperator

Stream processing using Ruby Enumerators made easy. Build composable pipelines
to allows data to flow though them with possibility to add initialisation and
clean up code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'piperator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install piperator

## Usage

```ruby
append_end = proc do |enumerator|
  Enumerator.new do |yielder|
    enumerator.lazy.each { |item| yielder << item }
    yielder << 'end'
  end
end

prepend_start = proc do |enumerator|
  Enumerator.new do |yielder|
    yielder << 'start'
    enumerator.lazy.each { |item| yielder << item }
  end
end

double = ->(enumerator) { enumerator.lazy.map { |i| i * 2 } }

prepend_append = Piperator::Pipeline.new([prepend_start, append_end])
Piperator::Pipeline.pipe(double).pipe(prepend_append).call([1, 2, 3]).to_a
# => ['start', 2, 4, 6, 'end']
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lautis/piperator.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
