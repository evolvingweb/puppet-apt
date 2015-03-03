require 'spec_helper'
describe 'apt::params', :type => :class do
  let(:facts) { { :lsbdistid => 'Debian', :osfamily => 'Debian', :lsbdistcodename => 'wheezy' } }
  let (:title) { 'my_package' }

  it { is_expected.to contain_apt__params }

  # There are 4 resources in this class currently
  # there should not be any more resources because it is a params class
  # The resources are class[apt::params], class[main], class[settings], stage[main]
  it "Should not contain any resources" do
    expect(subject.resources.size).to eq(4)
  end

  describe "With unknown lsbdistid" do

    let(:facts) { { :lsbdistid => 'CentOS', :osfamily => 'Debian' } }
    let (:title) { 'my_package' }

    it do
      expect {
       is_expected.to compile
      }.to raise_error(Puppet::Error, /Unsupported lsbdistid/)
    end

  end

  describe "With lsb-release not installed" do
    let(:facts) { { :lsbdistid => '', :osfamily => 'Debian' } }
    let (:title) { 'my_package' }

    it do
      expect {
        is_expected.to compile
      }.to raise_error(Puppet::Error, /Unable to determine lsbdistid, is lsb-release installed/)
    end
  end

end
