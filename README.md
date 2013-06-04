# Puppet Zookeeper Module

Installs and configures a Zookeeper client and/or Zookeeper server.

This module has been implemented and tested on Ubuntu Precise, and uses
the Zookeeper package in upstream Debian/Ubuntu repositories.

# Usage

class { 'zookeeper':
  hosts    => ['zoo1.domain.org', 'zoo2.domain.org', 'zoo3.domain.org'],
  data_dir => '/var/lib/zookeeper',
}

The above setup should be used to configure a 3 node zookeeper cluster.
You can include the above class on any of your nodes that will need to talk
to the zookeeper cluster.

On the 3 zookeeper server nodes, you should also include:

class { 'zookeeper::server': }

This will ensure that the zookeeper server is running.
Remember that this requires that you also include the
zookeeper class as defined above as well as the server class.

On each of the defined zookeeper hosts, a myid file must be created
that identifies the host in the zookeeper quorum.  This myid number
will be inferred from the nodes index in the zookeeper hosts array.
e.g.  zoo1.domain.org's myid will be '1', zoo2.domain.org's myid will be 2, etc.