include 'apt'

apt::key { 'phusionpassanger':
  key => '561F9B9CAC40B2F7',
}

apt::source { 'phusionpassenger':
  location => 'https://oss-binaries.phusionpassenger.com/apt/passenger',
  repos    => 'main',
}

package {'apt-transport-https':
  ensure  =>  latest,
}

package {'ca-certificates':
  ensure  =>  latest,
}

package {'libapache2-mod-passenger':
  ensure  =>  latest,
}
