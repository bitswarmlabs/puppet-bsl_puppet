class bsl_puppet::server::r10k::deploy::post {
  file { $::puppet::sharedir:
    ensure => directory,
  }

  file { $::puppet::server_common_modules_path:
    ensure => directory,
    owner  => $::puppet::server_environments_owner,
    group  => $::puppet::server_environments_group,
    mode   => $::puppet::server_environments_mode,
  }

  # make sure your site.pp exists (puppet #15106, foreman #1708) and server_manifest_path too
  file { $::puppet::server_manifest_path:
    ensure => directory,
    owner  => $puppet::server_user,
    group  => $puppet::server_group,
    mode   => '0755',
  }

  file { "${::puppet::server_manifest_path}/site.pp":
    ensure  => file,
    replace => false,
    content => "# site.pp must exist (puppet #15106, foreman #1708)\n",
    mode    => '0644',
  }

  anchor { 'bsl_puppet::server::r10k::deploy::post_start': }
  ->
  bsl_puppet::server::r10k::deploy::post::env { $::puppet::server_environments: }
  ->anchor { 'bsl_puppet::server::r10k::deploy::post_end': }
}