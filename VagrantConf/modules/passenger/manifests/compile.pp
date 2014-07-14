class passenger::compile {

  exec {'compile-passenger':
    path      => [ $passenger::gem_binary_path, '/usr/bin', '/bin', '/usr/local/bin' ],
    command   => 'passenger-install-apache2-module -a',
    logoutput => on_failure,
    creates   => $passenger::mod_passenger_location,
    timeout   => 0,
  }

}
