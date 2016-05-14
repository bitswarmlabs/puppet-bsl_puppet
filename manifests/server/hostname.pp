class bsl_puppet::server::hostname(
  $hostname = 'puppet',
  $domain = 'local',
) {
  class { '::hostname':
    hostname => $hostname,
    domain   => $domain,
    notify   => [Service['puppet'], Service['puppetdb'], Service['puppetserver']]
  }

  if ! defined(Host[$::bsl_puppet::server_certname]) {
    if $::bsl_puppet::server_certname != $::hostname {
      host { $::bsl_puppet::server_certname:
        ip           => '127.0.0.1',
        host_aliases => [$::hostname],
      }
    }
    else {
      host { $::bsl_puppet::server_certname:
        ip           => '127.0.0.1',
      }
    }
  }
}
