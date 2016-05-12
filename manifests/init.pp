# Class: bsl_puppet
# ===========================
#
# Full description of class bsl_puppet here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'bsl_puppet':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Reuben Avery <ravery@bitswarm.io>
#
# Copyright
# ---------
#
# Copyright 2016 Bitswarm Labs
#
class bsl_puppet(
  $puppetmaster,
  $environment = $bsl_puppet::params::environment,
  $server_certname = $bsl_puppet::params::server_certname,
  $server_alt_dns_names = $bsl_puppet::params::server_alt_dns_names,
  $server_puppetdb_host = $bsl_puppet::params::server_puppetdb_host,
) inherits bsl_puppet::params {
}
