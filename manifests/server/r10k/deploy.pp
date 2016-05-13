class bsl_puppet::server::r10k::deploy {
  Class['bsl_puppet::server::ssh_keys']
  ->
  Class['::r10k::install']
  ~>
  exec { 'r10k deploy':
    command   => 'r10k deploy environment --verbose',
    path      => '/opt/puppetlabs/puppet/bin:/usr/local/bin:/usr/bin:/bin',
    # environment => [ "HOME='/opt/puppetlabs/puppet'" ],
    # user      => $::puppet::server_user,
    logoutput => true,
  }
  ~>
  class { 'bsl_puppet::server::r10k::deploy::post':

  }

  Bsl_puppet::Server::R10k::Source <| |> {
    before => Exec['r10k deploy']
  }
}