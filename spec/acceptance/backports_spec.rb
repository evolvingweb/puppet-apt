require 'spec_helper_acceptance'

describe 'apt::backports class' do
  context 'defaults' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'apt::backports': }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
  end

  context 'release' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'apt::backports': release => 'precise' }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/apt/sources.list.d/backports.list') do
      it { should be_file }
      it { should contain 'precise-backports main universe multiverse restricted' }
    end
  end

  context 'location' do
    it 'should work with no errors' do
      pp = <<-EOS
      class { 'apt::backports': release => 'precise', location => 'http://localhost/ubuntu' }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/apt/sources.list.d/backports.list') do
      it { should be_file }
      it { should contain 'deb http://localhost/ubuntu precise-backports main universe multiverse restricted' }
    end
  end

  context 'reset' do
    it 'deletes backport files' do
      shell('rm -rf /etc/apt/sources.list.d/backports.list')
      shell('rm -rf /etc/apt/preferences.d/backports.pref')
    end
  end

end
