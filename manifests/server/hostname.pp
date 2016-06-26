class bsl_puppet::server::hostname(
  $hostname = $::hostname,
  $domain = $::domain,
) {
  $fqdn = "${hostname}.${domain}"

  class { '::hostname':
    hostname => $hostname,
    domain   => $domain,
  }
}
