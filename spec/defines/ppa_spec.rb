require 'spec_helper'
describe 'apt::ppa' do

  describe 'defaults' do
    let :pre_condition do
      'class { "apt": }'
    end
    let :facts do
      {
        :lsbdistrelease  => '11.04',
        :lsbdistcodename => 'natty',
        :operatingsystem => 'Ubuntu',
        :osfamily        => 'Debian',
        :lsbdistid       => 'Ubuntu',
      }
    end

    let(:title) { 'ppa:needs/such.substitution/wow' }
    it { is_expected.to_not contain_package('python-software-properties') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:needs/such.substitution/wow').that_notifies('Exec[apt_update]').with({
      :environment => [],
      :command     => '/usr/bin/add-apt-repository -y ppa:needs/such.substitution/wow',
      :unless      => '/usr/bin/test -s /etc/apt/sources.list.d/needs-such_substitution-wow-natty.list',
      :user        => 'root',
      :logoutput   => 'on_failure',
    })
    }
  end

  describe 'apt included, no proxy' do
    let :pre_condition do
      'class { "apt": }'
    end
    let :facts do
      {
        :lsbdistrelease  => '14.04',
        :lsbdistcodename => 'trusty',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :osfamily        => 'Debian',
      }
    end
    let :params do
      {
        :options => '',
        :package_manage => true,
      }
    end
    let(:title) { 'ppa:foo' }
    it { is_expected.to contain_package('software-properties-common') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:foo').that_notifies('Exec[apt_update]').with({
      :environment => [],
      :command     => '/usr/bin/add-apt-repository  ppa:foo',
      :unless      => '/usr/bin/test -s /etc/apt/sources.list.d/foo-trusty.list',
      :user        => 'root',
      :logoutput   => 'on_failure',
    })
    }
  end

  describe 'apt included, proxy host' do
    let :pre_condition do
      'class { "apt":
        proxy => { "host" => "localhost" },
      }'
    end
    let :facts do
      {
        :lsbdistrelease  => '14.04',
        :lsbdistcodename => 'trusty',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :osfamily        => 'Debian',
      }
    end
    let :params do
      {
        'options' => '',
        'package_manage' => true,
      }
    end
    let(:title) { 'ppa:foo' }
    it { is_expected.to contain_package('software-properties-common') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:foo').that_notifies('Exec[apt_update]').with({
      :environment => ['http_proxy=http://localhost:8080'],
      :command     => '/usr/bin/add-apt-repository  ppa:foo',
      :unless      => '/usr/bin/test -s /etc/apt/sources.list.d/foo-trusty.list',
      :user        => 'root',
      :logoutput   => 'on_failure',
    })
    }
  end

  describe 'apt included, proxy host and port' do
    let :pre_condition do
      'class { "apt":
        proxy => { "host" => "localhost", "port" => 8180 },
      }'
    end
    let :facts do
      {
        :lsbdistrelease  => '14.04',
        :lsbdistcodename => 'trusty',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :osfamily        => 'Debian',
      }
    end
    let :params do
      {
        :options => '',
        :package_manage => true,
      }
    end
    let(:title) { 'ppa:foo' }
    it { is_expected.to contain_package('software-properties-common') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:foo').that_notifies('Exec[apt_update]').with({
      :environment => ['http_proxy=http://localhost:8180'],
      :command     => '/usr/bin/add-apt-repository  ppa:foo',
      :unless      => '/usr/bin/test -s /etc/apt/sources.list.d/foo-trusty.list',
      :user        => 'root',
      :logoutput   => 'on_failure',
    })
    }
  end

  describe 'apt included, proxy host and port and https' do
    let :pre_condition do
      'class { "apt":
        proxy => { "host" => "localhost", "port" => 8180, "https" => true },
      }'
    end
    let :facts do
      {
        :lsbdistrelease  => '14.04',
        :lsbdistcodename => 'trusty',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :osfamily        => 'Debian',
      }
    end
    let :params do
      {
        :options => '',
        :package_manage => true,
      }
    end
    let(:title) { 'ppa:foo' }
    it { is_expected.to contain_package('software-properties-common') }
    it { is_expected.to contain_exec('add-apt-repository-ppa:foo').that_notifies('Exec[apt_update]').with({
      :environment => ['http_proxy=http://localhost:8180', 'https_proxy=https://localhost:8180'],
      :command     => '/usr/bin/add-apt-repository  ppa:foo',
      :unless      => '/usr/bin/test -s /etc/apt/sources.list.d/foo-trusty.list',
      :user        => 'root',
      :logoutput   => 'on_failure',
    })
    }
  end

  describe 'ensure absent' do
    let :pre_condition do
      'class { "apt": }'
    end
    let :facts do
      {
        :lsbdistrelease  => '14.04',
        :lsbdistcodename => 'trusty',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :osfamily        => 'Debian',
      }
    end
    let(:title) { 'ppa:foo' }
    let :params do
      {
        :ensure => 'absent'
      }
    end
    it { is_expected.to contain_file('/etc/apt/sources.list.d/foo-trusty.list').that_notifies('Exec[apt_update]').with({
      :ensure => 'absent',
    })
    }
  end

  context 'validation' do
    describe 'no release' do
      let :facts do
        {
          :lsbdistrelease  => '14.04',
          :operatingsystem => 'Ubuntu',
          :lsbdistid       => 'Ubuntu',
          :osfamily        => 'Debian',
        }
      end
      let(:title) { 'ppa:foo' }
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /lsbdistcodename fact not available: release parameter required/)
      end
    end

    describe 'not ubuntu' do
      let :facts do
        {
          :lsbdistrelease  => '14.04',
          :lsbdistcodename => 'trusty',
          :operatingsystem => 'Debian',
          :lsbdistid       => 'Ubuntu',
          :osfamily        => 'Debian',
        }
      end
      let(:title) { 'ppa:foo' }
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /supported on Ubuntu and LinuxMint only/)
      end
    end
  end
end
