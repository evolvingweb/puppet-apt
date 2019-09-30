require 'spec_helper'

describe 'apt::mark', type: :define do
  let :title do
    'my_source'
  end

  let :facts do
    {
      os: { family: 'Debian', name: 'Debian', release: { major: '8', full: '8.0' } },
      lsbdistid: 'Debian',
      lsbdistcodename: 'jessie',
      osfamily: 'Debian',
    }
  end

  context 'with correct seting' do
    let :params do
      {
        'setting' => 'manual',
      }
    end

    it {
      is_expected.to contain_exec('/usr/bin/apt-mark manual my_source')
    }
  end

  describe 'with wrong setting' do
    let :params do
      {
        'setting' => 'foobar',
      }
    end

    it do
      is_expected.to raise_error(Puppet::PreformattedError, %r{expects a match for Enum\['auto', 'hold', 'manual', 'unhold'\], got 'foobar'})
    end
  end
end
