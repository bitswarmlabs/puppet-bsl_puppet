class bsl_puppet::agent {
  include 'bsl_puppet::config'

  $manage_packages = str2bool($bsl_puppet::config::manage_packages) ? {
    true => 'agent',
    default => undef,
  }

  if ! defined(Class['::puppet']) {
    class { '::puppet':
      server                      => false,
      manage_packages             => $manage_packages,
    }
  }
}
