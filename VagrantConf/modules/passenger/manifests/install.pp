class passenger::install {

  package { 'passenger':
    ensure   => $passenger::package_ensure,
    name     => $passenger::package_name,
    provider => $passenger::package_provider,
  }

  if $passenger::package_dependencies {
    package { $passenger::package_dependencies:
      ensure => present,
    }
  }

}
