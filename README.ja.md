rocuses
=======

monitoring servers tool.

# 前提条件

* ruby 1.9
* log4r

# インストール方法

    # ruby setup.rb

`/etc/rocuses`以外へ設定ファイルのサンプルをインストールした場合は、シンボリックリンクを作成する。
`/usr/local/etc/rocuses`へ設定ファイルのサンプルをインストールした場合は、以下コマンドを実行する。

    # ln -s /usr/local/etc/rocuses /etc/

# 設定
## エージェントの設定
エージェントの設定は、`/etc/rocuses/agentconfig.xml`を作成する。

    # cp /etc/rocuses/agentconfig.sample.xml /etc/rocuses/agentconfig.xml
    # vi /etc/rocuses/agentconfig.xml

マネージャのIPアドレスを設定する。エージェントは、マネージャとして設定したIPアドレス以外の接続を拒否する。
もし、マネージャのIPアドレスを設定しなかった場合は、任意のIPアドレスからの接続を許可する。
マネージャのIPアドレスは、複数設定することができる。また、IPアドレスの代わりにホスト名（IPアドレスの逆引き結果）も設定できる。

    <manager hostname="manager1.in.example.com"/>
    <manager hostname="192.168.0.1"/>

## マネージャの設定
マネージャの設定は、`/etc/rocuses/managerconfig.xml`を作成する。

    # cp /etc/rocuses/managerconfig.sample.xml /etc/rocuses/managerconfig.xml
    # vi /etc/rocuses/managerconfig.xml

RRDToolのPATHを設定する。

    <rrdtool path="/usr/local/bin/rrdtool"/>

RRDToolのDataSourceのStepを設定する。

    <step time="300"/>

RRDToolのデータベースファイルの保存先ディレクトリを指定する。

    <rra directory="/var/rocuses/rra"/>

グラフの保存先ディレクトリを設定する。

    <graph directory="/var/rocuses/graph"/>

データベースとグラフの保存先ディレクトリを作成する。

    # mkdir -p /var/rocuses/rra
    # mkdir -p /var/rocuses/graph

## リソース情報取得対象の登録

`/etc/rocuses/targetsconfig.xml`を作成する。

    <?xml version="1.0" encoding="UTF-8"?>
    <rocuses>
      <targets>
        <target node="node01" hostname="192.168.0.1">
        </target>
        <target node="node02" hostname="192.168.0.2">
        </target>
      </targets>
    </rocuses>


## エージェントの実行

    # rocusagent

## マネージャの実行（データ取得・グラフ作成）

    # crontab -e
    */5 * * * * /usr/bin/rocusesmanager

