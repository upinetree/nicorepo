# Nicorepo

Nicorepo is an (unofficial) API client for Nicorepo on nicovideo.jp

- Fetch nicorepo logs
- Filter them by topics and a period
- Provides a built-in CLI and commands

## Requirements

- ruby 2.3.0

## Installation

Add this line to your application's Gemfile:

    gem 'nicorepo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nicorepo

## Usage

```rb
client = Nicorepo::Client.new

client.all
# => Returns raw logs wrapped in Nicorepo::Report

client.lives(10)
# => Returns 10 live logs

client.videos(10, from: Time.now - (3600 * 24), to: Time.now - (3600 * 48))
# => Returns 10 uploaded video logs (at most) within yesterday

client.all.format
# => Returns an array of logs formatted by Nicorepo::Report::DefaultFormatter
```

### Authentication for nicovideo.jp

Nicorepo requires your nicovideo account and reads them from the `~/.netrc` file.

Add following lines to your `~/.netrc`.

```
machine nicovideo.jp
  login your@email.account
  password your-password
```

And set the permission if not yet.

```console
$ chmod 0600 ~/.netrc
```

### Start Nicorepo CLI

```console
$ nicorepo
```

You can use following commands in interactive cli.

command               | alias | description
----------------------|-------|---------------------------------------------------------
  all                 | a     | fetch all logs
  videos              | v     | fetch only video logs
  lives               | li    | fetch only live logs
  show                | s     | show current logs
  open REPORT-NUMBER  | o     | open the report url specified by number in your browser
  help [COMMAND]      | h     | Describe available commands or one specific command
  login               | lo    | re-login if your session is expired
  exit                | e     | exit interactive prompt

If you want only video logs, type `video` command.

    > video

Or you can also use aliases.

    > v

Some commands have options of `-n, --request-num=N` and `-p, --limit-page=N`.
For example:

    > lives -n20 -p5

It fetches 20 live logs at a most, with limitation of max 5 pages.

If you omit them the default values are used for that. (the defaults are configurable)

    > v
    # => `video -n10 -p10`
    > v -n20
    # => `video -n20 -p10`
    > v -p5
    # => `video -n20 -p10`

And also, you can use `-l, --latest`, `-h, --hours` and `-d, --days` options to fetch logs in the specific period.

    > all -l

Collect all logs until reach the last fetched log.

    > lives -h1

Collect live logs until 1 hour ago. 

#### Configuration for CLI

You can configure default `request_num` and `limit_page` by adding `~/.nicorepo.yaml` if you want.
Please refer the sample `nicorepo/.nicorepo.yaml.sample` or copy it to your home directory.

**Sample**

```
request_num:
  general: 20
  videos: 5
limit_page:
  general: 5
  videos: 10
```

- `general`: used in all commands
- `all`, `videos`, `lives`: used in each command, has higher priority than `general`

## Contributing

1. Fork it ( https://github.com/upinetree/nicorepo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

