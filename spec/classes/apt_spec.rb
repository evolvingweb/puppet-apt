require 'spec_helper'
describe 'apt', :type => :class do
  let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }

  context 'defaults' do
    it { is_expected.to contain_file('sources.list').that_notifies('Exec[apt_update]').only_with({
      'ensure' => 'present',
      'path'   => '/etc/apt/sources.list',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
      'notify' => 'Exec[apt_update]',
    })}

    it { is_expected.to contain_file('sources.list.d').that_notifies('Exec[apt_update]').only_with({
      'ensure'  => 'directory',
      'path'    => '/etc/apt/sources.list.d',
      'owner'   => 'root',
      'group'   => 'root',
      'purge'   => false,
      'recurse' => false,
      'notify'  => 'Exec[apt_update]',
    })}

    it { is_expected.to contain_file('preferences.d').only_with({
      'ensure'  => 'directory',
      'path'    => '/etc/apt/preferences.d',
      'owner'   => 'root',
      'group'   => 'root',
      'purge'   => false,
      'recurse' => false,
    })}

    it 'should lay down /etc/apt/apt.conf.d/15update-stamp' do
      is_expected.to contain_file('/etc/apt/apt.conf.d/15update-stamp').with({
        'group' => 'root',
        'mode'  => '0644',
        'owner' => 'root',
      }).with_content(/APT::Update::Post-Invoke-Success \{"touch \/var\/lib\/apt\/periodic\/update-success-stamp 2>\/dev\/null \|\| true";\};/)
    end

    it { is_expected.to contain_exec('apt_update').with({
      'refreshonly' => 'true',
    })}
  end

  context 'lots of non-defaults' do
    let :params do
      {
        :always_apt_update    => true,
        :purge_sources_list   => true,
        :purge_sources_list_d => true,
        :purge_preferences    => true,
        :purge_preferences_d  => true,
        :update_timeout       => '1',
        :update_tries         => '3',
      }
    end

    it { is_expected.to contain_file('sources.list').with({
      'content' => "# Repos managed by puppet.\n"
    })}

    it { is_expected.to contain_file('sources.list.d').with({
      'purge'   => 'true',
      'recurse' => 'true',
    })}

    it { is_expected.to contain_file('apt-preferences').only_with({
      'ensure' => 'absent',
      'path'   => '/etc/apt/preferences',
    })}

    it { is_expected.to contain_file('preferences.d').with({
      'purge'   => 'true',
      'recurse' => 'true',
    })}

    it { is_expected.to contain_exec('apt_update').with({
      'refreshonly' => 'false',
      'timeout'     => '1',
      'tries'       => '3',
    })}

  end

  context 'with sources defined on valid osfamily' do
    let :facts do
      { :osfamily        => 'Debian',
        :lsbdistcodename => 'precise',
        :lsbdistid       => 'Debian',
      }
    end
    let(:params) { { :sources => {
      'debian_unstable' => {
        'location'          => 'http://debian.mirror.iweb.ca/debian/',
        'release'           => 'unstable',
        'repos'             => 'main contrib non-free',
        'key'               => '55BE302B',
        'key_server'        => 'subkeys.pgp.net',
        'pin'               => '-10',
        'include_src'       => true
      },
      'puppetlabs' => {
        'location'   => 'http://apt.puppetlabs.com',
        'repos'      => 'main',
        'key'        => '4BD6EC30',
        'key_server' => 'pgp.mit.edu',
      }
    } } }

    it {
      is_expected.to contain_apt__setting('list-debian_unstable').with({
        'ensure'  => 'present',
      })
    }

    it { is_expected.to contain_file('/etc/apt/sources.list.d/debian_unstable.list').with_content(/^deb http:\/\/debian.mirror.iweb.ca\/debian\/ unstable main contrib non-free$/) }
    it { is_expected.to contain_file('/etc/apt/sources.list.d/debian_unstable.list').with_content(/^deb-src http:\/\/debian.mirror.iweb.ca\/debian\/ unstable main contrib non-free$/) }

    it {
      is_expected.to contain_apt__setting('list-puppetlabs').with({
        'ensure'  => 'present',
      })
    }

    it { is_expected.to contain_file('/etc/apt/sources.list.d/puppetlabs.list').with_content(/^deb http:\/\/apt.puppetlabs.com precise main$/) }
  end

  describe 'failing tests' do
    context 'bad purge_sources_list' do
      let :params do
        {
          'purge_sources_list' => 'foo'
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error)
      end
    end

    context 'bad purge_sources_list_d' do
      let :params do
        {
          'purge_sources_list_d' => 'foo'
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error)
      end
    end

    context 'bad purge_preferences' do
      let :params do
        {
          'purge_preferences' => 'foo'
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error)
      end
    end

    context 'bad purge_preferences_d' do
      let :params do
        {
          'purge_preferences_d' => 'foo'
        }
      end
      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error)
      end
    end

    context 'with unsupported osfamily' do
      let :facts do
        { :osfamily => 'Darwin', }
      end

      it do
        expect {
          is_expected.to compile
        }.to raise_error(Puppet::Error, /This module only works on Debian or derivatives like Ubuntu/)
      end
    end
  end
end
