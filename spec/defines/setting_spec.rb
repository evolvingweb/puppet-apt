require 'spec_helper'

describe 'apt::setting' do
  let(:pre_condition) { 'class { "apt": }' }
  let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
  let(:title) { 'conf-teddybear' }

  let(:default_params) { { :content => 'di' } }

  describe 'when using the defaults' do
    context 'without source or content' do
      it do
        expect { is_expected.to compile }.to raise_error(Puppet::Error, /needs either of /)
      end
    end

    context 'with title=conf-teddybear ' do
      let(:params) { default_params }
      it { is_expected.to contain_file('/etc/apt/apt.conf.d/50teddybear').that_notifies('Exec[apt_update]') }
    end

    context 'with title=pref-teddybear' do
      let(:title) { 'pref-teddybear' }
      let(:params) { default_params }
      it { is_expected.to contain_file('/etc/apt/preferences.d/50teddybear').that_notifies('Exec[apt_update]') }
    end

    context 'with title=list-teddybear' do
      let(:title) { 'list-teddybear' }
      let(:params) { default_params }
      it { is_expected.to contain_file('/etc/apt/sources.list.d/teddybear.list').that_notifies('Exec[apt_update]') }
    end

    context 'with source' do
      let(:params) { { :source => 'puppet:///la/die/dah' } }
      it {
        is_expected.to contain_file('/etc/apt/apt.conf.d/50teddybear').that_notifies('Exec[apt_update]').with({
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
        :source => "#{params[:source]}",
      })}
    end

    context 'with content' do
      let(:params) { default_params }
      it { is_expected.to contain_file('/etc/apt/apt.conf.d/50teddybear').that_notifies('Exec[apt_update]').with({
        :ensure  => 'file',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0644',
        :content => "#{params[:content]}",
      })}
    end
  end

  describe 'when trying to pull one over' do
    context 'with source and content' do
      let(:params) { default_params.merge({ :source => 'la' }) }
      it do
        expect { is_expected.to compile }.to raise_error(Puppet::Error, /cannot have both /)
      end
    end

    context 'with title=ext-teddybear' do
      let(:title) { 'ext-teddybear' }
      let(:params) { default_params }
      it do
        expect { is_expected.to compile }.to raise_error(Puppet::Error, /must start with /)
      end
    end

    context 'with ensure=banana' do
      let(:params) { default_params.merge({ :ensure => 'banana' }) }
      it do
        expect { is_expected.to compile }.to raise_error(Puppet::Error, /"banana" does not /)
      end
    end

    context 'with priority=1.2' do
      let(:params) { default_params.merge({ :priority => 1.2 }) }
      it do
        expect { is_expected.to compile }.to raise_error(Puppet::Error, /be an integer /)
      end
    end
  end

  describe 'with priority=100' do
    let(:params) { default_params.merge({ :priority => 100 }) }
    it { is_expected.to contain_file('/etc/apt/apt.conf.d/100teddybear').that_notifies('Exec[apt_update]') }
  end

  describe 'with ensure=absent' do
    let(:params) { default_params.merge({ :ensure => 'absent' }) }
    it { is_expected.to contain_file('/etc/apt/apt.conf.d/50teddybear').that_notifies('Exec[apt_update]').with({
      :ensure => 'absent',
    })}
  end

  describe 'with file_perms' do
    context "{'owner' => 'roosevelt'}" do
      let(:params) { default_params.merge({ :file_perms => {'owner' => 'roosevelt'} }) }
      it { is_expected.to contain_file('/etc/apt/apt.conf.d/50teddybear').that_notifies('Exec[apt_update]').with({
        :owner => 'roosevelt',
        :group => 'root',
        :mode  => '0644',
      })}
    end

    context "'group' => 'roosevelt'}" do
      let(:params) { default_params.merge({ :file_perms => {'group' => 'roosevelt'} }) }
      it { is_expected.to contain_file('/etc/apt/apt.conf.d/50teddybear').that_notifies('Exec[apt_update]').with({
        :owner => 'root',
        :group => 'roosevelt',
        :mode  => '0644',
      })}
    end

    context "'owner' => 'roosevelt'}" do
      let(:params) { default_params.merge({ :file_perms => {'mode' => '0600'} }) }
      it { is_expected.to contain_file('/etc/apt/apt.conf.d/50teddybear').that_notifies('Exec[apt_update]').with({
        :owner => 'root',
        :group => 'root',
        :mode  => '0600',
      })}
    end

    context "'notify_update' => false}" do
      let(:params) { default_params.merge({ :notify_update => false }) }
      it { is_expected.to contain_file('/etc/apt/apt.conf.d/50teddybear') }
      it { is_expected.not_to contain_file('/etc/apt/apt.conf.d/50teddybear').that_notifies('Exec[apt_update]') }
    end

  end
end
