class bsl_puppet::server::r10k::webhook(
  $callback_fqdn = $bsl_puppet::config::r10k_webhook_callback_fqdn,
  $callback_port = $bsl_puppet::config::r10k_webhook_callback_port,
  $enable_ssl = 'false',
) {
  assert_private("bsl_puppet::server::r10k::webhook is a private class")

  anchor { 'bsl_puppet::server::r10k::webhook::begin': }->
  notify { '## hello from bsl_puppet::server::r10k::webhook': }

  include 'bsl_puppet::server::r10k'

  if str2bool($bsl_puppet::config::r10k_use_mcollective) {
    include '::r10k::mcollective'
    Class['::r10k::mcollective']->Class['::r10k::webhook']
  }

  Anchor['bsl_puppet::server::r10k::webhook::begin']->
  class { '::r10k::webhook::config':
    enable_ssl       => str2bool($bsl_puppet::config::r10k_webhook_enable_ssl),
    # certname         => '',
    # certpath         => '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem',
    # public_key_path  => '/etc/puppetlabs/puppet/ssl/ca/ca_pub.pem',
    # private_key_path => '/etc/puppetlabs/puppet/ssl/ca/ca_key.pem',
    protected        => true,
    use_mcollective  => str2bool($bsl_puppet::config::r10k_se_mcollective),
    user             => $bsl_puppet::config::r10k_webhook_user,
    pass             => $bsl_puppet::config::r10k_webhook_pass,
    notify           => Service['webhook'],
  }
  ->
  class { '::r10k::webhook':
    use_mcollective => str2bool($bsl_puppet::config::r10k_use_mcollective),
    user            => 'root',
    group           => '0',
  }
  ~>Anchor['bsl_puppet::server::r10k::webhook::end']

  $webhook_proto = str2bool($bsl_puppet::config::r10k_webhook_enable_ssl) ? {
    true  => 'https',
    false => 'http',
  }

  $webhook_base_url = "${webhook_proto}://${bsl_puppet::config::r10k_webhook_user}:${bsl_puppet::config::r10k_webhook_pass}@${bsl_puppet::config::r10k_webhook_callback_fqdn}:${bsl_puppet::config::r10k_webhook_callback_port}/"

  notify { "## r10k webhook base_url: ${webhook_base_url}": }->
  anchor { 'bsl_puppet::server::r10k::webhook::end': }
}
