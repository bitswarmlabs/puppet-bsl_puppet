class bsl_puppet::params {
  $puppetmaster_fqdn = hiera('puppetmaster', 'puppet')
  $default_admin_acct_name = hiera('default_admin_acct_name', 'admin')
  $default_admin_acct_pass = hiera('default_admin_acct_pass', 'admin')

  $server = 'false'
  $agent = 'true'

  $foreman = 'false'
  $foreman_user = $default_admin_acct_name
  $foreman_password = $default_admin_acct_pass

  $server_environment = empty($::ec2_tag_environment) ? {
    false => $::ec2_tag_environment,
    default => empty($::app_environment) ? {
      false => $::app_environment,
      default => $::environment,
    }
  }

  $app_project = empty($::app_project) ? {
    false => $::app_project,
    default => 'default'
  }

  $app_environment = $server_environment

  $server_hostname = hiera('hostname', 'puppet')
  $server_domain = hiera('domain', 'local')

  # Generate hostname
  if empty($server_domain) {
    # No domain pro\vided, won't be a FQDN
    $server_fqdn = $server_hostname
  }
  else {
    $server_fqdn = "${server_hostname}.${server_domain}"
  }

  $server_certname = $server_fqdn
  $agent_certname = $::clientcert
  $client_certname = $::clientcert

  $server_external_fqdn = hiera('external_fqdn', $server_fqdn)
  $server_external_nodes = ''

  $server_dns_alt_names = unique([ $server_hostname, $server_certname, $server_fqdn, $server_external_fqdn, $::fqdn ])

  $server_autosigns = ["*.${server_domain}", "*.internal"]

  $manage_packages = 'true'

  $server_jvm_min_heap_size = hiera('jvm_min_heap_size', '512M')
  $server_jvm_max_heap_size = hiera('jvm_max_heap_size', '900M')

  $confdir = '/etc/puppetlabs/puppet'
  $puppetserver_home = '/opt/puppetlabs/server/data/puppetserver'

  $manage_hiera = 'true'
  $manage_puppetdb = 'false'
  $manage_postgresql = 'false'
  $manage_hostname = 'false'
  $manage_puppetboard = 'false'
  $manage_r10k = 'true'
  $manage_r10k_webhooks = 'false'
  $manage_facts_d = 'false'

  # See bsl_puppet::server::r10k::deploy::post::env for where environment speciic module paths are set.
  $server_common_modules_path = [
    "/etc/puppetlabs/code/environments/common/modules",
    "/etc/puppetlabs/code/environments/common/dist",
    "/etc/puppetlabs/code/modules",
    "/opt/puppetlabs/puppet/modules"
  ]

  $server_core_modules_path  = [
    "/etc/puppetlabs/code/private/${server_environment}/modules",
    "/etc/puppetlabs/code/private/${server_environment}/dist",
    "/etc/puppetlabs/code/environments/core/modules",
    "/etc/puppetlabs/code/environments/core/dist",
  ]

  $server_private_code_path = "/etc/puppetlabs/code/private"

  $server_aws_api_key = hiera('aws_api_key', undef)
  $server_aws_api_secret = hiera('aws_api_secret', undef)
  $server_aws_default_region = hiera('aws_default_region', 'us-east-1')

  $hiera_config_path = '/etc/puppetlabs/code/hiera.yaml'
  $hiera_logger = 'console'
  $hiera_merge_behavior = 'deeper'
  $hiera_datadir = '/etc/puppetlabs/code'
  $hiera_backends = [ 'yaml' ]
  $hiera_hierarchy = [
    "private/${server_environment}/hieradata/global",
    "private/${server_environment}/hieradata/nodes/%{::trusted.certname}",
    'private/%{::server_facts.environment}/hieradata/iam/%{::iam_profile_name}',
    'private/%{::server_facts.environment}/hieradata/iam/%{::iam_profile_name}/%{::trusted.certname}',
    'private/%{::server_facts.environment}/hieradata/iam/%{::iam_profile_name}/%{::ec2_tag_profile}',
    'private/%{::server_facts.environment}/hieradata/iam/%{::iam_profile_name}/%{::ec2_tag_role}',
    'private/%{::server_facts.environment}/hieradata/iam/%{::iam_profile_name}/%{::ec2_tag_environment}',
    'environments/core/hieradata/iam/%{::iam_profile_name}/defaults',
    'environments/core/hieradata/global',
    'environments/core/hieradata/nodes/%{::trusted.certname}',
    'environments/core/hieradata/iam/%{::iam_profile_name}',
    'environments/core/hieradata/iam/%{::iam_profile_name}/%{::trusted.certname}',
    'environments/core/hieradata/iam/%{::iam_profile_name}/%{::ec2_tag_profile}',
    'environments/core/hieradata/iam/%{::iam_profile_name}/%{::ec2_tag_role}',
    'environments/core/hieradata/iam/%{::iam_profile_name}/%{::ec2_tag_environment}',
    'environments/core/hieradata/iam/%{::iam_profile_name}/defaults',
    'environments/core/hieradata/apps/%{::app_project}',
    'environments/core/hieradata/apps/%{::app_project}/%{::trusted.certname}',
    'environments/core/hieradata/apps/%{::app_project}/%{::ec2_tag_profile}',
    'environments/core/hieradata/apps/%{::app_project}/%{::ec2_tag_role}',
    'environments/core/hieradata/apps/%{::app_project}/%{::ec2_tag_environment}',
    'environments/core/hieradata/apps/%{::app_project}/defaults',
    'environments/%{::environment}/hieradata/global',
    'environments/%{::environment}/hieradata/nodes/%{::trusted.certname}',
    'environments/%{::environment}/hieradata/iam/%{::iam_profile_name}',
    'environments/%{::environment}/hieradata/iam/%{::iam_profile_name}/%{::trusted.certname}',
    'environments/%{::environment}/hieradata/iam/%{::iam_profile_name}/%{::ec2_tag_profile}',
    'environments/%{::environment}/hieradata/iam/%{::iam_profile_name}/%{::ec2_tag_role}',
    'environments/%{::environment}/hieradata/iam/%{::iam_profile_name}/%{::ec2_tag_environment}',
    'environments/%{::environment}/hieradata/iam/%{::iam_profile_name}/defaults',
    'environments/%{::environment}/hieradata/apps/%{::app_project}',
    'environments/%{::environment}/hieradata/apps/%{::app_project}/%{::trusted.certname}',
    'environments/%{::environment}/hieradata/apps/%{::app_project}/%{::ec2_tag_profile}',
    'environments/%{::environment}/hieradata/apps/%{::app_project}/%{::ec2_tag_role}',
    'environments/%{::environment}/hieradata/apps/%{::app_project}/%{::ec2_tag_environment}',
    'environments/%{::environment}/hieradata/apps/%{::app_project}/defaults',
    'environments/%{::environment}/hieradata/%{::ec2_tag_profile}',
    'environments/%{::environment}/hieradata/%{::ec2_tag_role}',
    'environments/%{::environment}/hieradata/%{::ec2_tag_environment}',
    'environments/%{::environment}/hieradata/defaults',
    "private/${server_environment}/hieradata/bootstrap/%{::app_project}",
    "private/${server_environment}/hieradata/defaults",
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

  $r10k_sources = {
    public => {
      remote            => 'https://github.com/bitswarmlabs/puppetmaster-envs.git',
      basedir           => "/etc/puppetlabs/code/environments",
      provider          => 'github',
      project           => 'bitswarmlabs/puppetmaster-envs',
      manage_deploy_key => false,
    }
  }

  $r10k_init_deploy_enabled = 'false'
  $r10k_cache_dir = "${puppetserver_home}/r10k"
  $r10k_config_file = '/etc/puppetlabs/r10k/r10k.yaml'
  $r10k_webhook_callback_fqdn = hiera('external_fqdn', $server_fqdn)
  $r10k_webhook_callback_port = '8088'
  $r10k_webhook_enable_ssl = 'false'
  $r10k_webhook_user = $default_admin_acct_name
  $r10k_webhook_pass = $default_admin_acct_pass
  $r10k_github_api_token = hiera('github_api_token', false)
  $r10k_use_mcollective = 'false'
  $r10k_postrun = ['/bin/chown', '-R', 'puppet:puppet', '/etc/puppetlabs/code']

  $puppetboard_fqdn = hiera('external_fqdn', $server_fqdn)
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
