# == Class zookeeper::defaults
# Default zookeeper configs.
class zookeeper::defaults {
  # NOTE: The order of this array matters.
  # The Zookeeper 'myid' will be infered by the index of a node's
  # fqdn in this array.  Changing the order will change the 'myid'
  # of zookeeper servers.
  $hosts            = [$::fqdn]

  $data_dir         = '/var/lib/zookeeper'
  $data_log_dir     = undef
  $log_file         = '/var/log/zookeeper/zookeeper.log'
  $jmx_port         = 9998

  # Default puppet paths to template config files.
  # This allows us to use custom template config files
  # if we want to override more settings than this
  # module yet supports.
  $conf_template    = 'zookeeper/zoo.cfg.erb'
  $default_template = 'zookeeper/zookeeper.default.erb'
  $log4j_template   = 'zookeeper/log4j.properties.erb'
}
