# == Class zookeeper::server
# Configures a zookeeper server.
# This requires that zookeeper is installed
# And that the current nodes fqdn is an entry in the
# $::zookeeper::hosts array.
#
# == Parameters
# $jmx_port      - JMX port.  Set this to false if you don't want to expose JMX.
# $log_file      - zookeeper.log file.  Default: /var/log/zookeeper/zookeeper.log
#
class zookeeper::server(
  $jmx_port         = $::zookeeper::defaults::jmx_port,
  $log_file         = $::zookeeper::defaults::log_file,
  $default_template = $::zookeeper::defaults::default_template,
  $log4j_template   = $::zookeeper::defaults::log4j_template,
)
{
  # need zookeeper common package and config.
  Class['zookeeper'] -> Class['zookeeper::server']

  # Install zookeeper server package
  package { 'zookeeperd':
    ensure  => 'installed',
  }

  file { '/etc/default/zookeeper':
    content => template($default_template),
    require => Package['zookeeperd'],
  }

  file { '/etc/zookeeper/conf/log4j.properties':
    content => template($log4j_template),
    require => Package['zookeeperd'],
  }

  file { $::zookeeper::data_dir:
    ensure => 'directory',
    owner  => 'zookeeper',
    group  => 'zookeeper',
    mode   => '0755',
  }

  $zookeeper_hosts = $::zookeeper::hosts
  # Infer this host's $myid from the index in the $zookeeper_hosts array.
  $myid = inline_template('<%= zookeeper_hosts.index(fqdn) %>')

  file { '/etc/zookeeper/conf/myid':
    content => $myid,
  }
  file { "${::zookeeper::data_dir}/myid":
    ensure => 'link',
    target => '/etc/zookeeper/conf/myid',
  }

  service { 'zookeeper':
    ensure     => running,
    require    => [Package['zookeeperd'], File[ $::zookeeper::data_dir]],
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [
      File['/etc//default/zookeeper'],
      File['/etc/zookeeper/conf/zoo.cfg'],
      File['/etc/zookeeper/conf/myid'],
      File['/etc/zookeeper/conf/log4j.properties']
    ],
  }
}