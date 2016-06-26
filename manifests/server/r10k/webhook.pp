class bsl_puppet::server::r10k::webhook(
  $callback_fqdn = $bsl_puppet::server::r10k::params::webhook_callback_fqdn,
  $callback_port = $bsl_puppet::server::r10k::params::webhook_callback_port,
  $enable_ssl = 'false',
) {
  include 'bsl_puppet::server::r10k'

  if str2bool($bsl_puppet::server::r10k::use_mcollective) {
    include '::r10k::mcollective'
  }

  class { '::r10k::webhook::config':
    enable_ssl       => str2bool($enable_ssl),
    # certname         => '',
    # certpath         => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
    # public_key_path  => '/etc/puppetlabs/puppet/ssl/ca/ca_pub.pem',
    # private_key_path => '/etc/puppetlabs/puppet/ssl/ca/ca_key.pem',
    protected        => true,
    use_mcollective  => str2bool($bsl_puppet::server::r10k::use_mcollective),
    user             => $bsl_puppet::server::r10k::webhook_user,
    pass             => $bsl_puppet::server::r10k::webhook_pass,
    notify           => Service['webhook'],
  }
  ->
  class { '::r10k::webhook':
    use_mcollective => str2bool($bsl_puppet::server::r10k::use_mcollective),
    user            => 'root',
    group           => '0',
  }

  $webhook_proto = str2bool($enable_ssl) ? {
    true  => 'https',
    false => 'http',
  }

  $webhook_base_url = "${webhook_proto}://${bsl_puppet::server::r10k::webhook_user}:${bsl_puppet::server::r10k::webhook_pass}@${callback_fqdn}:${callback_port}/"

  notify { "## r10k webhook base_url: ${webhook_base_url}": }
}
