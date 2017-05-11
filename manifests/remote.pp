class syslog::remote (
  $syslog_servers = undef,
  ) {
  package { rsyslog:
    alias => syslog
  }

  service { rsyslog:
    ensure => running
  }

  file { '/etc/logrotate.d/rsyslog':
    source  => 'puppet:///modules/syslog/rsyslog.logrotate',
    require => [Package['rsyslog'], File['/usr/local/sbin/rsyslog-postrotate']],
    mode    => '0644'
  }

  file { '/usr/local/sbin/rsyslog-postrotate':
    source  => 'puppet:///modules/syslog/rsyslog-postrotate',
    mode    => '0755',
    require => Package['rsyslog']
  }

  file { "/etc/rsyslog.conf":
    content => template("syslog/rsyslog.conf"),
    require => Package[rsyslog],
    notify  => Service[rsyslog]
  }

  include syslog::remote::tiger
}
