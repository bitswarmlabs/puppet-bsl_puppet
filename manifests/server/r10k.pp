class bsl_puppet::server::r10k(
  $sources = undef,
  $webhooks_enabled = 'false',
  $webhook_user = 'puppet',
  $webhook_pass = 'changeme',
  $github_api_token = $bsl_puppet::server::r10k::params::github_api_token,
  $use_mcollective = 'false',
) inherits bsl_puppet::server::r10k::params {
  if !empty($sources) {
    validate_hash($sources)
    $r10k_sources = $sources.map|$key, $value| {
        if str2bool($value[manage_deploy_key]) {
          [$key, {
            basedir => $value[basedir],
            remote  => inline_template('git@<%= @value["project"].gsub(/(\/|\_)/, "-") %>.<%= @value["provider"] %>:<%= @value["project"] %>.git'),
            prefix  => str2bool($value[prefix]),
          }]
        }
        else {
          [$key, {
            basedir => $value[basedir],
            remote  => $value[remote],
            prefix  => str2bool($value[prefix]),
          }]
        }
      }
  }

  Class['bsl_puppet::server']
  ->
  class { '::r10k':
    provider => 'puppet_gem',
    sources  => hash($r10k_sources),
  }

  # r10k module bug workaround, r10k symlink not being properly created due to broken puppet version fact
  if ! defined(File['/usr/bin/r10k']) {
    exec { 'r10k gem install':
      command => '/opt/puppetlabs/puppet/bin/gem install r10k',
      creates => '/opt/puppetlabs/puppet/bin/r10k',
      path    => '/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/bin:/bin'
    }
    ->
    file { '/usr/bin/r10k':
      ensure  => link,
      target  => '/opt/puppetlabs/puppet/bin/r10k',
      require => Package['r10k'],
      force   => true,
    }
  }

  exec { 'r10k version':
    command   => 'r10k version',
    logoutput => true,
    path      => '/usr/bin:/bin',
    require   => File['/usr/bin/r10k']
  }

  # ->
  # file { "${::r10k::cachedir}":
  #   ensure => directory,
  #   owner  => $::puppet::server_user,
  #   group  => $::puppet::server_group,
  # }

  # if ! defined(Class['r10k::install::puppet_gem']) {
  #   file { '/usr/bin/r10k':
  #     ensure => link,
  #     target => '/opt/puppetlabs/puppet/bin/r10k',
  #     force  => true,
  #     require => Class['r10k'],
  #   }
  # }

  if !empty($sources) {
    $defaults = {
      'manage_webhook'   => $webhooks_enabled,
    }

    create_resources('bsl_puppet::server::r10k::source', $sources, $defaults)

    # file { '/root/.ssh/config':
    #   content => template('bsl_puppet/server/root-ssh-config.erb'),
    #   mode    => '0600',
    # }
  }
}
