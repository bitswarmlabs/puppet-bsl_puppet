class bsl_puppet::server::hiera(
  $datadir = $bsl_puppet::server::params::hiera_datadir,
  $backends = $bsl_puppet::server::params::hiera_backends,
  $hierarchy = $bsl_puppet::server::params::hiera_hierarchy,
  $logger = $bsl_puppet::server::params::hiera_logger,
  $merge_behavior = $bsl_puppet::server::params::hiera_merge_behavior,
) inherits bsl_puppet::server::params {
  $hiera_config_path = $bsl_puppet::server::hiera_config_path
  $confdir = $bsl_puppet::server::confdir

  ## Hiera
  # file { $hiera_config_path:
  #   ensure  => file,
  #   content => template('bsl_puppet/server/hiera.yaml.erb')
  # }

  class { '::hiera':
    hiera_yaml     => $hiera_config_path,
    datadir        => $datadir,
    backends       => $backends,
    hierarchy      => $hierarchy,
    logger         => $logger,
    merge_behavior => $merge_behavior,
    confdir        => $confdir,
  }
}
