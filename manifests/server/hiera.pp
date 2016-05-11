class bsl_puppet::server::hiera(
  $hiera_config_path = '/etc/puppetlabs/code/hiera.yaml',
) {
  ## Hiera
  file { $hiera_config_path:
    ensure  => file,
    content => template('bsl_puppet/server/hiera.yaml.erb')
  }
}