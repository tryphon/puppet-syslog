class syslog::helper {
  file { "/usr/local/bin/syslog":
    source => "puppet:///modules/syslog/syslog.sh"
  }
}
