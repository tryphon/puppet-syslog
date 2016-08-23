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
    source => 'puppet:///modules/syslog/rsyslog.logrotate',
    require => [Package['rsyslog'], File['/usr/local/sbin/rsyslog-postrotate']],
    mode => 644
  }

  file { '/usr/local/sbin/rsyslog-postrotate':
    source => 'puppet:///modules/syslog/rsyslog-postrotate',
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

class syslog::ng($forwarder = false, $keep_hostname = false) {
  package { 'syslog-ng-core':
    alias => syslog
  }

  file { "/etc/syslog-ng/syslog-ng.conf":
    source => "puppet:///modules/syslog/syslog-ng.conf",
    require => Package['syslog-ng-core'],
    notify => Service[syslog-ng]
  }

  service { 'syslog-ng':
    ensure => running,
    require => Package['syslog-ng-core']
  }

  file { "/etc/logrotate.d/syslog-ng":
    source => "puppet:///modules/syslog/syslog-ng.logrotate",
    require => Package['syslog-ng-core'],
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

  syslog::ng::conf { 'source':
    content => template('syslog/syslog-ng-source')
  }

  if $forwarder {
    syslog::ng::conf { 'forwarder':
      content => "destination d_loghost { udp(\"$forwarder\" port(514)); };\nlog { source(s_all); destination(d_loghost); };"
    }
  }

  define conf($source = false, $content = false) {
    $filename = "/etc/syslog-ng/conf.d/$name.conf"

    if $content {
      file { $filename:
        content => $content,
        require => Package['syslog'],
        notify => Service['syslog-ng']
      }
    } else {
      file { $filename:
        source => $source,
        require => Package['syslog'],
        notify => Service['syslog-ng']
      }
    }
  }
}

class syslog::helper {
  file { "/usr/local/bin/syslog":
    source => "puppet:///modules/syslog/syslog.sh"
  }
}

class rsyslog::module::file {
  file { "/etc/rsyslog.d/00imfile.conf":
    content => '$ModLoad imfile',
    require => Package[rsyslog],
    notify => Service[rsyslog]
  }
}
