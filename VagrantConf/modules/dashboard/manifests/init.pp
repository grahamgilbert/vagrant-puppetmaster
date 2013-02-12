class dashboard (
  $dashboard_ensure         = $dashboard::params::dashboard_ensure,
  $dashboard_user           = $dashboard::params::dashboard_user,
  $dashboard_group          = $dashboard::params::dashboard_group,
  $dashboard_password       = $dashboard::params::dashboard_password,
  $dashboard_db             = $dashboard::params::dashboard_db,
  $dashboard_charset        = $dashboard::params::dashboard_charset,
  $dashboard_site           = $dashboard::params::dashboard_site,
  $dashboard_port           = $dashboard::params::dashboard_port,
  $dashboard_config         = $dashboard::params::dashboard_config,
  $mysql_root_pw            = $dashboard::params::mysql_root_pw,
  $passenger                = $dashboard::params::passenger,
  $mysql_package_provider   = $dashboard::params::mysql_package_provider,
  $ruby_mysql_package       = $dashboard::params::ruby_mysql_package,
  $dashboard_config         = $dashboard::params::dashboard_config,
  $dashboard_root           = $dashboard::params::dashboard_root,
  $rack_version             = $dashboard::params::rack_version,
  $dashboard_workers_start  = $dashboard::params::dashboard_workers_start,
  $num_delayed_job_workers  = $dashboard::params::num_delayed_job_workers
) inherits dashboard::params {

  require mysql
  class { 'mysql::server':
    config_hash => { 'root_password' => $mysql_root_pw }
  }
  class { 'mysql::ruby':
    package_provider => $mysql_package_provider,
    package_name     => $ruby_mysql_package,
  }

  if $passenger {
    class { 'dashboard::passenger':
      dashboard_site   => $dashboard_site,
      dashboard_port   => $dashboard_port,
      dashboard_config => $dashboard_config,
      dashboard_root   => $dashboard_root,
    }
  } else {
      file { 'dashboard_config':
      ensure  => present,
      path    => $dashboard_config,
      content => template("dashboard/config.${::osfamily}.erb"),
      owner   => '0',
      group   => '0',
      mode    => '0644',
      require => Package[$dashboard_package],
    }

    service { $dashboard_service:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      subscribe  => [File['/etc/puppet-dashboard/database.yml'],File['/etc/puppet-dashboard/settings.yml']],
      require    => Exec['db-migrate']
    }
  }

  file { 'dashboard_workers':
    ensure => present,
    path   => $dashboard_workers,
    content => template("dashboard/config-dashboard-workers.erb"),
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => [ Package[$dashboard_package], User[$dashboard_user] ],
  }


  service { $dashboard_workers_service:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [File['/etc/puppet-dashboard/database.yml'],File['/etc/puppet-dashboard/settings.yml']],
    require    => File['dashboard_workers']
  }

  package { $dashboard_package:
    ensure  => $dashboard_version,
    require => [ Package['rdoc'], Package['rack']],
  }

  # Currently, the dashboard requires this specific version
  #  of the rack gem. Using the gem provider by default.
  package { 'rack':
    ensure   => $rack_version,
    provider => 'gem',
  }

  package { ['rake', 'rdoc']:
    ensure   => present,
    provider => 'gem',
  }

  File {
    mode    => '0755',
    owner   => $dashboard_user,
    group   => $dashboard_group,
    require => Package[$dashboard_package],
  }

  file { [ "${dashboard::params::dashboard_root}/public", "${dashboard::params::dashboard_root}/tmp", "${dashboard::params::dashboard_root}/log", '/etc/puppet-dashboard' ]:
    ensure       => directory,
    recurse      => true,
    recurselimit => '1',
    mode          => "0777",
  }

  file {'/etc/puppet-dashboard/database.yml':
    ensure  => present,
    content => template('dashboard/database.yml.erb'),
  }
  
  file {'/etc/puppet-dashboard/settings.yml':
    ensure  => present,
    content => template('dashboard/settings.erb'),
  }

  file { "${dashboard::params::dashboard_root}/config/database.yml":
    ensure => 'symlink',
    target => '/etc/puppet-dashboard/database.yml',
  }
  
  file { "${dashboard::params::dashboard_root}/spool":
    ensure => 'directory',
    owner => $dashboard_user,
    group => $dashboard_group,
  }
  
  file { "${dashboard::params::dashboard_root}/config/settings.yml":
    ensure => 'symlink',
    target => '/etc/puppet-dashboard/settings.yml',
  }

  file { [ "${dashboard::params::dashboard_root}/log/production.log", "${dashboard::params::dashboard_root}/config/environment.rb" ]:
    ensure => file,
    mode   => '0644',
  }

  file { '/etc/logrotate.d/puppet-dashboard':
    ensure  => present,
    content => template('dashboard/logrotate.erb'),
    owner   => '0',
    group   => '0',
    mode    => '0644',
  }

  exec { 'db-migrate':
    command => 'rake RAILS_ENV=production db:migrate',
    cwd     => $dashboard::params::dashboard_root,
    path    => '/usr/bin/:/usr/local/bin/',
    creates => "/var/lib/mysql/${dashboard_db}/nodes.frm",
    require => [Package[$dashboard_package], Mysql::Db[$dashboard_db],
                File["${dashboard::params::dashboard_root}/config/database.yml"]],
  }

  mysql::db { $dashboard_db:
    user     => $dashboard_user,
    password => $dashboard_password,
    charset  => $dashboard_charset,
  }

  user { $dashboard_user:
      ensure     => 'present',
      comment    => 'Puppet Dashboard',
      gid        => $dashboard_group,
      shell      => '/sbin/nologin',
      managehome => true,
  }

  group { $dashboard_group:
      ensure => 'present',
  }
}

