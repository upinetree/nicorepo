# Nicorepo
ニコニコ動画のニコレポをスクレイピングするためのライブラリとスクリプトです。

- 欲しいニコレポログを、欲しい数だけ取得できます（例：投稿動画を30個）
- 複数ページにわたってログを取得できます
- スクリプトを使ってターミナル上からニコレポ確認したり、ブラウザにURL送ったりできます


# 環境とか

- ruby 2.0.0p247
- 依存Gem: `mechanize`, `launchy`


# 使い方

## スクリプト

bin/nicorepoを呼び出します。本体はlib/nicorepo/cli.rbです。

    $ nicorepo command params

なお、起動前にアカウントを設定する必要があります。

config.yamlをnicorepoフォルダに作成して、下記のように記述してください。

    mail: your@mail
    pass: your_password


### command

    all, a    [disp_num]         : すべてのニコレポを表示
    videos, v [disp_num] [nest]  : 投稿動画のみ
    lives, l  [disp_num] [nest]  : 生放送のみ
    interactive, i               : 対話モード（後述）

- [disp\_num]の数だけニコレポを表示します。省略すると10個表示します

- [nest]は探しに行くページの最大数です。[nest]以上探しても[disp\_num]の数だけ見つけられない場合は諦めます。省略すると3ページです

- それぞれエイリアスが設定されています。all なら a だけで認識します


### 対話モード

`nicorepo i`で起動します。
対話モードは上記コマンドに加えて、下記の対話用コマンドが使用できます。

    open, o [log_num]  : 指定のニコレポログの対象URLをブラウザで開く
    login              : 再ログイン
    exit               : 対話モード終了

`all`や`videos`でニコレポを表示すると、各ログの最初に連番が振られます。
その連番を`open`に指定すると、対象のURLをブラウザで開きます。


### config.yaml

config.yamlでは、アカウントの設定の他に、取得するログの数、探しに行くページの数をコマンドごとに設定することが出来ます。
設定項目は以下のとおりです。

    general: コマンド全体に定義した数を設定します
    all, videos, lives: それぞれのコマンドに定義した数を設定します。generalより優先します

（例）

    general:
      num: 20
      nest: 5
    videos:
      num: 5
      nest: 10


## ライブラリ

ニコニコ動画へのログインは次のような感じです。

    repo = Nicorepo.new
    repo.login(mail, pass)

以降のニコレポ取得ですが、現在は3種類だけメソッドにしています。

    all(req_num = LOGS_PER_PAGE)
    videos(req_num = 3, page_nest_max = 5)
    lives(req_num = 3, page_nest_max = 5)

取得したニコレポは`Nicorepo::Log`のArrayで返ってきます。
中身は、

    @body   # 本文。「〜さんが…しました」
    @title  # ログ対象の名前。動画名や生放送名など
    @url    # ログ対象のURL。動画URLや生放送URLなど
    @author # ログ発生元ユーザ
    @kind   # ログの種類。CSSクラス名から抜粋したもの
    @date   # ログ発生日時

filtered_byを使うと、@kindを指定の条件でフィルタしてログを取得します。

    filtered_by(filter, req_num = LOGS_PER_PAGE, page_nest_max = 1)

例えば：

    logs = filtered_by('clip')
    logs = filtered_by('seiga')
    logs = filtered_by('mylist')

のような感じです。
