class bsl_puppet::server::hostname(
  $hostname = $::hostname,
  $domain = $::domain,
) {
  assert_private("bsl_puppet::server::hostname is a private class")

  notify { '## hello from bsl_puppet::server::hostname': }

  include 'bsl_puppet::config'

  $set_fqdn = "${hostname}.${domain}"

  if $set_fqdn != $::fqdn {
    notify { "## bsl_puppet::server::hostname changing hostname to ${set_fqdn}": }
    class { '::hostname':
      hostname => $hostname,
      domain   => $domain,
    }
  }
  else {
    notify { "## bsl_puppet::server::hostname not changing hostname to ${set_fqdn} (fqdn=${::fqdn}": }
  }
}
