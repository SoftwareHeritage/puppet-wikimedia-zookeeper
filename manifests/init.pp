# == Class zookeeper
# Installs common zookeeper package and configs.
#
# == Parameters
# $hosts         - Array of zookeeper fqdns.  The order of this array matters.
#                  Zookeeper 'myid's will be inferred from the node's index in this array.
# $data_dir      - Zookeeper dataDir.     Default: /var/lib/zookeeper
# $data_log_dir  - Zookeeper dataLogDir.  Default: undef.
#
# == Usage
#
# class { 'zookeeper':
#   hosts    => ['zoo0.domain.org', 'zoo1.domain.org', 'zoo2.domain.org'],
#   data_dir => '/var/lib/zookeeper',
# }
#
# The above setup should be used to configure a 3 node zookeeper cluster.
# You can include the above class on any of your nodes that will need to talk
# to the zookeeper cluster.
#
# On the 3 zookeeper server nodes, you should also include:
#
# class { 'zookeeper::server': }
#
# This will ensure that the zookeeper server is running.
# Remember that this requires that you also include the
# zookeeper class as defined above as well as the server class.
#
# On each of the defined zookeeper hosts, a myid file must be created
# that identifies the host in the zookeeper quorum.  This myid number
# will be inferred from the nodes index in the zookeeper hosts array.
# e.g.  zoo0.domain.org's myid will be '0', zoo1.domain.org's myid will be 1, etc.
#
class zookeeper(
  $hosts         = $::zookeeper::defaults::hosts,
  $data_dir      = $::zookeeper::defaults::data_dir,
  $data_log_dir  = $::zookeeper::defaults::data_log_dir,
  $conf_template = $::zookeeper::defaults::conf_template,
) inherits zookeeper::defaults
{
  package { ['zookeeper', 'zookeeper-bin']:
    ensure => 'installed',
  }

  file { '/etc/zookeeper/conf/zoo.cfg':
    content => template($conf_template),
    require => Package['zookeeper'],
  }
}