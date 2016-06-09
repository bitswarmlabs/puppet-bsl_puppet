class bsl_puppet::server::r10k::params {
  $github_api_token = hiera('github_api_token', false)
  $cache_dir = "${bsl_puppet::server::puppet_home}/r10k"
}
