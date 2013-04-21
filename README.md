rocuses
=======

Monitoring servers tool.

# Requirements

* ruby 1.9
* log4r
* rrdtool 1.4.x
 
# install
## install agent

    # ruby setup.rb

If configration file is installed to /usr/local/etc

    # ln -s /usr/local/etc/rocuses /etc/

Create a user and group for rocusagent.

    # groupadd rocus
    # useradd -g rocus rocus

Create a directory of rocusagent.

    # mkdir /var/log/rocus
    # chown rocus:rocus /var/log/rocus

## install manager

    # ruby setup.rb

If configration file is installed to /usr/local/etc

    # ln -s /usr/local/etc/rocuses /etc/

Create a user and group for rocusesmanager

    # groupadd rocuses
    # useradd -g rocuses rocuses

Create a directory of rocusesmanager.

    # mkdir /var/log/rocuses
    # chown rocuses /var/log/rocuses

# configration
## agent configration
Edit agent configration file `/etc/rocuses/agentconfig.xml` from sample.xml. 

    # cp /etc/rocuses/agentconfig.sample.xml /etc/rocuses/agentconfig.xml
    # vi /etc/rocuses/agentconfig.xml

You should set IP addresses or hostnames of manager. Agent reject connections from non-manager IP address.
If you have not set IP addresses of manager, the agent accept connections from any IP addresses.

    <manager hostname="manager1.in.example.com"/>
    <manager hostname="192.168.0.1"/>

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

Directory of graph images.

    <graph directory="/var/rocuses/graph"/>

Make directories of Databases and graph images.

    # mkdir -p /var/rocuses/rra
    # mkdir -p /var/rocuses/graph
    # mkdir -p /var/rocuses/data
    # chown -R rocuses:rocuses /var/rocuses

create `/etc/rocuses/targetsconfig.xml`.

    # vi /etc/rocuses/targetsconfig.xml

    <?xml version="1.0" encoding="UTF-8"?>
    <rocuses>
      <targets>
        <target node="node01" hostname="192.168.0.1">
        </target>
        <target node="node02" hostname="192.168.0.2">
        </target>
      </targets>
    </rocuses>

## start agent
### On Ubuntu ( upstart )

    # cp /usr/share/rocuses/upstart/rocusagent.conf /etc/init/
    # initctl reload-configuration
    # initctl start rocusagent

## execute manager

add to crontab

    # su - rocuses
    rocuses> crontab -e
    */5 * * * * /usr/bin/rocusesmanager
