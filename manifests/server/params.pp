class bsl_puppet::server::params {
  $certname = $::clientcert

  # Define the hostnamr (without domain) to be used.
  $hostname = $::hostname

  # Define the domain to be used
  $domain = undef

  # Array of Puppet service names to be reloaded after hostname change.
  # Generally you will need to at least restart syslog (or variant).
  $reloads = ['puppetserver']
}
