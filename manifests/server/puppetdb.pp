class bsl_puppet::server::puppetdb(
  $puppetdb_host = $::bsl_puppet::server::params::puppetdb_host,
  $validate_puppetdb_connection = 'true',
  $puppetdb_soft_write_failure = 'false',
  $database_host = 'localhost',
  $database_port = '5432',
  $database_name = 'puppetdb',
  $database_username = 'puppetdb',
  $database_password = 'puppetdb'
) inherits bsl_puppet::server::params {
  class { '::puppetdb':
    database_host       => $database_host,
    database_port       => $database_port,
    database_name       => $database_name,
    database_username   => $database_username,
    database_password   => $database_password,
  }

  class { '::puppetdb::master::config':
    puppetdb_server             => $puppetdb_host,
    puppetdb_soft_write_failure => str2bool($puppetdb_soft_write_failure),
    strict_validation           => str2bool($validate_puppetdb_connection),
    manage_storeconfigs         => false, # this is managed by ::puppet::server::config
  }
  ~>
  Service['puppetserver']

  exec { 'puppetdb-ssl-setup':
    command     => 'puppetdb ssl-setup -f',
    path        => '/opt/puppetmaster/bin:/usr/bin:/bin',
    logoutput   => true,
    refreshonly => true,
  }

  Class['::puppet::config']~>Exec['puppetdb-ssl-setup']~>Service['puppetdb']
}
