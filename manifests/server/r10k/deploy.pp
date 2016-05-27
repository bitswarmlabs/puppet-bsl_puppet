class bsl_puppet::server::r10k::deploy {
  anchor { 'bsl_puppet::server::r10k::deploy::begin': }
  ->
  Class['bsl_puppet::server::ssh_keys']
  ->
  Class['::r10k::install']
  ~>
  exec { 'r10k deploy':
    command   => 'r10k deploy environment -v -p',
    path      => '/opt/puppetlabs/puppet/bin:/usr/local/bin:/usr/bin:/bin',
    # environment => [ "HOME='/opt/puppetlabs/puppet'" ],
    # user      => $::puppet::server_user,
    logoutput => true,
  }
  ~>
  class { 'bsl_puppet::server::r10k::deploy::post':

  }
  ~>anchor { 'bsl_puppet::server::r10k::deploy::end': }

  Bsl_puppet::Server::R10k::Source <| |> {
    before => Exec['r10k deploy']
  }
}
