# Class: bsl_puppet::config
# ===========================
#
# Creates a boot script for Puppetmaster nodes which will run a `puppet apply` with certain templated parameters.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Examples
# --------
#
# @example
#
# class { 'bsl_puppet::config':
#   manage_hiera             => true,
#   manage_puppetdb          => true,
#   manage_hostname          => true,
#   manage_puppetboard       => true,
#
#   manage_r10k              => true,
#   r10k_init_deploy_enabled => false,
#   r10k_webhook_user        => 'puppet',
#   r10k_webhook_pass        => 'puppet123',
#   r10k_sources             => {
#     'local' => {
#       remote  => 'git@mygitrepo.com/r10k_site.git',
#       basedir => "/etc/puppetlabs/code/environments",
#     }
#   }
# }
#
#
# Authors
# -------
#
# Reuben Avery <ravery@bitswarm.io>
#
# Copyright
# ---------
#
# Copyright 2016 Bitswarm Labs
#
class bsl_puppet::config(
  $puppetmaster_fqdn              = $bsl_puppet::params::puppetmaster_fqdn,
  $app_project                    = $bsl_puppet::params::app_project,
  $app_environment                = $bsl_puppet::params::app_environment,

  $agent                          = $bsl_puppet::params::agent,
  $agent_certname                 = $bsl_puppet::params::agent_certname,

  $server                         = $bsl_puppet::params::server,
  $server_environment             = $bsl_puppet::params::server_environment,
  $server_hostname                = $bsl_puppet::params::server_hostname,
  $server_domain                  = $bsl_puppet::params::server_domain,
  $server_certname                = $bsl_puppet::params::server_certname,
  $server_external_fqdn           = $bsl_puppet::params::server_external_fqdn,
  $server_external_nodes          = $bsl_puppet::params::server_external_nodes,
  $server_jvm_min_heap_size       = $bsl_puppet::params::server_jvm_min_heap_size,
  $server_jvm_max_heap_size       = $bsl_puppet::params::server_jvm_max_heap_size,
  $server_dns_alt_names           = $bsl_puppet::params::server_dns_alt_names,
  $server_autosigns               = $bsl_puppet::params::server_autosigns,
  $server_private_code_path       = $bsl_puppet::params::server_private_code_path,
  $server_aws_api_key             = $bsl_puppet::params::server_aws_api_key,
  $server_aws_api_secret          = $bsl_puppet::params::server_aws_api_secret,
  $server_aws_default_region      = $bsl_puppet::params::server_aws_default_region,

  $foreman                        = $bsl_puppet::params::foreman,
  $foreman_user                   = $bsl_puppet::params::foreman_user,
  $foreman_password               = $bsl_puppet::params::foreman_password,

  $manage_hiera                   = $bsl_puppet::params::manage_hiera,
  $manage_puppetdb                = $bsl_puppet::params::manage_puppetdb,
  $manage_postgresql              = $bsl_puppet::params::manage_postgresql,
  $manage_hostname                = $bsl_puppet::params::manage_hostname,
  $manage_puppetboard             = $bsl_puppet::params::manage_puppetboard,
  $manage_r10k                    = $bsl_puppet::params::manage_r10k,
  $manage_r10k_webhooks           = $bsl_puppet::params::manage_r10k_webhooks,
  $manage_packages                = $bsl_puppet::params::manage_packages,
  $manage_dependencies            = $bsl_puppet::params::manage_dependencies,

  $puppetdb_host                  = $bsl_puppet::params::puppetdb_host,
  $puppetdb_database_type         = $bsl_puppet::params::puppetdb_database_type,
  $puppetdb_database_host         = $bsl_puppet::params::puppetdb_database_host,
  $puppetdb_database_port         = $bsl_puppet::params::puppetdb_database_port,
  $puppetdb_database_name         = $bsl_puppet::params::puppetdb_database_name,
  $puppetdb_database_user         = $bsl_puppet::params::puppetdb_database_user,
  $puppetdb_database_pass         = $bsl_puppet::params::puppetdb_database_pass,
  $puppetdb_soft_write_failure    = $bsl_puppet::params::puppetdb_soft_write_failure,
  $puppetdb_validate_connection   = $bsl_puppet::params::puppetdb_validate_connection,

  $r10k_sources                   = $bsl_puppet::params::r10k_sources,
  $r10k_init_deploy_enabled       = $bsl_puppet::params::r10k_init_deploy_enabled,
  $r10k_cache_dir                 = $bsl_puppet::params::r10k_cache_dir,
  $r10k_config_file               = $bsl_puppet::params::r10k_config_file,
  $r10k_webhook_callback_fqdn     = $bsl_puppet::params::r10k_webhook_callback_fqdn,
  $r10k_webhook_callback_port     = $bsl_puppet::params::r10k_webhook_callback_port,
  $r10k_webhook_enable_ssl        = $bsl_puppet::params::r10k_webhook_enable_ssl,
  $r10k_webhook_user              = $bsl_puppet::params::r10k_webhook_user,
  $r10k_webhook_pass              = $bsl_puppet::params::r10k_webhook_pass,
  $r10k_github_api_token          = $bsl_puppet::params::r10k_github_api_token,
  $r10k_use_mcollective           = $bsl_puppet::params::r10k_use_mcollective,
  $r10k_postrun                   = $bsl_puppet::params::r10k_postrun,

  $puppetboard_user               = $bsl_puppet::params::puppetboard_user,
  $puppetboard_pass               = $bsl_puppet::params::puppetboard_pass,
  $puppetboard_fqdn               = $bsl_puppet::params::puppetboard_fqdn,
  $puppetboard_port               = $bsl_puppet::params::puppetboard_port,
  $puppetboard_manage_apache_via  = $bsl_puppet::params::puppetboard_manage_apache_via,

  $hiera_config_path              = $bsl_puppet::params::hiera_config_path,
  $hiera_datadir                  = $bsl_puppet::params::hiera_datadir,
  $hiera_backends                 = $bsl_puppet::params::hiera_backends,
  $hiera_hierarchy                = $bsl_puppet::params::hiera_hierarchy,
  $hiera_logger                   = $bsl_puppet::params::hiera_logger,
  $hiera_merge_behavior           = $bsl_puppet::params::hiera_merge_behavior,

  $ruby_gems_version              = 'installed',
) inherits bsl_puppet::params {
  if !empty($r10k_sources) {
    validate_hash($r10k_sources)
  }

  validate_re($puppetboard_manage_apache_via, [ '^declare', '^include', '^external' ])

  # notify { "puppetserver jvm_min_heap_size: ${server_jvm_min_heap_size}, jvm_max_heap_size: ${server_jvm_max_heap_size}": }
}
