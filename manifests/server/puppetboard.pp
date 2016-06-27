class bsl_puppet::server::puppetboard(
  $admin_user = 'admin',
  $admin_pass = 'admin',
  $www_hostname = 'puppet',
)  {
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
    puppetdb_host => 'puppet',
  }

  class { '::puppetboard::apache::vhost':
    vhost_name => $www_hostname,
    port       => 80,
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

  httpauth { "${admin_user}":
    file      =>  "${::puppetboard::apache::vhost::basedir}/htpasswd",
    password  => "${admin_pass}",
    realm     => 'puppetboard',
    mechanism => basic,
    ensure    => present,
  }
  ->
  file { "${::puppetboard::apache::vhost::basedir}/htpasswd":
    owner => $::apache::user,
  }
}
