class bsl_puppet::server::puppetdb {
  assert_private('bsl_puppet::server::puppetdb is a private class')

  anchor { 'bsl_puppet::server::puppetdb::begin': }

  include 'bsl_puppet::config'

  class { '::puppetdb::master::config':
    puppetdb_server             => $bsl_puppet::config::puppetdb_host,
    puppetdb_soft_write_failure => str2bool($bsl_puppet::config::puppetdb_soft_write_failure),
    strict_validation           => str2bool($bsl_puppet::config::puppetdb_validate_connection),
    manage_storeconfigs         => false, # this is managed by ::puppet::server::config
  }
  ~>
  Service['puppetserver']

  if $bsl_puppet::config::manage_postgresql {
    class { '::postgresql::server': before => Class['::puppetdb'] }
  }

  class { '::puppetdb':
    database            => $bsl_puppet::config::puppetdb_database_type,
    database_host       => $bsl_puppet::config::puppetdb_database_host,
    database_port       => $bsl_puppet::config::puppetdb_database_port,
    database_name       => $bsl_puppet::config::puppetdb_database_name,
    database_username   => $bsl_puppet::config::puppetdb_database_user,
    database_password   => $bsl_puppet::config::puppetdb_database_pass,
  }
  ~> Anchor['bsl_puppet::server::puppetdb::end']

  exec { 'puppetdb-ssl-setup':
    command     => 'puppetdb ssl-setup -f',
    path        => '/opt/puppetmaster/bin:/usr/bin:/bin',
    logoutput   => true,
    refreshonly => true,
  }
  ~> Service['puppetdb']
  -> anchor { 'bsl_puppet::server::puppetdb::end': }


}
