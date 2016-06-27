class bsl_puppet::server(
  $hostname = $bsl_puppet::server::params::hostname,
  $domain = $bsl_puppet::server::params::domain,
  $certname = $bsl_puppet::server::params::certname,
  $dns_alt_names = $bsl_puppet::server::params::dns_alt_names,
  $server_common_modules_path = $bsl_puppet::server::params::server_common_modules_path,
  $server_core_modules_path  = $bsl_puppet::server::params::server_core_modules_path,
  $server_jvm_min_heap_size = $bsl_puppet::server::params::server_jvm_min_heap_size,
  $server_jvm_max_heap_size = $bsl_puppet::server::params::server_jvm_max_heap_size,
  $use_foreman = $bsl_puppet::server::params::use_foreman,
  $confdir = $bsl_puppet::server::params::confdir,
  $hiera_config_path = $bsl_puppet::server::params::hiera_config_path,
  $puppet_home = $bsl_puppet::server::params::puppet_home,
  $external_nodes = '',
) inherits bsl_puppet::server::params {
  include '::bsl_puppet'

  $set_fqdn = "${hostname}.${domain}"
  if $set_fqdn != $certname {
    $_dns_alt_names = concat($dns_alt_names, $set_fqdn)
  }
  else {
    $_dns_alt_names = $dns_alt_names
  }

  host { $certname:
    ip           => $::ipaddress,
    host_aliases => unique($_dns_alt_names)
  }

  if $set_fqdn != $::fqdn {
    notify { "## bsl_puppet::server changing hostname to ${set_fqdn}": }
    class { '::hostname':
      hostname => $hostname,
      domain   => $domain,
      before   => Class['::puppet'],
    }
  }
  else {
    notify { "## bsl_puppet::server not changing hostname to ${set_fqdn} (fqdn=${::fqdn}":}
  }

  class { '::puppet':
    puppetmaster                  => $::bsl_puppet::puppetmaster,
    client_certname               => $certname,
    dns_alt_names                 => unique($_dns_alt_names),
    server                        => true,
    server_certname               => $certname,
    server_implementation         => 'puppetserver',
    server_directory_environments => true,
    server_dynamic_environments   => true, # since its managed by r10k
    server_common_modules_path    => $server_common_modules_path,
    server_foreman                => false, # handling separately, see below
    server_external_nodes         => $external_nodes,
    server_jvm_min_heap_size      => $server_jvm_min_heap_size,
    server_jvm_max_heap_size      => $server_jvm_max_heap_size,
    server_reports                => 'store,puppetdb',
    server_storeconfigs_backend   => 'puppetdb',
    hiera_config                  => $hiera_config_path,
    environment                   => $::bsl_puppet::environment,
    manage_packages               => false,
    # main_template                 => 'bsl_puppet/puppet.conf.erb',
    # agent_template                => 'bsl_puppet/agent/puppet.conf.erb',
    # server_template               => 'bsl_puppet/server/puppet.conf.erb',
    #auth_template                 => 'bsl_puppet/auth.conf.erb',
    #nsauth_template               => 'bsl_puppet/namespaceauth.conf.erb'
  }

  # Class['bsl_puppet::server::hostname']~>
  # exec { 'generate puppetserver cert':
  #   command   => "puppet cert generate ${::bsl_puppet::server::fqdn}",
  #   creates   => "${::puppet::server_ssl_dir}/certs/${::bsl_puppet::server::fqdn}.pem",
  #   path      => '/opt/puppetmaster/bin:/usr/bin:/bin',
  #   notify    => [ Service['puppetserver'], Service['puppet'] ],
  #   subscribe => Class['bsl_puppet::server::hostname'],
  #   logoutput => true,
  # }

  if str2bool($use_foreman) {
    ## Foreman
    # Include foreman components for the puppetmaster
    # ENC script, reporting script etc.
    anchor { 'bsl_puppet::server::config_start': } ->
    Class['::puppet'] ->
    class { '::foreman::puppetmaster':
      foreman_url    => $::puppet::server_foreman_url,
      receive_facts  => $::puppet::server_facts,
      puppet_home    => $::puppet::vardir,
      puppet_basedir => $::puppet::server_puppet_basedir,
      puppet_etcdir  => $::puppet::dir,
      enc_api        => $::puppet::server_enc_api,
      report_api     => $::puppet::server_report_api,
      timeout        => $::puppet::server_request_timeout,
      ssl_ca         => pick($::puppet::server_foreman_ssl_ca, $::puppet::server::ssl_ca_cert),
      ssl_cert       => pick($::puppet::server_foreman_ssl_cert, $::puppet::server::ssl_cert),
      ssl_key        => pick($::puppet::server_foreman_ssl_key, $::puppet::server::ssl_cert_key),
    } ~>
    anchor { 'bsl_puppet::server::config_end': }
  }
}
