require 'spec_helper'
describe 'apt::builddep', :type => :define do

  let(:title) { 'my_package' }

  describe "should succeed with a Class['apt']" do
    let(:pre_condition) { 'class {"apt": } ' }

    it { should contain_exec("apt-update-#{title}").with_command("/usr/bin/apt-get update").with_refreshonly(true) }
  end

  describe "should fail without Class['apt']" do
    it { expect {should contain_exec("apt-update-#{title}").with_command("/usr/bin/apt-get update").with_refreshonly(true) }\
      .to raise_error(Puppet::Error)
    }
  end

end
