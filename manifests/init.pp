# Class: bsl_puppet
# ===========================
#
# Full description of class bsl_puppet here.
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
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'bsl_puppet':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
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
class bsl_puppet(
  $puppetmaster_fqdn          = $bsl_puppet::params::puppetmaster_fqdn,

  $server                     = $bsl_puppet::params::server,
  $server_environment         = $bsl_puppet::params::server_environment,
  $server_hostname            = $bsl_puppet::params::server_hostname,
  $server_domain              = $bsl_puppet::params::server_domain,
  $server_certname            = $bsl_puppet::params::server_certname,

  $manage_hiera               = $bsl_puppet::params::manage_hiera,
  $manage_puppetdb            = $bsl_puppet::params::manage_puppetdb,
  $manage_hostname            = $bsl_puppet::params::manage_hostname,
  $manage_puppetboard         = $bsl_puppet::params::manage_puppetboard,
  $manage_r10k                = $bsl_puppet::params::manage_r10k,
  $manage_r10k_webhooks       = $bsl_puppet::params::manage_r10k_webhooks,
  $manage_packages            = $bsl_puppet::params::manage_packages,
  $manage_dependencies        = $bsl_puppet::params::manage_dependencies,

  $puppetdb_database_host     = $bsl_puppet::params::puppetdb_database_host,
  $puppetdb_database_user     = $bsl_puppet::params::puppetdb_database_user,
  $puppetdb_database_pass     = $bsl_puppet::params::puppetdb_database_pass,

  $r10k_webhook_user          = $bsl_puppet::params::r10k_webhook_user,
  $r10k_webhook_pass          = $bsl_puppet::params::r10k_webhook_pass,
  $r10k_sources               = $bsl_puppet::params::r10k_sources,
  $r10k_github_api_token      = $bsl_puppet::params::r10k_github_api_token,
  $r10k_init_deploy_enabled   = $bsl_puppet::params::r10k_init_deploy_enabled,

  $puppetboard_user           = $bsl_puppet::params::puppetboard_user,
  $puppetboard_pass           = $bsl_puppet::params::puppetboard_pass,
  $puppetboard_fqdn           = $bsl_puppet::params::puppetboard_fqdn,

  $config_via                 = $bsl_puppet::params::config_via,
  $manage_dependencies_via    = $bsl_puppet::params::manage_dependencies_via,

  $manage_facts_d             = $bsl_puppet::params::manage_facts_d,

) inherits bsl_puppet::params {
  validate_re($config_via, [ '^declare', '^include', '^external' ])
  validate_re($manage_dependencies_via, [ '^declare', '^include', '^external' ])

  if $config_via == 'declare' {
    class { 'bsl_puppet::config':
      server                        => $server,
      server_environment            => $server_environment,
      server_hostname               => $server_hostname,
      server_domain                 => $server_domain,
      server_certname               => $server_certname,

      manage_hostname               => $manage_hostname,
      manage_puppetdb               => $manage_puppetdb,
      manage_hiera                  => $manage_hiera,
      manage_r10k                   => $manage_r10k,
      manage_r10k_webhooks          => $manage_r10k_webhooks,
      manage_puppetboard            => $manage_puppetboard,
      manage_packages               => $manage_packages,
      manage_dependencies           => $manage_dependencies,

      puppetdb_database_host        => $puppetdb_database_host,
      puppetdb_database_user        => $puppetdb_database_user,
      puppetdb_database_pass        => $puppetdb_database_pass,

      r10k_webhook_user             => $r10k_webhook_user,
      r10k_webhook_pass             => $r10k_webhook_pass,
      r10k_sources                  => $r10k_sources,
      r10k_github_api_token         => $r10k_github_api_token,
      r10k_init_deploy_enabled      => $r10k_init_deploy_enabled,

      puppetboard_user              => $puppetboard_user,
      puppetboard_pass              => $puppetboard_pass,
      puppetboard_fqdn              => $puppetboard_fqdn,
    }
  }
  elsif $config_via == 'include' {
    include 'bsl_puppet::config'
  }

  if str2bool($manage_facts_d) {
    include 'bsl_puppet::server::facter'
  }

  if str2bool($manage_dependencies) {
    if $manage_dependencies_via == 'declare' {
      class { '::ruby':
        gems_version => $bsl_puppet::config::ruby_gems_version,
      }
      class { '::java':

      }
      class { '::python':
        virtualenv => 'present',
        pip        => 'present',
        dev        => 'present',
      }
    }
    elsif $manage_dependencies_via == 'include' {
      include '::ruby'
      include '::java'
      include '::python'
    }
  }

  if str2bool($server) or str2bool($bsl_puppet::config::server) {
    include 'bsl_puppet::server'
    include 'bsl_puppet::server::ssh_keys'

    if str2bool($bsl_puppet::config::manage_hostname) {
      include 'bsl_puppet::server::hostname'
      Class['bsl_puppet::server::hostname']->Class['bsl_puppet::server']
    }

    if str2bool($bsl_puppet::config::manage_puppetdb) {
      include 'bsl_puppet::server::puppetdb'
    }

    if str2bool($bsl_puppet::config::manage_hiera) {
      include 'bsl_puppet::server::hiera'
    }

    if str2bool($bsl_puppet::config::manage_r10k) {
      include 'bsl_puppet::server::r10k'
      include 'bsl_puppet::server::r10k::envs'
      include 'bsl_puppet::server::r10k::cleanup'

      if str2bool($bsl_puppet::config::r10k_init_deploy_enabled) {
        include 'bsl_puppet::server::r10k::deploy'
      }

      Class['bsl_puppet::server::r10k']->
      Class['bsl_puppet::server::r10k::envs']->
      Class['bsl_puppet::server::r10k::cleanup']
    }

    if str2bool($bsl_puppet::config::manage_puppetboard) {
      include 'bsl_puppet::server::puppetboard'
    }
  }
  else {
    include 'bsl_puppet::agent'
  }
}
