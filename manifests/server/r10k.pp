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

  Class['::bsl_puppet::server']
  ->
  class { '::r10k':
    provider               => 'puppet_gem',
    sources                => hash($r10k_sources),
  }

  if !empty($sources) {
    validate_hash($sources)
    create_resources('bsl_puppet::server::r10k::source', $sources)

    # file { '/root/.ssh/config':
    #   content => template('bsl_puppet/server/root-ssh-config.erb'),
    #   mode    => '0600',
    # }
  }

  sshkey { 'github.com':
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==',
    target => '/etc/ssh/ssh_known_hosts',
    type   => 'ssh-rsa',
  }
}
