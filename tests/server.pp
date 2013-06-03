class { 'zookeeper':
  hosts    => ['zoo0.domain.org', 'zoo1.domain.org', 'zoo2.domain.org'],
  data_dir => '/var/lib/zookeeper',
}

class { 'zookeeper::server': }
