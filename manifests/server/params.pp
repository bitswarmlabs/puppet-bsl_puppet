class bsl_puppet::server::params {
  include 'bsl_puppet::config'

  $certname = $bsl_puppet::config::server_certname

  # Define the hostnamr (without domain) to be used.
  $hostname = $bsl_puppet::config::server_hostname

  # Define the domain to be used
  $domain = $bsl_puppet::config::server_domain

  # Array of Puppet service names to be reloaded after hostname change.
  # Generally you will need to at least restart syslog (or variant).
  $reloads = ['puppetserver']
}
