node default {

  class { 'dashboard':
    dashboard_ensure          => 'present',
    dashboard_user            => 'puppet-dbuser',
    dashboard_group           => 'puppet-dbgroup',
    dashboard_password        => 'changeme',
    dashboard_db              => 'dashboard_prod',
    dashboard_charset         => 'utf8',
    dashboard_site            => $::fqdn,
    dashboard_port            => '8081',
    mysql_root_pw             => 'changemetoo',
    passenger                 => true,
  }

}

