class bsl_puppet::server::r10k::cleanup {
  assert_private("bsl_puppet::server::r10k::cleanup is a private class")

  # A workaround for some modules not have proper permissions on .rb files
  exec { 'puppet codedir environment perm fix':
    command   => "find ${::puppet::codedir} -type f -name '*.rb' ! -path '**/.git/**' -exec chmod -c ugo+r {} \\;",
    path      => '/usr/bin:/bin',
    logoutput => true,
  }
}
