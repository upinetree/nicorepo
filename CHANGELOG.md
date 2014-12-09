## 0.0.7 (HEAD)

* Output error reports when exceptions occurd in the parsing process.

## 0.0.6 (2014/10/18)

* Disable SSLv3 and use TLSv1 because of POODLE vulnerability
* Support rspec3

## 0.0.5 (2014/05/11)

### Features

#### CLI
* Add options `--latest`, `--hours=N`, `days=N` for fetch command
* Reports is cached and it can recalled by `show` command
  * `show` command recalls recent reports by default
  * You can specify `--more` option and it shows all report caches
  * Caches are cleared when you exit the cli
* Reports will be colorfully decorated

### API
* Enable to fetch since specific time

## 0.0.4 (2014-05-04)

### Features

#### CLI
* Add thor and reconstruct CLI
* Simplify CLI by removing exec modes without interactive mode
  * Now you can launch interaction cli without any exec options
* Use option keyword `-n` and `-p` to specify request-num and limit-page
* Change aliases
* Cache last fetched reports
* Add show command: it shows cached current reports

