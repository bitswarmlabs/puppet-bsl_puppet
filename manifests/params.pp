class bsl_puppet::params {
  $puppetmaster_fqdn = hiera('puppetmaster', 'puppet')
  $default_admin_acct_name = hiera('default_admin_acct_name', 'admin')
  $default_admin_acct_pass = hiera('default_admin_acct_pass', 'admin')

  $server = 'false'

  $server_environment = $::ec2_tag_environment ? {
    /.+/ => $::ec2_tag_environment,
    default => 'production',
  }

  $server_hostname = hiera('hostname', 'puppet')
  $server_domain = hiera('domain', $::domain)
  $server_certname = "${server_hostname}.${server_domain}"
  $server_external_fqdn = hiera('external_fqdn', $::fqdn)
  $server_external_nodes = ''
  $server_dns_alt_names = [ 'puppet', $server_certname, $::fqdn]

  $manage_packages = 'false'

  $server_jvm_min_heap_size = '512M'
  $server_jvm_max_heap_size = '900M'

  $confdir = '/etc/puppetlabs/puppet'
  $puppetserver_home = '/opt/puppetlabs/server/data/puppetserver'

  $manage_hiera = 'true'
  $manage_puppetdb = 'true'
  $manage_hostname = 'true'
  $manage_puppetboard = 'false'
  $manage_r10k = 'true'
  $manage_r10k_webhooks = 'false'
  $manage_facts_d = 'false'

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

  $hiera_config_path = '/etc/puppetlabs/code/hiera.yaml'
  $hiera_logger = 'puppet'
  $hiera_merge_behavior = 'deep'
  $hiera_datadir = '/etc/puppetlabs/code'
  $hiera_backends = [ 'yaml' ]
  $hiera_hierarchy = [
    'infrastructure/%{::server.environment}/hieradata/common',
    'infrastructure/%{::server.environment}/hieradata/nodes/%{::trusted.certname}',
    'environments/core/hieradata/common',
    'environments/core/hieradata/nodes/%{::trusted.certname}',
    'environments/%{::environment}/hieradata/common',
    'environments/%{::environment}/hieradata/nodes/%{::trusted.certname}',
    'environments/%{::environment}/hieradata/%{::ec2_tag_profile}',
    'environments/%{::environment}/hieradata/%{::ec2_tag_role}',
    'environments/%{::environment}/hieradata/%{::ec2_tag_environment}',
    'environments/%{::environment}/hieradata/defaults',
    'infrastructure/%{::server.environment}/hieradata/bootstrap/%{::app_project}',
    'infrastructure/%{::server.environment}/hieradata/defaults',
    'environments/core/hieradata/bootstrap/%{::app_project}',
    'environments/core/hieradata/defaults',
  ]

  $puppetdb_host = $server_certname
  $puppetdb_database_type = 'postgres'
  $puppetdb_database_host = 'localhost'
  $puppetdb_database_port = '5432'
  $puppetdb_database_name = 'puppetdb'
  $puppetdb_database_user = 'puppetdb'
  $puppetdb_database_pass = 'puppetdb'
  $puppetdb_soft_write_failure = 'false'
  $puppetdb_validate_connection = 'false'

  $r10k_sources = undef
  $r10k_init_deploy_enabled = 'false'
  $r10k_cache_dir = "${puppetserver_home}/r10k"
  $r10k_config_file = '/etc/puppetlabs/r10k/r10k.yaml'
  $r10k_webhook_callback_fqdn = hiera('external_fqdn', $::fqdn)
  $r10k_webhook_callback_port = '8088'
  $r10k_webhook_enable_ssl = 'false'
  $r10k_webhook_user = $default_admin_acct_name
  $r10k_webhook_pass = $default_admin_acct_pass
  $r10k_github_api_token = hiera('github_api_token', '')
  $r10k_use_mcollective = 'false'

  $puppetboard_fqdn = hiera('external_fqdn', $::fqdn)
  $puppetboard_port = '80'
  $puppetboard_user = $default_admin_acct_name
  $puppetboard_pass = $default_admin_acct_pass
  $puppetboard_manage_apache_via = 'declare'

  if defined(Class['bsl_puppet::config']) {
    $config_via = 'include'
  }
  else {
    $config_via = 'declare'
  }

  $manage_dependencies = 'true'
  $manage_dependencies_via = 'include'
}
