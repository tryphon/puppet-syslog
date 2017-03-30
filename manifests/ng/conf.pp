define syslog::ng::conf($source = false, $content = false) {
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
