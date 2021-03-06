rocuses
=======

Monitoring servers tool.

# Requirements

* ruby 1.9
* ruby net-ldap 0.2.2
* log4r
* rrdtool 1.4.x
 
# install
## install agent

    # ruby setup.rb

If configration file is installed to /usr/local/etc, create symlink from /usr/local/etc/rocuses to /etc/rocuses.

    # ln -s /usr/local/etc/rocuses /etc/

Create user and group for rocusagent.

    # groupadd rocus
    # useradd -g rocus rocus

Create a directory of rocusagent log files.

    # mkdir /var/log/rocus
    # chown rocus:rocus /var/log/rocus

## install manager

    # ruby setup.rb

If configration file is installed to /usr/local/etc, create symlink from /usr/local/etc/rocuses to /etc/rocuses.

    # ln -s /usr/local/etc/rocuses /etc/

Create a user and group for rocusesmanager

    # groupadd rocuses
    # useradd -g rocuses rocuses

Create a directory of rocusesmanager log files.

    # mkdir /var/log/rocuses
    # chown rocuses /var/log/rocuses
    # chmod 777 /var/log/rocuses

# configration
## agent configration

Edit agent configration file `/etc/rocuses/agentconfig.xml` from sample.xml. 

    # cp /etc/rocuses/agentconfig.sample.xml /etc/rocuses/agentconfig.xml
    # vi /etc/rocuses/agentconfig.xml

You should set IP addresses or hostnames of manager. Agent reject connections from non-manager IP address.
If you have not set IP addresses of manager, the agent accept connections from any IP addresses.

    <manager hostname="manager1.in.example.com"/>
    <manager hostname="192.168.0.1"/>

### ISC Bind Statistics

If you want get statistic of ISC Bind, you shuold add statitsics-file directive in named.conf,

    named.conf

    options {
        ...
        statistics-file "/var/named/data/named_stats.txt";
        ...
    };

and add <named_stats path="..."> and <rndc path="..."/> to agentconfig.xml.

    agentconfig.xml

    <rocuses>
      <agent>
        ...
        <options>
          ...
          <rndc path="/usr/sbin/rndc"/>
          <named_stats path="/var/named/named.stats"/>
          <!-- if named chroot to /var/named/chroot 
          <named_stats path="/var/named/chroot/var/named/named.stats"/>
          -->
          ...
        </options>
      </agent>
    <rocuses>     

### OpenLDAP Monitor Backend

If you want to get slapd of OpenLDAP statistics, you should add monitor backend 
configration to slapd.conf or cn=monitor,cn=config,

    slapd.conf

    database monitor
    rootdn cn=Admin,cn=Monitor
    rootpw *****
    access to dn.subtree="cn=Monitor"
	   by dn.exact="cn=Admin,cn=Monitor" write
	   by * none


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

# config manager
Edit agent configration file `/etc/rocuses/managerconfig.xml` from sample.xml. 

    # cp /etc/rocuses/managerconfig.sample.xml /etc/rocuses/managerconfig.xml
    # vi /etc/rocuses/managerconfig.xml

RRDTool PATH.

    <rrdtool path="/usr/local/bin/rrdtool"/>

RRDTool DataSource Step,

    <step time="300"/>

Directory of RRDTool Database files.

    <rra directory="/var/rocuses/rra"/>

Make directories of data and databases.

    # mkdir -p /var/rocuses/rra
    # mkdir -p /var/rocuses/data
    # chown -R rocuses:rocuses /var/rocuses

Create `/etc/rocuses/targetsconfig.xml`.

    # vi /etc/rocuses/targetsconfig.xml

    <?xml version="1.0" encoding="UTF-8"?>
    <rocuses>
      <targets>
        <target name="node01" hostname="192.168.0.1">
        </target>
        <target name="node02" hostname="192.168.0.2">
        </target>
      </targets>
    </rocuses>

## Start agent
### On Ubuntu ( upstart )

    # cp /usr/share/rocuses/upstart/rocusagent.conf /etc/init/
    # initctl reload-configuration
    # initctl start rocusagent

## Execute manager

add to crontab

    # su - rocuses
    rocuses> crontab -e
    */5 * * * * /usr/bin/rocusesmanager

