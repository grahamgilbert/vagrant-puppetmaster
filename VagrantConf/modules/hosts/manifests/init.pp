class hosts inherits hosts::params {
  file { '/etc/hosts':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("hosts/${::lsbdistcodename}/etc/hosts.erb"),
  }
}