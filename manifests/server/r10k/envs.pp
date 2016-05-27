class bsl_puppet::server::r10k::envs {
  bsl_puppet::server::r10k::deploy::post::env { $::puppet::server_environments: }
}
