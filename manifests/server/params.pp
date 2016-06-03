class bsl_puppet::server::params {

  # See bsl_puppet::server::r10k::deploy::post::env for where environment speciic module paths are set.

  $server_common_modules_path = [
      "/etc/puppetlabs/code/environments/common/modules",
      "/etc/puppetlabs/code/environments/common/dist",
      "/etc/puppetlabs/code/modules",
      "/opt/puppetlabs/puppet/modules"
  ]

  $server_core_modules_path  = [
      "/etc/puppetlabs/code/infrastructure/${::environment}/modules",
      "/etc/puppetlabs/code/infrastructure/${::environment}/dist"
  ]

  $server_jvm_min_heap_size = '512M'
  $server_jvm_max_heap_size = '900M'
  $use_foreman = false
  $external_nodes = false

  $hiera_datadir = '/etc/puppetlabs/code'
  $hiera_backends = [ 'yaml' ]
  $hiera_hierarchy = [
    'infrastructure/%{environment}/hieradata/common',
    'infrastructure/%{environment}/hieradata/nodes/%{::trusted.certname}',
    'environments/%{environment}/hieradata/nodes/%{::trusted.certname}',
    # 'environments/%{environment}/hieradata/%{::aws_tag_profile}',
    # 'environments/%{environment}/hieradata/%{::aws_tag_role}',
    # 'environments/%{environment}/hieradata/%{::aws_tag_environment}',
    'infrastructure/%{environment}/hieradata/bootstrap/%{::app_bootsrap_project}',
    'infrastructure/%{environment}/hieradata/defaults',
  ]

  $hiera_config_path = '/etc/puppetlabs/code/hiera.yaml'
  $hiera_logger = 'puppet'
  $hiera_merge_behavior = 'deep'

  $confdir = '/etc/puppetlabs/puppet'

  $puppet_home = '/opt/puppetlabs/server/data/puppetserver'
}
