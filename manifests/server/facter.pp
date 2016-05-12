class bsl_puppet::server::facter {
  file { ['/etc/facter', '/opt/puppetlabs/facter', '/etc/puppetlabs/facter']:
    ensure => directory,
  }
  ->
  file { ['/etc/facter/facts.d/', '/opt/puppetlabs/facter/facts.d', '/etc/puppetlabs/facter/facts.d']:
    ensure => directory,
  }
}