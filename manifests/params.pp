class bsl_puppet::params {
  $puppetmaster = hiera('puppetmaster', 'puppet')

  $environment = $::aws_tag_environment ? {
    /.+/ => $::aws_tag_environment,
    default => 'production',
  }

  $server_certname = $::fqdn

  $server_alt_dns_names = [ 'puppet' ]

  $server_puppetdb_host = $::fqdn

  $external_fqdn = $::fqdn
}
