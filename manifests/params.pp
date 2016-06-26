class bsl_puppet::params {
  $puppetmaster = hiera('puppetmaster', 'puppet')

  $environment = $::ec2_tag_environment ? {
    /.+/ => $::ec2_tag_environment,
    default => 'production',
  }
}
