define bsl_puppet::server::r10k::deploy::post::env {
  assert_private("bsl_puppet::server::r10k::deploy::post::env is a private class")

  include 'bsl_puppet::config'

  ::puppet::server::env { $name:
    modulepath => [
      $bsl_puppet::config::server_core_modules_path,
      "${::puppet::server_envs_dir}/${name}/modules",
      $::puppet::server_common_modules_path],
  }
}
