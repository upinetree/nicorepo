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

### Start nicorepo cli as interactive mode

    $ nicorepo i

You can use following commands in interactive cli to fetch nicorepos.
For example, if you want 20 video reports by searcing over 5 pages, the command will be,

    > video 20 5

Or you can also use aliases.

    > v 20 5

And each commad has default value so it is simply used like,

    # it means `video 10 3`
    > v

**Commands**

command  | alias | params        | description
---------|-------|---------------|-------------------------------------
  all    | a     | disp_num      | all reports
  videos | v     | disp_num nest | only videos
  lives  | l     | disp_num nest | only lives
  open   | o     | log_num       | open the specified report url in the browser
  login  |       |               | re-login
  exit   |       |               | exit nicorepo

### Configuration

You can configure default `disp_num` and `nest` by adding `~/.nicorepo.yaml` if you want.
Please refer the sample `nicorepo/.nicorepo.yaml.sample` or copy it to your home directory.

**Sample**

```
num:
  general: 20
  videos: 5
nest:
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

