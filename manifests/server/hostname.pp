class bsl_puppet::server::hostname(
  $hostname = 'puppet',
  $domain = 'local',
) {
  class { '::hostname':
    hostname => $hostname,
    domain => $domain,
    notify => [Service['puppet'], Service['puppetdb'], Service['puppetserver']]
  }
}
