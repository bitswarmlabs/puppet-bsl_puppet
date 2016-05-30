class bsl_puppet::server::r10k::webhook {
  include 'bsl_puppet::server::r10k'

  class { '::r10k::webhook::config':
    enable_ssl      => true,
    protected       => true,
    use_mcollective => str2bool($bsl_puppet::server::r10k::use_mcollective),
    user            => $bsl_puppet::server::r10k::webhook_user,
    pass            => $bsl_puppet::server::r10k::webhook_pass,
    notify     => Service['webhook'],
  }
  ->
  class { '::r10k::webhook':
    use_mcollective => str2bool($bsl_puppet::server::r10k::use_mcollective),
    user            => 'root',
    group           => '0',
  }
}