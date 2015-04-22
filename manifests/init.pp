class syslog {
  if !defined(Class['syslog::ng']) {
    if ($syslog_server == $fqdn or $syslog_server == $ipaddress) {
      include syslog::ng
    } else {
      include syslog::remote
    }
  }

  include syslog::helper
}

class syslog::remote {
  package { rsyslog:
    alias => syslog
  }

  service { rsyslog:
    ensure => running
  }

  file { '/etc/logrotate.d/rsyslog':
    source => 'puppet:///syslog/rsyslog.logrotate',
    require => [Package['rsyslog'], File['/usr/local/sbin/rsyslog-postrotate']],
    mode => 644
  }

  file { '/usr/local/sbin/rsyslog-postrotate':
    source => 'puppet:///syslog/rsyslog-postrotate',
    mode => 755,
    require => Package['rsyslog']
  }

  file { "/etc/rsyslog.conf":
    content => template("syslog/rsyslog.conf"),
    require => Package[rsyslog],
    notify => Service[rsyslog]
  }

  include syslog::remote::tiger
}

class syslog::remote::tiger {
  if $tiger_enabled {
    tiger::ignore { rsyslog: }
  }
}

class syslog::ng {
  package { syslog-ng:
    alias => syslog
  }

  file { "/etc/syslog-ng/syslog-ng.conf":
    source => "puppet:///syslog/syslog-ng.conf",
    require => Package[syslog-ng],
    notify => Service[syslog-ng]
  }

  service { "syslog-ng":
    ensure => running,
    require => Package[syslog-ng]
  }

  file { "/etc/logrotate.d/syslog-ng":
    source => "puppet:///syslog/syslog-ng.logrotate",
    require => Package[syslog-ng],
    mode => 644
  }

  file { '/srv/log':
    ensure => directory
  }
  file { '/srv/log/syslog':
    ensure => present,
    group => adm,
    mode => 644
  }
  file { '/var/log/syslog':
    ensure => link,
    target => '/srv/log/syslog'
  }
}

class syslog::helper {
  file { "/usr/local/bin/syslog":
    source => "puppet:///syslog/syslog.sh"
  }
}

class rsyslog::module::file {
  file { "/etc/rsyslog.d/00imfile.conf":
    content => '$ModLoad imfile',
    require => Package[rsyslog],
    notify => Service[rsyslog]
  }
}
