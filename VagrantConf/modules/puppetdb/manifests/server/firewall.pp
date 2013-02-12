class puppetdb::server::firewall(
    $port                   = '',
    $http_port              = $puppetdb::params::listen_port,             
    $open_http_port         = $puppetdb::params::open_listen_port,
    $ssl_port               = $puppetdb::params::ssl_listen_port,
    $open_ssl_port          = $puppetdb::params::open_ssl_listen_port,
    $manage_redhat_firewall = $puppetdb::params::manage_redhat_firewall,
) inherits puppetdb::params {
  # TODO: figure out a way to make this not platform-specific; debian and ubuntu
  # have an out-of-the-box firewall configuration that seems trickier to manage.
  # TODO: the firewall module should be able to handle this itself
  if ($puppetdb::params::firewall_supported) {

    if ($manage_redhat_firewall != undef) {
      notify {'Deprecation notice: `$manage_redhat_firewall` is deprecated in the `puppetdb::service::firewall` class and will be removed in a future version. Use `open_http_port` and `open_ssl_port` instead.':}

      if ($open_ssl_port != undef) {
        fail('`$manage_redhat_firewall` and `$open_ssl_port` cannot both be specified.')
      }
    }

    exec { 'puppetdb-persist-firewall':
      command     => $puppetdb::params::persist_firewall_command,
      refreshonly => true,
    }

    Firewall {
      notify => Exec['puppetdb-persist-firewall']
    }
    
    if ($port) {
      notify { 'Deprecation notice: `port` parameter will be removed in future versions of the puppetdb module. Please use ssl_port instead.': }
    }

    if ($port and $ssl_port) {
      fail('`port` and `ssl_port` cannot both be defined. `port` is deprecated in favor of `ssl_port`')
    }
    
    if ($open_http_port) {
      firewall { "${http_port} accept - puppetdb":
        port   => $http_port,
        proto  => 'tcp',
        action => 'accept',
      }
    }

    # This technically defaults to 'true', but in order to preserve backwards
    # compatibility with the deprecated 'manage_redhat_firewall' parameter, we
    # had to specify 'undef' as the default so that we could tell whether or
    # not the user explicitly specified a value. Here's where we're resolving
    # that and setting the 'real' default.  We should be able to get rid of
    # this block when we remove `manage_redhat_firewall`.
    if ($open_ssl_port != undef) {
      $final_open_ssl_port = $open_ssl_port
    } else {
      $final_open_ssl_port = true
    }

    if ($open_ssl_port or $manage_redhat_firewall) {
      if ($ssl_port) {
        $final_ssl_port = $ssl_port
      } else {
        $final_ssl_port = $port
      }
      firewall { "${final_ssl_port} accept - puppetdb":
        port   => $final_ssl_port,
        proto  => 'tcp',
        action => 'accept',
      }
    }
  }
}
