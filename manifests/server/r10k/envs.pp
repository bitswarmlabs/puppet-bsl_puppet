class bsl_puppet::server::r10k::envs {
  assert_private("bsl_puppet::server::r10k::envs is a private class")

  bsl_puppet::server::r10k::deploy::post::env { $::puppet::server_environments: }
}
