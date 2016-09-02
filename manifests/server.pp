# == Class zookeeper::server
# Configures a zookeeper server.
# This requires that zookeeper is installed
# And that the current nodes fqdn is an entry in the
# $::zookeeper::hosts array.
#
# == Parameters
# $jmx_port            - JMX port.    Set this to false if you don't want to expose JMX.
#
# $cleanup_count       - If this is > 0, this installs a cron to cleanup transaction
#                        and snapshot logs.  zkCleanup.sh - $cleanup_count will be run daily.
#                        Default: 10
# $cleanup_script      - Full path of the cleanup script to execute.
#                        Default: /usr/share/zookeeper/bin/zkCleanup.sh
#                        If defined it installs a daily cron.
#                        Default: '/usr/share/zookeeper/bin/zkCleanup.sh'
# $cleanup_script_args - Arguments to pass to the script (or the shell)
#                        Default: '-n 10 > /dev/null'

class zookeeper::server(
    $jmx_port            = $::zookeeper::defaults::jmx_port,
    $cleanup_count       = $::zookeeper::defaults::cleanup_count,
    $cleanup_script      = $::zookeeper::defaults::cleanup_script,
    $cleanup_script_args = $::zookeeper::defaults::cleanup_script_args,
    $default_template    = $::zookeeper::defaults::default_template,
    $log4j_template      = $::zookeeper::defaults::log4j_template
)
{
    # need zookeeper common package and config.
    Class['zookeeper'] -> Class['zookeeper::server']

    # Install zookeeper server package
    package { 'zookeeperd':
        ensure    => $::zookeeper::version,
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

    # Get this host's $myid from the $fqdn in the $zookeeper_hosts hash.
    $myid = $::zookeeper::hosts[$::fqdn]
    file { '/etc/zookeeper/conf/myid':
        content => $myid,
    }
    file { "${::zookeeper::data_dir}/myid":
        ensure => 'link',
        target => '/etc/zookeeper/conf/myid',
    }

    service { 'zookeeper':
        ensure     => running,
        require    => [
            Package['zookeeperd'],
            File[ $::zookeeper::data_dir],
            File["${::zookeeper::data_dir}/myid"],
            File['/etc/default/zookeeper'],
            File['/etc/zookeeper/conf/zoo.cfg'],
            File['/etc/zookeeper/conf/myid'],
            File['/etc/zookeeper/conf/log4j.properties'],
        ],
        hasrestart => true,
        hasstatus  => true,
    }

    cron { 'zookeeper-cleanup':
        command => "${cleanup_script} ${cleanup_script_args}",
        minute  => 10,
        hour    => 0,
        user    => 'zookeeper',
        require => Service['zookeeper'],
    }

    $cleanup_cron_ensure = cleanup_script ? {
        undef   => false,
        default => true
    }

    if (cleanup_script) {
        Cron['zookeeper-cleanup'] { ensure => $cleanup_cron_ensure}
    }
}
