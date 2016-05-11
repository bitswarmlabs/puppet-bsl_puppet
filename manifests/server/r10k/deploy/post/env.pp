define bsl_puppet::server::r10k::deploy::post::env {
  ::puppet::server::env { $name:
    modulepath => [$::bsl_puppet::server::server_core_modules_path, "${::puppet::server_envs_dir}/${name}/modules", $::puppet::server_common_modules_path],
  }
}