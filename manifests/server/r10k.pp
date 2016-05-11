class bsl_puppet::server::r10k(
  $sources = undef,
  $webhook_user = 'puppet',
  $webhook_pass = 'changeme',
  $github_api_token = $bsl_puppet::server::r10k::params::github_api_token,
  $use_mcollective = false,
) inherits bsl_puppet::server::r10k::params {
  $r10k_sources = $sources.map|$key, $value| {
    if str2bool($value[manage_deploy_key]) {
      [$key, {
        basedir => $value[basedir],
        remote  => inline_template('git@<%= @value["project"].gsub(/(\/|\_)/, "-") %>.<%= @value["provider"] %>:<%= @value["project"] %>.git'),
        prefix => str2bool($value[prefix]),
      }]
    }
    else {
      [$key, {
        basedir => $value[basedir],
        remote => $value[remote],
        prefix => str2bool($value[prefix]),
      }]
    }
  }

  Class['bsl_puppet::server']
  ->
  class { '::r10k':
    provider               => 'puppet_gem',
    sources                => hash($r10k_sources),
  }
  ->
  file { "${::r10k::cachedir}":
    ensure => directory,
    owner  => $::puppet::server_user,
    group  => $::puppet::server_group,
  }


  if !empty($sources) {
    validate_hash($sources)
    create_resources('bsl_puppet::server::r10k::source', $sources)

    # file { '/root/.ssh/config':
    #   content => template('bsl_puppet/server/root-ssh-config.erb'),
    #   mode    => '0600',
    # }
  }
}
