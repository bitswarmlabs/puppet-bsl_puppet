class bsl_puppet::server::puppetboard {
  assert_private("bsl_puppet::server::puppetboard is a private class")

  include 'bsl_puppet::config'

  if $bsl_puppet::config::puppetboard_manage_apache_via == 'declare' {
    class { '::apache':
      default_vhost   => false,
      purge_vhost_dir => true
    }

    class { '::apache::mod::wsgi': }
  }
  elsif $bsl_puppet::config::puppetboard_manage_apache_via == 'include' {
    include '::apache'
    include '::apache::mod::wsgi'
  }

  class { '::puppetboard':
    puppetdb_host => $bsl_puppet::config::puppetdb_host,
  }

  class { '::puppetboard::apache::vhost':
    vhost_name =>  $bsl_puppet::config::puppetboard_fqdn,
    port       => $bsl_puppet::config::puppetboard_port,
  }

  Apache::Vhost <| docroot == "$::puppetboard::apache::vhost::docroot" |> {
    directories => [
      {
        path                => "$::puppetboard::apache::vhost::docroot",
        auth_type           => 'basic',
        auth_name           => 'puppetboard',
        auth_user_file      => "${::puppetboard::apache::vhost::basedir}/htpasswd",
        auth_require        => 'valid-user',
        auth_basic_provider => file,
      }
    ],
  }

  httpauth {  $bsl_puppet::config::puppetboard_user:
    file      =>  "${::puppetboard::apache::vhost::basedir}/htpasswd",
    password  => $bsl_puppet::config::puppetboard_pass,
    realm     => 'puppetboard',
    mechanism => basic,
    ensure    => present,
    notify    => Service['apache'],
  }
  ->
  file { "${::puppetboard::apache::vhost::basedir}/htpasswd":
    owner => $::apache::user,
  }
}
