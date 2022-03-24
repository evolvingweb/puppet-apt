# frozen_string_literal: true

require 'spec_helper'

describe 'apt::backports', type: :class do
  let(:pre_condition) { "class{ '::apt': }" }

  describe 'debian/ubuntu tests' do
    context 'with defaults on deb' do
      let(:facts) do
        {
          os: {
            family: 'Debian',
            name: 'Debian',
            release: {
              major: '9',
              full: '9.0',
            },
            distro: {
              codename: 'stretch',
              id: 'Debian',
            },
          },
        }
      end

      it {
        is_expected.to contain_apt__source('backports').with(location: 'http://deb.debian.org/debian',
                                                             repos: 'main contrib non-free',
                                                             release: 'stretch-backports',
                                                             pin: { 'priority' => 200, 'release' => 'stretch-backports' })
      }
    end
    context 'with defaults on ubuntu' do
      let(:facts) do
        {
          os: {
            family: 'Debian',
            name: 'Ubuntu',
            release: {
              major: '18',
              full: '18.04',
            },
            distro: {
              codename: 'bionac',
              id: 'Ubuntu',
            },
          },
        }
      end

      it {
        is_expected.to contain_apt__source('backports').with(location: 'http://archive.ubuntu.com/ubuntu',
                                                             key: '630239CC130E1A7FD81A27B140976EAF437D05B5',
                                                             repos: 'main universe multiverse restricted',
                                                             release: 'bionac-backports',
                                                             pin: { 'priority' => 200, 'release' => 'bionac-backports' })
      }
    end
    context 'with everything set' do
      let(:facts) do
        {
          os: {
            family: 'Debian',
            name: 'Ubuntu',
            release: {
              major: '18',
              full: '18.04',
            },
            distro: {
              codename: 'bionac',
              id: 'Ubuntu',
            },
          },
        }
      end
      let(:params) do
        {
          location: 'http://archive.ubuntu.com/ubuntu-test',
          release: 'vivid',
          repos: 'main',
          key: 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553',
          pin: '90',
        }
      end

      it {
        is_expected.to contain_apt__source('backports').with(location: 'http://archive.ubuntu.com/ubuntu-test',
                                                             key: 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553',
                                                             repos: 'main',
                                                             release: 'vivid',
                                                             pin: { 'priority' => 90, 'release' => 'vivid' })
      }
    end
    context 'when set things with hashes' do
      let(:facts) do
        {
          os: {
            family: 'Debian',
            name: 'Ubuntu',
            release: {
              major: '18',
              full: '18.04',
            },
            distro: {
              codename: 'bionac',
              id: 'Ubuntu',
            },
          },
        }
      end
      let(:params) do
        {
          key: {
            'id' => 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553',
          },
          pin: {
            'priority' => '90',
          },
        }
      end

      it {
        is_expected.to contain_apt__source('backports').with(key: { 'id' => 'A1BD8E9D78F7FE5C3E65D8AF8B48AD6246925553' },
                                                             pin: { 'priority' => '90' })
      }
    end
  end
  describe 'mint tests' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name: 'LinuxMint',
          release: {
            major: '17',
            full: '17',
          },
          distro: {
            codename: 'qiana',
            id: 'LinuxMint',
          },
        },
      }
    end

    context 'with all the needed things set' do
      let(:params) do
        {
          location: 'http://archive.ubuntu.com/ubuntu',
          release: 'trusty-backports',
          repos: 'main universe multiverse restricted',
          key: '630239CC130E1A7FD81A27B140976EAF437D05B5',
        }
      end

      it {
        is_expected.to contain_apt__source('backports').with(location: 'http://archive.ubuntu.com/ubuntu',
                                                             key: '630239CC130E1A7FD81A27B140976EAF437D05B5',
                                                             repos: 'main universe multiverse restricted',
                                                             release: 'trusty-backports',
                                                             pin: { 'priority' => 200, 'release' => 'trusty-backports' })
      }
    end
    context 'with missing location' do
      let(:params) do
        {
          release: 'trusty-backports',
          repos: 'main universe multiverse restricted',
          key: '630239CC130E1A7FD81A27B140976EAF437D05B5',
        }
      end

      it do
        is_expected.to raise_error(Puppet::Error, %r{If not on Debian or Ubuntu, you must explicitly pass location, release, repos, and key})
      end
    end
    context 'with missing release' do
      let(:params) do
        {
          location: 'http://archive.ubuntu.com/ubuntu',
          repos: 'main universe multiverse restricted',
          key: '630239CC130E1A7FD81A27B140976EAF437D05B5',
        }
      end

      it do
        is_expected.to raise_error(Puppet::Error, %r{If not on Debian or Ubuntu, you must explicitly pass location, release, repos, and key})
      end
    end
    context 'with missing repos' do
      let(:params) do
        {
          location: 'http://archive.ubuntu.com/ubuntu',
          release: 'trusty-backports',
          key: '630239CC130E1A7FD81A27B140976EAF437D05B5',
        }
      end

      it do
        is_expected.to raise_error(Puppet::Error, %r{If not on Debian or Ubuntu, you must explicitly pass location, release, repos, and key})
      end
    end
    context 'with missing key' do
      let(:params) do
        {
          location: 'http://archive.ubuntu.com/ubuntu',
          release: 'trusty-backports',
          repos: 'main universe multiverse restricted',
        }
      end

      it do
        is_expected.to raise_error(Puppet::Error, %r{If not on Debian or Ubuntu, you must explicitly pass location, release, repos, and key})
      end
    end
  end
  describe 'validation' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            major: '18',
            full: '18.04',
          },
          distro: {
            codename: 'bionac',
            id: 'Ubuntu',
          },
        },
      }
    end

    context 'with invalid location' do
      let(:params) do
        {
          location: true,
        }
      end

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a})
      end
    end
    context 'with invalid release' do
      let(:params) do
        {
          release: true,
        }
      end

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a})
      end
    end
    context 'with invalid repos' do
      let(:params) do
        {
          repos: true,
        }
      end

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a})
      end
    end
    context 'with invalid key' do
      let(:params) do
        {
          key: true,
        }
      end

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a})
      end
    end
    context 'with invalid pin' do
      let(:params) do
        {
          pin: true,
        }
      end

      it do
        is_expected.to raise_error(Puppet::Error, %r{expects a})
      end
    end
  end
end
