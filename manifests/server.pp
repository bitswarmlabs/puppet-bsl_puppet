class bsl_puppet::server(
  $certname = undef,
  $dns_alt_names = []
) inherits bsl_puppet::server::params {
  include 'bsl_puppet::config'

  if $certname {
    $server_certname = $certname
    $client_certname = $certname
  }
  else {
    $server_certname = $bsl_puppet::config::server_certname
    $client_certname = $bsl_puppet::config::agent_certname
  }

  anchor { 'bsl_puppet::server::start': } ->
  notify { '## hello from bsl_puppet::server': message => "server_certname: ${server_certname} client_certname: ${client_certname}" }

  $set_dns_alt_names = concat($dns_alt_names, $bsl_puppet::config::server_dns_alt_names)
  $unique_dns_alts = unique($set_dns_alt_names)

  $manage_packages = str2bool($bsl_puppet::config::manage_packages) ? {
    true    => 'server',
    default => undef,
  }

  if str2bool($bsl_puppet::config::manage_puppetdb) {
    if str2bool($bsl_puppet::config::foreman) {
      $server_reports = 'store,foreman,puppetdb'
      $server_storeconfigs_backend = 'puppetdb'
    }
    else {
      $server_reports = 'store,puppetdb'
      $server_storeconfigs_backend = 'puppetdb'
    }
  }
  elsif str2bool($bsl_puppet::config::foreman) {
    $server_reports = 'foreman'
    $server_storeconfigs_backend = undef
  }
  else {
    $server_reports = 'store'
    $server_storeconfigs_backend = false
  }

  if str2bool($bsl_puppet::config::foreman) {
    Anchor['bsl_puppet::server::start'] ->
    class { '::puppet':
      agent                         => str2bool($bsl_puppet::config::agent),
      server                        => true,
      puppetmaster                  => $bsl_puppet::config::puppetmaster_fqdn,
      client_certname               => $client_certname,
      server_certname               => $server_certname,
      dns_alt_names                 => $unique_dns_alts,
      server_implementation         => 'puppetserver',
      server_directory_environments => true,
      server_dynamic_environments   => true, # since its managed by r10k
      server_common_modules_path    => $bsl_puppet::config::server_common_modules_path,
      server_foreman                => true,
      server_jvm_min_heap_size      => $bsl_puppet::config::server_jvm_min_heap_size,
      server_jvm_max_heap_size      => $bsl_puppet::config::server_jvm_max_heap_size,
      server_reports                => $server_reports,
      server_storeconfigs_backend   => $server_storeconfigs_backend,
      hiera_config                  => $bsl_puppet::config::hiera_config_path,
      environment                   => $bsl_puppet::config::server_environment,
      manage_packages               => $manage_packages,
      # main_template                 => 'bsl_puppet/puppet.conf.erb',
      # agent_template                => 'bsl_puppet/agent/puppet.conf.erb',
      # server_template               => 'bsl_puppet/server/puppet.conf.erb',
      # auth_template                 => 'bsl_puppet/auth.conf.erb',
      # nsauth_template               => 'bsl_puppet/namespaceauth.conf.erb'
    }
    ->
    class { '::foreman':
      admin_username => $bsl_puppet::config::foreman_user,
      admin_password => $bsl_puppet::config::foreman_password,
    }
  }
  else {
    Anchor['bsl_puppet::server::start'] ->
    class { '::puppet':
      agent                         => str2bool($bsl_puppet::config::agent),
      server                        => true,
      puppetmaster                  => $bsl_puppet::config::puppetmaster_fqdn,
      client_certname               => $client_certname,
      server_certname               => $server_certname,
      dns_alt_names                 => $unique_dns_alts,
      server_implementation         => 'puppetserver',
      server_directory_environments => true,
      server_dynamic_environments   => true, # since its managed by r10k
      server_common_modules_path    => $bsl_puppet::config::server_common_modules_path,
      server_foreman                => false,
      server_external_nodes         => $bsl_puppet::config::server_external_nodes,
      server_jvm_min_heap_size      => $bsl_puppet::config::server_jvm_min_heap_size,
      server_jvm_max_heap_size      => $bsl_puppet::config::server_jvm_max_heap_size,
      server_reports                => $server_reports,
      server_storeconfigs_backend   => $server_storeconfigs_backend,
      hiera_config                  => $bsl_puppet::config::hiera_config_path,
      environment                   => $bsl_puppet::config::server_environment,
      manage_packages               => $manage_packages,
      # main_template                 => 'bsl_puppet/puppet.conf.erb',
      # agent_template                => 'bsl_puppet/agent/puppet.conf.erb',
      # server_template               => 'bsl_puppet/server/puppet.conf.erb',
      # auth_template                 => 'bsl_puppet/auth.conf.erb',
      # nsauth_template               => 'bsl_puppet/namespaceauth.conf.erb'
    }
  }

  file { "${::puppet::dir}/puppet.conf":
    ensure => file,
    notify => [ Service['puppet'], Service['puppetserver'] ],
  }

  $autosigns = $::bsl_puppet::config::server_autosigns
  notify { "autosigns": message => inline_template('<%= @autosigns.join("\n") %>') }

  File <| title == "${::puppet::autosign}" |> {
    content => inline_template('<%= @autosigns.join("\n") %>'),
    notify  => Service['puppetserver'],
  }

  anchor { 'bsl_puppet::server::end': }
}
