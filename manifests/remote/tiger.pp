class syslog::remote::tiger($tiger_enabled = false) {
  if $tiger_enabled {
    tiger::ignore { rsyslog: }
  }
}
