class bsl_puppet::server::r10k::envs {
  assert_private("bsl_puppet::server::r10k::envs is a private class")

  notify { '## hello from bsl_puppet::server::r10k::envs': }

  include '::bsl_puppet::config'

  $private_code_dirs = [
    "${bsl_puppet::config::server_private_code_path}",
    "${bsl_puppet::config::server_private_code_path}/hieradata",
    "${bsl_puppet::config::server_private_code_path}/hieradata/nodes",
  ]

  file { $private_code_dirs:
    ensure => directory,
  }
  ->
  file { "${bsl_puppet::config::server_private_code_path}/hieradata/nodes/${bsl_puppet::config::server_certname}.yaml":
    ensure => file,
    replace => false,
    source => '/etc/puppetlabs/code/bsl_puppet/hieradata/puppetmaster.yaml'
  }

  bsl_puppet::server::r10k::deploy::post::env { $::puppet::server_environments: }
}
