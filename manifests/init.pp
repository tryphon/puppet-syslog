class syslog {
  if ($syslog_server == $fqdn) {
    include syslog::ng
  } else {
    include syslog::remote
  }
}

class syslog::remote {
  package { rsyslog:
    alias => syslog
  }

  service { rsyslog:
    ensure => running
  }

  # send messages to nas.studio.priv
  line { syslog_to_admin:
    file => "/etc/rsyslog.conf",
    line => "*.*             @$syslog_server",
    notify => Service[rsyslog]
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

  service { syslog-ng:
    ensure => running,
    require => Package[syslog-ng]
  }

}
