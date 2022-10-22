# PokerTrump

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/poker_trump`. To experiment with that code, run `bin/console` for an interactive prompt.

ポーカーの役判定

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'poker_trump'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install poker_trump

## Usage

```
PokerTrump::Cards.from_string('KdKcKs3h3d') > PokerTrump::Cards.from_string('KdKcKs2h2h')
# => true

['AdKdQdJdTd', 'AdKcQsJhTh', 'AdKcKsKhKc', 'QdKcKsKhKd', 'AdKcKs4h3d', '2d3c4s5h6d'].map { |s| PokerTrump::Cards.from_string(s) }.sort.reverse.map(&:to_s)
# => ["Ad Kd Qd Jd Td", "Ad Kc Ks Kh Kc", "Qd Kc Ks Kh Kd", "Ad Kc Qs Jh Th", "2d 3c 4s 5h 6d", "Ad Kc Ks 4h 3d"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/poker_trump. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/poker_trump/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PokerTrump project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/poker_trump/blob/master/CODE_OF_CONDUCT.md).
