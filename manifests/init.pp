class bsl_puppet(
  $puppetmaster,
  $environment = $bsl_puppet::params::environment,
  $server_certname = $bsl_puppet::params::server_certname,
  $server_alt_dns_names = $bsl_puppet::params::server_alt_dns_names,
  $server_puppetdb_host = $bsl_puppet::params::server_puppetdb_host,
) inherits bsl_puppet::params {

}
