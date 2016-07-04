class bsl_puppet::server::r10k::envs {
  assert_private("bsl_puppet::server::r10k::envs is a private class")

  notify { '## hello from bsl_puppet::server::r10k::envs': }

  include '::bsl_puppet::config'

  file { "${bsl_puppet::config::server_private_code_path}":
    ensure => directory,
  }
  ->
  file { "${bsl_puppet::config::server_private_code_path}/${bsl_puppet::config::server_environment}":
    ensure => directory,
  }
  ->
  file { "${bsl_puppet::config::server_private_code_path}/${bsl_puppet::config::server_environment}/hieradata":
    ensure => directory,
  }
  ->
  file { "${bsl_puppet::config::server_private_code_path}/${bsl_puppet::config::server_environment}/hieradata/nodes":
    ensure => directory,
  }
  ->
  file { "${bsl_puppet::config::server_private_code_path}/${bsl_puppet::config::server_environment}/hieradata/nodes/${bsl_puppet::config::server_certname}.yaml":
    ensure => file,
    replace => false,
    content => template('bsl_puppet/server/puppetmaster-hieradata.yaml.erb')
  }

  bsl_puppet::server::r10k::deploy::post::env { $::puppet::server_environments: }
}
