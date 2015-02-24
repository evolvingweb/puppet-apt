require 'spec_helper'

describe 'apt::setting' do
  let(:pre_condition) { 'class { "apt": }' }
  let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian' } }
  let(:title) { 'teddybear' }

  let(:default_params) { { :setting_type => 'conf', :content => 'di' } }

  describe 'when using the defaults' do
    context 'without setting_type' do
      it do
        expect { should compile }.to raise_error(Puppet::Error, /Must pass setting_type /)
      end
    end

    context 'without source or content' do
      let(:params) { { :setting_type => 'conf' } }
      it do
        expect { should compile }.to raise_error(Puppet::Error, /needs either of /)
      end
    end

    context 'with setting_type=conf' do
      let(:params) { default_params }
      it { should contain_file('/etc/apt/apt.conf.d/50teddybear') }
    end

    context 'with setting_type=pref' do
      let(:params) { { :setting_type => 'pref', :content => 'di' } }
      it { should contain_file('/etc/apt/preferences.d/50teddybear') }
    end

    context 'with setting_type=list' do
      let(:params) { { :setting_type => 'list', :content => 'di' } }
      it { should contain_file('/etc/apt/sources.list.d/teddybear.list') }
    end

    context 'with source' do
      let(:params) { { :setting_type => 'conf', :source => 'puppet:///la/die/dah' } }
      it {
        should contain_file('/etc/apt/apt.conf.d/50teddybear').with({
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
        :source => "#{params[:source]}",
      })}
    end

    context 'with content' do
      let(:params) { default_params }
      it { should contain_file('/etc/apt/apt.conf.d/50teddybear').with({
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
        expect { should compile }.to raise_error(Puppet::Error, /cannot have both /)
      end
    end

    context 'with setting_type=ext' do
      let(:params) { default_params.merge({ :setting_type => 'ext' }) }
      it do
        expect { should compile }.to raise_error(Puppet::Error, /"ext" does not /)
      end
    end

    context 'with ensure=banana' do
      let(:params) { default_params.merge({ :ensure => 'banana' }) }
      it do
        expect { should compile }.to raise_error(Puppet::Error, /"banana" does not /)
      end
    end

    context 'with priority=1.2' do
      let(:params) { default_params.merge({ :priority => 1.2 }) }
      it do
        expect { should compile }.to raise_error(Puppet::Error, /be an integer /)
      end
    end
  end

  describe 'with priority=100' do
    let(:params) { default_params.merge({ :priority => 100 }) }
    it { should contain_file('/etc/apt/apt.conf.d/100teddybear') }
  end

  describe 'with base_name=puppy' do
    let(:params) { default_params.merge({ :base_name => 'puppy' }) }
    it { should contain_file('/etc/apt/apt.conf.d/50puppy') }
  end

  describe 'with base_name=true' do
    let(:params) { default_params.merge({ :base_name => true }) }
      it do
        expect { should compile }.to raise_error(Puppet::Error, /not a string/)
      end
  end

  describe 'with ensure=absent' do
    let(:params) { default_params.merge({ :ensure => 'absent' }) }
    it { should contain_file('/etc/apt/apt.conf.d/50teddybear').with({
      :ensure => 'absent',
    })}
  end

  describe 'with file_perms' do
    context "{'owner' => 'roosevelt'}" do
      let(:params) { default_params.merge({ :file_perms => {'owner' => 'roosevelt'} }) }
      it { should contain_file('/etc/apt/apt.conf.d/50teddybear').with({
        :owner => 'roosevelt',
        :group => 'root',
        :mode  => '0644',
      })}
    end

    context "'group' => 'roosevelt'}" do
      let(:params) { default_params.merge({ :file_perms => {'group' => 'roosevelt'} }) }
      it { should contain_file('/etc/apt/apt.conf.d/50teddybear').with({
        :owner => 'root',
        :group => 'roosevelt',
        :mode  => '0644',
      })}
    end

    context "'owner' => 'roosevelt'}" do
      let(:params) { default_params.merge({ :file_perms => {'mode' => '0600'} }) }
      it { should contain_file('/etc/apt/apt.conf.d/50teddybear').with({
        :owner => 'root',
        :group => 'root',
        :mode  => '0600',
      })}
    end
  end
end
