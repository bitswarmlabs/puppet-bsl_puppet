class bsl_puppet::server(
  $server_core_modules_path  = ["/etc/puppetlabs/code/infrastructure/${::environment}/modules"],
  $hiera_config_path = '/etc/puppetlabs/code/hiera.yaml',
  $server_jvm_min_heap_size = '512M',
  $server_jvm_max_heap_size = '900M',
  $use_foreman = false,
  $external_nodes = false,
) {
  include '::bsl_puppet'

  host { $::bsl_puppet::server_certname:
    ip           => '127.0.0.1',
    host_aliases => [$::hostname, $::fqdn],
  }

  class { '::puppet':
    server                        => true,
    server_implementation         => 'puppetserver',
    server_directory_environments => true,
    server_dynamic_environments   => true, # since its managed by r10k
    server_foreman                => false, # handling separately, see below
    server_jvm_min_heap_size      => $server_jvm_min_heap_size,
    server_jvm_max_heap_size      => $server_jvm_max_heap_size,
    puppetmaster                  => $::bsl_puppet::server_certname,
    server_certname               => $::bsl_puppet::server_certname,
    dns_alt_names                 => $::bsl_puppet::server_alt_dns_names,
    environment                   => $::bsl_puppet::environment,
    manage_packages               => false,
    server_reports                => 'store,puppetdb',
    server_storeconfigs_backend   => 'puppetdb',
    main_template                 => 'bsl_puppet/puppet.conf.erb',
    agent_template                => 'bsl_puppet/agent/puppet.conf.erb',
    server_template               => 'bsl_puppet/server/puppet.conf.erb',
    #auth_template                 => 'bsl_puppet/auth.conf.erb',
    #nsauth_template               => 'bsl_puppet/namespaceauth.conf.erb'
  }
  ->
  file { "${::puppet::server_dir}/ssh":
    ensure => directory,
    owner  => $::puppet::server_user,
    group  => $::puppet::server_group,
    mode   => '0700',
  }

  exec { 'generate puppetserver cert':
    command   => "puppet cert generate ${::bsl_puppet::server_certname}",
    creates   => "${::puppet::server_ssl_dir}/certs/${::bsl_puppet::server_certname}.pem",
    path      => '/opt/puppetmaster/bin:/usr/bin:/bin',
    notify    => [ Service['puppetserver'], Service['puppet'] ],
    logoutput => true,
  }

  if $use_foreman {
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

  ## Hiera
  file { $hiera_config_path:
    ensure  => file,
    content => template('bsl_puppet/server/hiera.yaml.erb')
  }
}