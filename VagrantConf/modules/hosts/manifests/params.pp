class hosts::params {
  case $::lsbdistcodename {
    'lenny', 'squeeze', 'maverick', 'natty': {
    }
    default: {
      fail("Module ${module_name} does not support ${::lsbdistcodename}")
    }
  }
}