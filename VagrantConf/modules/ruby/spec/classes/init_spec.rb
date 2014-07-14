require 'spec_helper'
describe 'ruby', :type => :class do

  describe 'when called with no parameters on redhat' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path => '/usr/local/bin:/usr/bin:/bin' } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should contain_package('rubygems-update').with({
        'ensure'    => 'installed',
        'require'   => 'Package[rubygems]',
        'provider'  => 'gem',
      })
    }
    it {
      should contain_exec('ruby::update_rubygems').with({
        'path'        => '/usr/local/bin:/usr/bin:/bin',
        'command'     => 'update_rubygems',
        'subscribe'   => 'Package[rubygems-update]',
        'refreshonly' => true,
      })
    }
    it {
      should_not contain_package('ruby-switch')
    }
    it {
      should_not contain_exec('switch_ruby')
    }
  end

  describe 'when called with no parameters on debian' do
    let (:facts) { {  :osfamily => 'Debian',
                      :path     => '/usr/local/bin:/usr/bin:/bin' } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should_not contain_package('rubygems-update')
    }
    it {
      should_not contain_exec('ruby::update_rubygems')
    }
    it {
      should_not contain_package('ruby-switch')
    }
    it {
      should_not contain_exec('switch_ruby')
    }
  end

  describe 'when called with custom rubygems version on redhat' do
    let (:facts) { {   :osfamily  => 'Redhat',
                       :path      => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {  :gems_version => '1.8.7' } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should contain_package('rubygems-update').with({
        'ensure'    => '1.8.7',
        'require'   => 'Package[rubygems]',
        'provider'  => 'gem',
      })
    }
    it {
      should contain_exec('ruby::update_rubygems').with({
        'path'        => '/usr/local/bin:/usr/bin:/bin',
        'command'     => 'update_rubygems',
        'subscribe'   => 'Package[rubygems-update]',
        'refreshonly' => true,
      })
    }
  end
  describe 'when called with custom rubygems version on Ubuntu 14.04' do
    let (:facts) { {   :osfamily  => 'Debian',
                       :operatingsystemrelease => '14.04',
                       :path      => '/usr/local/bin:/usr/bin:/bin' } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby1.9.1',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'require' => 'Package[ruby]',
        'name'    => 'ruby1.9.1-full'
      })
    }
    it {should_not contain_package('rubygems-update')}
    it {should_not contain_exec('ruby::update_rubygems')}
  end
  describe 'when called with custom ruby package name' do
    let (:facts) { { :osfamily => 'Debian',
                     :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {  :ruby_package  => 'ruby1.9' } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby1.9',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should_not contain_package('rubygems-update')
    }
    it {
      should_not contain_exec('ruby::update_rubygems')
    }
  end

  describe 'when called with custom rubygems package name' do
    let (:facts) { { :osfamily => 'Debian',
                     :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { { :rubygems_package  => 'rubygems1.9.1' } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
      })
    }
    it {
      should contain_package('rubygems').with({
        'name'    => 'rubygems1.9.1',
        'ensure'  => 'installed',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should_not contain_package('rubygems-update')
    }
    it {
      should_not contain_exec('ruby::update_rubygems')
    }
  end


  describe 'when called with custom rubygems and ruby versions on redhat' do
    let (:facts) { {  :osfamily => 'Redhat',
                      :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :gems_version => '1.8.6',
                        :version      => '1.8.7', } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => 'installed',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should contain_package('rubygems-update').with({
        'ensure'    => '1.8.6',
        'require'   => 'Package[rubygems]',
        'provider'  => 'gem',
      })
    }
    it {
      should contain_exec('ruby::update_rubygems').with({
        'path'        => '/usr/local/bin:/usr/bin:/bin',
        'command'     => 'update_rubygems',
        'subscribe'   => 'Package[rubygems-update]',
        'refreshonly' => true,
      })
    }
  end

  describe 'when called with custom rubygems (1.8.6) and ruby (1.8.7) versions on debian' do
    let (:facts) { {  :osfamily => 'Debian',
                      :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :gems_version => '1.8.6',
                        :version      => '1.8.7', } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby1.8',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => '1.8.6',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should_not contain_package('rubygems-update')
    }
    it {
      should_not contain_exec('ruby::update_rubygems')
    }
  end

  describe 'when called with custom rubygems (1.8.14) and ruby (1.9.1) versions on debian' do
    let (:facts) { {  :osfamily => 'Debian',
                      :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :gems_version => '1.8.14',
                        :version      => '1.9.1', } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby1.9.1',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => '1.8.14',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should_not contain_package('rubygems-update')
    }
    it {
      should_not contain_exec('ruby::update_rubygems')
    }
  end

  describe 'when called with custom rubygems version and no rubygems_update on debian' do
    let (:facts) { {    :osfamily => 'Debian',
                        :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :gems_version     => '1.8.7',
                        :rubygems_update  => false, } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => '1.8.7',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should_not contain_package('rubygems-update')
    }
    it {
      should_not contain_exec('ruby::update_rubygems')
    }
  end

  describe 'when called with custom rubygems version and no rubygems_update on redhat' do
    let (:facts) { {    :osfamily => 'Redhat',
                        :path => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :gems_version     => '1.8.7',
                        :rubygems_update  => false, } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby',
      })
    }
    it {
      should contain_package('rubygems').with({
        'ensure'  => '1.8.7',
        'require' => 'Package[ruby]',
      })
    }
    it {
      should_not contain_package('rubygems-update')
    }
    it {
      should_not contain_exec('ruby::update_rubygems')
    }
  end

  describe 'when specifying Ruby version 1.9.3' do
    let (:facts) { { :osfamily => 'Debian',
                     :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {  :version  => '1.9.3' } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby1.9.3',
      })
    }
  end

  describe 'when specifying Ruby version 2.0.0' do
    let (:facts) { { :osfamily => 'Debian',
                     :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {  :version  => '2.0.0' } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby2.0',
      })
    }
  end

  describe 'when specifying Ruby version 2.1.0' do
    let (:facts) { { :osfamily => 'Debian',
                     :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {  :version  => '2.1.0' } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'installed',
        'name'    => 'ruby2.1',
      })
    }
  end

  describe 'when latest release on Debian' do
    let (:facts) { { :osfamily => 'Debian',
                     :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {  :latest_release  => true } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'latest',
      })
    }
  end

  describe 'when latest release on RedHat' do
    let (:facts) { { :osfamily => 'Redhat',
                     :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {  :latest_release  => true } }
    it {
      should contain_package('ruby').with({
        'ensure'  => 'latest',
      })
    }
  end

  describe 'when trying to use ruby-switch on RedHat' do
    let (:facts) { {    :osfamily => 'Redhat',
                        :path     => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :version  => '1.9.1',
                        :switch   => true, } }
    it {
      should_not contain_package('ruby-switch')
    }
    it {
      should_not contain_exec('switch_ruby')
      # there is no rspec-puppet test for notice()
    }
  end

  describe 'when trying to use ruby-switch on Ubuntu 14.04' do
    let (:facts) { {    :osfamily         => 'Debian',
                        :operatingsystem  => 'Ubuntu',
                        :lsbdistrelease   => '14.04',
                        :path             => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :version  => '1.9.1',
                        :switch   => true, } }
    it {
      should_not contain_package('ruby-switch')
    }
    it {
      should_not contain_exec('switch_ruby')
      # there is no rspec-puppet test for notice()
    }
  end

  describe 'when using ruby-switch on Ubuntu earlier than 14.04' do
    let (:facts) { {    :osfamily         => 'Debian',
                        :operatingsystem  => 'Ubuntu',
                        :lsbdistrelease   => '12.04',
                        :path             => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :version  => '1.9.1',
                        :switch   => true, } }
    it {
      should contain_package('ruby-switch').with({
        'ensure'  => 'installed',
        'name'    => 'ruby-switch',
        'require' => 'Package[ruby]'
      })
    }
    it {
      should contain_exec('switch_ruby').with({
        'command' => '/usr/bin/ruby-switch --set ruby1.9.1',
        'unless'  => '/usr/bin/ruby-switch --check|/bin/grep ruby1.9.1',
        'require' => 'Package[ruby-switch]'
      })
    }
  end

  describe 'when using ruby-switch on Ubuntu earlier than 14.04 and the Ruby package is ruby1.9.1-full' do
    let (:facts) { {    :osfamily         => 'Debian',
                        :operatingsystem  => 'Ubuntu',
                        :lsbdistrelease   => '12.04',
                        :path             => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :version            => 'installed',
                        :ruby_package       => 'ruby1.9.1-full',
                        :switch             => true,
                        } }
    it {
      should contain_package('ruby-switch').with({
        'ensure'  => 'installed',
        'name'    => 'ruby-switch',
        'require' => 'Package[ruby]'
      })
    }
    it {
      should contain_exec('switch_ruby').with({
        'command' => '/usr/bin/ruby-switch --set ruby1.9.1',
        'unless'  => '/usr/bin/ruby-switch --check|/bin/grep ruby1.9.1',
        'require' => 'Package[ruby-switch]'
      })
    }
  end

  describe 'when using ruby-switch on Ubuntu earlier than 14.04 and the Ruby package is ruby1.8-full' do
    let (:facts) { {    :osfamily         => 'Debian',
                        :operatingsystem  => 'Ubuntu',
                        :lsbdistrelease   => '12.04',
                        :path             => '/usr/local/bin:/usr/bin:/bin' } }
    let (:params) { {   :version            => 'installed',
                        :ruby_package       => 'ruby1.8-full',
                        :switch             => true,
                        } }
    it {
      should contain_package('ruby-switch').with({
        'ensure'  => 'installed',
        'name'    => 'ruby-switch',
        'require' => 'Package[ruby]'
      })
    }
    it {
      should contain_exec('switch_ruby').with({
        'command' => '/usr/bin/ruby-switch --set ruby1.8',
        'unless'  => '/usr/bin/ruby-switch --check|/bin/grep ruby1.8',
        'require' => 'Package[ruby-switch]'
      })
    }
  end

end
