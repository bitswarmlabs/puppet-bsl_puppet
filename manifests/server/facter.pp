class bsl_puppet::server::facter() {
  notify { '## hello from bsl_puppet::server::facter': }

  include 'bsl_puppet::config'

  file { ['/etc/facter', '/opt/puppetlabs/facter', '/etc/puppetlabs/facter']:
    ensure => directory,
  }
  ->
  file { ['/etc/facter/facts.d', '/opt/puppetlabs/facter/facts.d', '/etc/puppetlabs/facter/facts.d']:
    ensure => directory,
  }

  $app_project = $bsl_puppet::config::app_project
  $app_environment = $bsl_puppet::config::app_environment

  file { '/etc/facter/facts.d/bitswarmlabs.yaml':
    ensure => file,
    content => template("bsl_puppet/bitswarmlabs-facts.yaml.erb"),
    require => File['/etc/facter/facts.d']
  }
}
