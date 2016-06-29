class bsl_puppet::server::hostname(
  $hostname      = $bsl_puppet::server::params::hostname,
  $domain        = $bsl_puppet::server::params::domain,
  $dns_alt_names = [],
  $reloads       = $bsl_puppet::server::params::reloads,
) inherits bsl_puppet::server::params {
  assert_private("bsl_puppet::server::hostname is a private class")

  notify { '## hello from bsl_puppet::server::hostname': }

  include 'bsl_puppet::config'

  $set_dns_alt_names = concat($dns_alt_names, $bsl_puppet::config::server_dns_alt_names)
  $unique_dns_alts = unique($set_dns_alt_names)

  # Generate hostname
  if empty($domain) {
    # No domain provided, won't be a FQDN
    $set_fqdn = $hostname
  }
  else {
    $set_fqdn = "${hostname}.${domain}"
  }

  # Write hostname to config
  anchor { 'bsl_puppet::server::hostname::begin': }
  ->
  file { "/etc/hostname":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "$set_fqdn\n",
    notify  => Exec["bsl_apply_hostname"],
  }
  ->

  # Set the hostname
  exec { "bsl_apply_hostname":
    command => "/bin/hostname -F /etc/hostname",
    unless  => "/usr/bin/test `hostname` = `/bin/cat /etc/hostname`",
  }
  ->
  Anchor['bsl_puppet::server::hostname::end']

  # Make sure the hosts file has an entry
  host { 'default hostname v4':
    ensure        => present,
    name          => $bsl_puppet::config::server_certname,
    host_aliases  => delete($unique_dns_alts, $bsl_puppet::config::server_certname),
    ip            => '127.0.0.1',
  }

  # TODO: This won't work yet thanks to an ancient puppet bug:
  # https://projects.puppetlabs.com/issues/8940
  #  host { 'default hostname v6':
  #    ensure       => present,
  #    name         => $set_fqdn,
  #    host_aliases => $hostname,
  #    ip           => '::1',
  #  }

  anchor { 'bsl_puppet::server::hostname::end': }

  # Optional Reloads. We iterate over the array and then for each provided
  # service, we setup a notification relationship with the change hostname
  # command.
  #
  # Note we use a old style interation (pre future parser) to ensure
  # compatibility with Puppet 3 systems. In future when 4.x+ is standard we
  # could rewite with a newer loop approach as per:
  # https://docs.puppetlabs.com/puppet/latest/reference/lang_iteration.html

  bsl_puppet::server::hostname::reloads { $reloads: }
}

define bsl_puppet::server::hostname::reloads ($service = $title) {
  Exec['bsl_apply_hostname'] ~> Service[$service]
}
