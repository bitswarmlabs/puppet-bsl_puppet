class bsl_puppet::server::hostname {
  class { '::hostname':
    hostname => 'puppet',
    domain => 'local',
    notify => [Service['puppet'], Service['puppetdb'], Service['puppetserver']]
  }
}