class syslog($syslog_server = $fqdn) {
  if !defined(Class['syslog::ng']) {
    if ($syslog_server == $fqdn or $syslog_server == $ipaddress) {
      include syslog::ng
    } else {
      class { 'syslog::remote':
        syslog_servers => $syslog_server,
      }
    }
  }

  include syslog::helper
}





class rsyslog::module::file {
  file { "/etc/rsyslog.d/00imfile.conf":
    content => '$ModLoad imfile',
    require => Package[rsyslog],
    notify => Service[rsyslog]
  }
}
