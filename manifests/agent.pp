class bsl_puppet::agent {
  if ! defined(Class['::puppet']) {
    class { '::puppet':
      server                      => false,
      environment                 => $::bsl_puppet::environment,
      manage_packages             => false,
    }
  }
}