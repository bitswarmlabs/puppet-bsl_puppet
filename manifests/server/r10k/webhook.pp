class bsl_puppet::server::r10k::webhook {
  include '::r10k::webhook'

  class { '::r10k::webhook::config':
    enable_ssl      => false,
    protected       => true,
    use_mcollective => $use_mcollective,
    user            => $webhook_user,
    pass            => $webhook_pass,
    notify          => Service['webhook'],
  }
}