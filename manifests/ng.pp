class syslog::ng($forwarder = false, $forwarder_port = 514, $keep_hostname = false) {
  package { 'syslog-ng-core':
    alias => syslog
  }

  file { "/etc/syslog-ng/syslog-ng.conf":
    source  => "puppet:///modules/syslog/syslog-ng.conf",
    require => Package['syslog-ng-core'],
    notify  => Service[syslog-ng]
  }

  service { 'syslog-ng':
    ensure  => running,
    require => Package['syslog-ng-core']
  }

  file { "/etc/logrotate.d/syslog-ng":
    source  => "puppet:///modules/syslog/syslog-ng.logrotate",
    require => Package['syslog-ng-core'],
    mode    => '0644'
  }

  file { '/srv/log':
    ensure => directory
  }
  file { '/srv/log/syslog':
    ensure => present,
    group  => adm,
    mode   => '0644'
  }
  file { '/var/log/syslog':
    ensure => link,
    target => '/srv/log/syslog'
  }

  syslog::ng::conf { 'source':
    content => template('syslog/syslog-ng-source')
  }

  if $forwarder {
    syslog::ng::conf { 'forwarder':
      content => "destination d_forwarder { udp(\"$forwarder\" port(${forwarder_port})); };\nlog { source(s_all); destination(d_forwarder); };"
    }
  }
}
