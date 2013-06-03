$fqdn = 'zookeeper-test0.local'

class { 'zookeeper':
  hosts    => ['zookeeper-test0.local', 'zookeeper-test1.local', 'zookeeper-test2.local'],
  data_dir => '/var/lib/zookeeper',
}

class { 'zookeeper::server': }
