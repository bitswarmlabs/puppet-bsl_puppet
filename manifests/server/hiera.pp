class bsl_puppet::server::hiera {
  include 'bsl_puppet::config'

  notify { '## hello from bsl_puppet::server::hiera': }

  class { '::hiera':
    hiera_yaml     => $bsl_puppet::config::hiera_config_path,
    datadir        => $bsl_puppet::config::hiera_datadir,
    backends       => $bsl_puppet::config::hiera_backends,
    hierarchy      => $bsl_puppet::config::hiera_hierarchy,
    logger         => $bsl_puppet::config::hiera_logger,
    merge_behavior => $bsl_puppet::config::hiera_merge_behavior,
    confdir        => $bsl_puppet::config::confdir,
    master_service => 'puppetserver',
  }
}
