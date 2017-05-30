# Nicorepo

Nicorepo is scraper and filter of nicorepo on nicovideo.

- filter reports by kind of them
- specify number and pages to fetch reports
- open url in browser

It requires ruby 2.0.0.

## Installation

Add this line to your application's Gemfile:

    gem 'nicorepo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nicorepo

## Usage

### Authentication

Nicorepo supports reading netrc file.

Add following lines to your netrc file (`~/.netrc`)

```
machine nicovideo.jp
  login your@email.account
  password your-password
```

And set the permission if not yet.

```console
$ chmod 600 ~/.netrc
```

### Start nicorepo cli

    $ nicorepo

You can use following commands in interactive cli to fetch nicorepos.

command               | alias | description
----------------------|-------|---------------------------------------------------------
  all                 | a     | fetch all reports
  videos              | v     | fetch only video reports
  lives               | li    | fetch only live reports
  show                | s     | show current reports
  open REPORT-NUMBER  | o     | open the report url specified by number in your browser
  help [COMMAND]      | h     | Describe available commands or one specific command
  login               | lo    | re-login if your session is expired
  exit                | e     | exit interactive prompt

Some commands have specific options `-n, --request-num=N`, `-p, --limit-page=N`.
For example, if you want 20 video reports by searcing over 5 pages, the command will be,

    > video -n20 -p5

Or you can also use aliases.

    > v -n20 -p5

`-n` and `-p` are specifing options.
You can omit it as you like then each commad uses default value.

    > v
    # => `video -n10 -p3`
    > v -n20
    # => `video -n20 -p3`
    > v -p5
    # => `video -n20 -p5`

And also, you can use `-l, --latest`, `-h, --hours`, `-d, --days` options to find reports by the specific period.

    > all -l
    > lives -h 1

### Configuration

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
- `all`, `videos`, `lives`: used in each command, has priority than `general`

## Contributing

1. Fork it ( https://github.com/upinetree/nicorepo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

