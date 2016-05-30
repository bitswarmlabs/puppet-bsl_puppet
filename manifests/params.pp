class bsl_puppet::params {
  $puppetmaster = hiera('puppetmaster', 'puppet')

  $environment = $::aws_tag_environment ? {
    /.+/ => $::aws_tag_environment,
    default => 'production',
  }

  $server_certname = 'puppet'

  $server_alt_dns_names = []

  $server_puppetdb_host = 'puppet'

  $external_fqdn = $::fqdn
}
