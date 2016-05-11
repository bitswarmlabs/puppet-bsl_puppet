class bsl_puppet::server::r10k::deploy {
  include 'bsl_puppet::server::r10k'

  file { "${::r10k::cachedir}":
    ensure => directory,
    owner  => $::puppet::server_user,
    group  => $::puppet::server_group,
  }
  ->
  exec { 'r10k deploy':
    command   => 'r10k deploy environment',
    path      => '/opt/puppetlabs/puppet/bin:/usr/local/bin:/usr/bin:/bin',
    # environment => [ "HOME='/opt/puppetlabs/puppet'" ],
    # user      => $::puppet::server_user,
    logoutput => true,
  }
  ~>
  class { 'bsl_puppet::server::r10k::deploy::post':

  }
}