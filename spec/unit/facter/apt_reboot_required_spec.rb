require 'spec_helper'

describe 'apt_reboot_required fact' do
  subject { Facter.fact(:apt_reboot_required).value }

  after(:each) { Facter.clear }

  describe 'if a reboot is required' do
    before(:each) do
      allow(Facter.fact(:osfamily)).to receive(:value).and_return('Debian')
      allow(File).to receive(:file?).and_return(true)
      allow(File).to receive(:file?).once.with('/var/run/reboot-required').and_return(true)
    end
    it { is_expected.to eq true }
  end

  describe 'if a reboot is not required' do
    before(:each) do
      allow(Facter.fact(:osfamily)).to receive(:value).and_return('Debian')
      allow(File).to receive(:file?).and_return(true)
      allow(File).to receive(:file?).once.with('/var/run/reboot-required').and_return(false)
    end
    it { is_expected.to eq false }
  end
end
