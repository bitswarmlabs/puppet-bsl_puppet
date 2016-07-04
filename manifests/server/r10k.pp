class bsl_puppet::server::r10k {
  assert_private("bsl_puppet::server::r10k is a private class")

  include 'bsl_puppet::config'

  anchor { 'bsl_puppet::server::r10k::begin': }->
  notify { '## hello from bsl_puppet::server::r10k': message => $bsl_puppet::config::r10k_sources }


  if !empty($bsl_puppet::config::r10k_sources) {
    $r10k_sources = $bsl_puppet::config::r10k_sources.map|$key, $value| {
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
  else {
    $r10k_sources = []
  }


  if !empty($r10k_sources) {
    class { '::r10k':
      manage_modulepath         => false,
      cachedir                  => $bsl_puppet::config::r10k_cache_dir,
      configfile                => $bsl_puppet::config::r10k_config_file,
      manage_configfile_symlink => false,
      sources                   => hash($r10k_sources),
      postrun                   => $bsl_puppet::config::r10k_postrun,
      provider                  => 'puppet_gem',
      require                   => Class['bsl_puppet::server'],
      notify                    => File['/etc/r10k.yaml'],
    }
  }

  file { '/etc/r10k.yaml': ensure => absent }

  # r10k module bug workaround, r10k symlink not being properly created due to broken puppet version fact
  if ! defined(File['/usr/bin/r10k']) {
    exec { 'r10k gem install':
      command => '/opt/puppetlabs/puppet/bin/gem install r10k',
      creates => '/opt/puppetlabs/puppet/bin/r10k',
      path    => '/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin:/usr/bin:/bin',
      notify  => Anchor['bsl_puppet::server::r10k::end'],
    }
    ->
    file { '/usr/bin/r10k':
      ensure  => link,
      target  => '/opt/puppetlabs/puppet/bin/r10k',
      force   => true,
    }
  }

  exec { 'r10k version':
    command   => 'r10k version',
    logoutput => true,
    path      => '/usr/bin:/bin',
    require   => File['/usr/bin/r10k']
  }

  if !empty($bsl_puppet::config::r10k_sources) {
    $defaults = {
      'manage_webhook' => $bsl_puppet::config::manage_r10k_webhooks,
      'notify' => Anchor['bsl_puppet::server::r10k::end'],
    }

    create_resources('bsl_puppet::server::r10k::source', $bsl_puppet::config::r10k_sources, $defaults)
  }

  anchor { 'bsl_puppet::server::r10k::end': }
}
