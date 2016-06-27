class bsl_puppet::server::facter {
  notify { '## hello from bsl_puppet::server::facter': }

  file { ['/etc/facter', '/opt/puppetlabs/facter', '/etc/puppetlabs/facter']:
    ensure => directory,
  }
  ->
  file { ['/etc/facter/facts.d', '/opt/puppetlabs/facter/facts.d', '/etc/puppetlabs/facter/facts.d']:
    ensure => directory,
  }

  file { '/opt/puppetlabs/facter/facts.d/bitswarmlabs.yaml':
    ensure => file,
    content => template("bsl_puppet/bitswarmlabs-facts.yaml.erb"),
    require => File['/opt/puppetlabs/facter/facts.d']
  }
}
