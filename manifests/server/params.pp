class bsl_puppet::server::params {

  $fqdn = "${hostname}.${domain}"
  $certname = $::clientcert

  if $certname == $::bsl_puppet::puppetmaster {
    $dns_alt_names = [ 'puppet', $::fqdn ]
  }
  else {
    $dns_alt_names = [ 'puppet', $::bsl_puppet::puppetmaster, $::fqdn ]
  }

  $external_fqdn = hiera('external_fqdn', $::fqdn)
  $puppetdb_host = $certname

  $hiera_config_path = '/etc/puppetlabs/code/hiera.yaml'
  $hiera_logger = 'puppet'
  $hiera_merge_behavior = 'deep'

  $confdir = '/etc/puppetlabs/puppet'
  $puppet_home = '/opt/puppetlabs/server/data/puppetserver'

  $server_jvm_min_heap_size = '512M'
  $server_jvm_max_heap_size = '900M'
  $use_foreman = 'false'


  # See bsl_puppet::server::r10k::deploy::post::env for where environment speciic module paths are set.
  $server_common_modules_path = [
      "/etc/puppetlabs/code/environments/common/modules",
      "/etc/puppetlabs/code/environments/common/dist",
      "/etc/puppetlabs/code/modules",
      "/opt/puppetlabs/puppet/modules"
  ]

  $server_core_modules_path  = [
      "/etc/puppetlabs/code/infrastructure/${::environment}/modules",
      "/etc/puppetlabs/code/infrastructure/${::environment}/dist",
      "/etc/puppetlabs/code/environments/core/modules",
      "/etc/puppetlabs/code/environments/core/dist",
  ]

  $hiera_datadir = '/etc/puppetlabs/code'
  $hiera_backends = [ 'yaml' ]
  $hiera_hierarchy = [
    'infrastructure/%{environment}/hieradata/common',
    'infrastructure/%{environment}/hieradata/nodes/%{trusted.certname}',
    'environments/core/hieradata/common',
    'environments/core/hieradata/nodes/%{trusted.certname}',
    "environments/${::environment}/hieradata/nodes/%{trusted.certname}",
    "environments/${::environment}/hieradata/%{ec2_tag_profile}",
    "environments/${::environment}/hieradata/%{ec2_tag_role}",
    "environments/${::environment}/hieradata/%{ec2_tag_environment}",
    "infrastructure/${::environment}/hieradata/bootstrap/%{app_project}",
    "infrastructure/${::environment}/hieradata/defaults",
    'environments/core/hieradata/bootstrap/%{app_project}',
    'environments/core/hieradata/defaults',
  ]
}
