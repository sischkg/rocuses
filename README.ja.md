rocuses
=======

monitoring servers tool.

# 前提条件

* ruby 1.9
* ruby net-ldap 0.2.2
* log4r
* rrdtool 1.4.x

# インストール方法
## エージェントのインストール

    # ruby setup.rb

`/etc/rocuses`以外へ設定ファイルのサンプルをインストールした場合は、シンボリックリンクを作成する。
`/usr/local/etc/rocuses`へ設定ファイルのサンプルをインストールした場合は、以下コマンドを実行する。

    # ln -s /usr/local/etc/rocuses /etc/

エージェント用ユーザ・グループを作成する。

    # groupadd rocus
    # useradd -g rocus rocus

エージェントのログ保存ディレクトリを作成する。

    # mkdir /var/log/rocus
    # chown rocus:rocus /var/log/rocus

## マネージャのインストール方法

    # ruby setup.rb

`/etc/rocuses`以外へ設定ファイルのサンプルをインストールした場合は、シンボリックリンクを作成する。
`/usr/local/etc/rocuses`へ設定ファイルのサンプルをインストールした場合は、以下コマンドを実行する。

    # ln -s /usr/local/etc/rocuses /etc/

マネージャ用ユーザ・グループを作成する。

    # groupadd rocuses
    # useradd -g rocuses rocuses

マネージャのログ保存ディレクトリを作成する。

    # mkdir /var/log/rocuses
	# chown rocuses:rocuses /var/log/rocuses
    # chmod 777 /var/log/rocuses

# 設定
## エージェントの設定
エージェントは、`/etc/rocuses/agentconfig.xml`にて設定する。

    # cp /etc/rocuses/agentconfig.sample.xml /etc/rocuses/agentconfig.xml
    # vi /etc/rocuses/agentconfig.xml

マネージャのIPアドレスを設定する。エージェントは、マネージャとして設定したIPアドレス以外の接続を拒否する。
もし、マネージャのIPアドレスを設定しなかった場合は、任意のIPアドレスからの接続を許可する。
マネージャのIPアドレスは、複数設定することができる。また、IPアドレスの代わりにホスト名（IPアドレスの逆引き結果）も設定できる。

    <manager hostname="manager1.in.example.com"/>
    <manager hostname="192.168.0.1"/>

ISC Bindの情報を取得する場合は、named.confでstatitsics-fileの設定を行う。

    named.conf

    options {
        ...
        statistics-file "/var/named/data/named_stats.txt";
        ...
    };
  
エージェント設定ファイルにrndcのpathとstatistics-fileのpathを設定する。

    agentconfig.xml

    <rocuses>
      <agent>
        ...
        <options>
          <rndc path="/usr/sbin/rndc"/>
          <named_stats path="/var/named/named.stats"/>
          <!-- if named chroot to /var/named/chroot 
          <named_stats path="/var/named/chroot/var/named/named.stats"/>
          -->
          ...
        </options>
      </agent>
    <rocuses>     

OpenLDAPの情報を取得するには、slapd.confにMonitor Backendを設定する。

    slapd.conf

    database monitor
    rootdn cn=Admin,cn=Monitor
    rootpw *****
    access to dn.subtree="cn=Monitor"
	   by dn.exact="cn=Admin,cn=Monitor" write
	   by * none


エージェント設定ファイルに、slapdのポート番号とBind DN、パスワードを設定する。

    agentconfig.xml

    <rocuses>
      <agent>
        ...
        <options>
          ...
          <openldap port="389" bind_dn="cn=Admin,cn=Monitor" bind_password="****"/>
          ...
        </options>
      </agent>
    <rocuses>     

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
    # mkdir -p /var/rocuses/data
    # chown -R rocuses:rocuses /var/rocuses

## リソース情報取得対象の登録

`/etc/rocuses/targetsconfig.xml`を作成する。

    <?xml version="1.0" encoding="UTF-8"?>
    <rocuses>
      <targets>
        <target name="node01" hostname="192.168.0.1">
        </target>
        <target name="node02" hostname="192.168.0.2">
        </target>
      </targets>
    </rocuses>


## エージェントの実行
### Ubuntuの場合

upstartへ登録する。

    # cp /usr/share/rocuses/upstart/rocusagent.conf /etc/init/
    # initctl reload-configuration

エージェントを起動する。

    # initctl start rocusagent

## マネージャの実行（データ取得）

    # su - rocuses
    rocuses$ crontab -e
    
    */5 * * * * /usr/bin/rocusesmanager

