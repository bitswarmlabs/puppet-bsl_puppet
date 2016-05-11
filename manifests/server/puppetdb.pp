class bsl_puppet::server::puppetdb(
  $puppetdb_host = $::bsl_puppet::server_puppetdb_host,
  $puppetdb_soft_write_failure = true,
  $postgresql_backend = 'localhost',
  $postgresql_user = '',
  $postgresql_pass = '',
) {
  if $puppetdb_host != undef and !defined(Host[$puppetdb_host]) {
    host { $puppetdb_host:
      ip     => '127.0.0.1',
      before => [Class['::puppetdb'], Class['::puppetdb::master::config']],
    }
  }

  class { '::puppetdb':
    # disable_ssl => true,
  }

  class { '::puppetdb::master::config':
    puppetdb_server             => $puppetdb_host,
    puppetdb_soft_write_failure => $puppetdb_soft_write_failure,
    manage_storeconfigs         => false, # this is managed by ::puppet::server::config
    # strict_validation           => false,
  }
  ~>
  Service['puppetserver']

  exec { 'puppetdb-ssl-setup':
    command     => 'puppetdb ssl-setup -f',
    refreshonly => true,
    path        => '/opt/puppetmaster/bin:/usr/bin:/bin',
    # creates => '/etc/puppetlabs/puppetdb/ssl/ca.pem',
    logoutput   => true,
  }

  Class['::puppet::config']->Exec['generate puppetserver cert']~>Exec['puppetdb-ssl-setup']~>Service['puppetdb']
}