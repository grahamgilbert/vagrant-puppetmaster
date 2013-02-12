class { 'postgresql::server':
    version => "8.4",

}

postgresql::db { 'test_app':
    user => 'test_app_user',
    password => 'test_app_password',
    host => 'localhost',
    require => Class['postgresql::server'],
}

