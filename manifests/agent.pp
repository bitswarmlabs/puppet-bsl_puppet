class bsl_puppet::agent {
  include 'bsl_puppet::config'

  $manage_packages = str2bool($bsl_puppet::config::manage_packages) ? {
    true => 'agent',
    default => undef,
  }

  if ! defined(Class['::puppet']) {
    anchor { 'bsl_puppet::agent::begin': }
    ->
    class { '::puppet':
      agent           => str2bool($bsl_puppet::config::agent),
      server          => false,
      puppetmaster    => $bsl_puppet::config::puppetmaster_fqdn,
      client_certname => $bsl_puppet::config::agent_certname,
      manage_packages => $manage_packages,
    }
    ->
    anchor { 'bsl_puppet::agent::end': }
  }
}
