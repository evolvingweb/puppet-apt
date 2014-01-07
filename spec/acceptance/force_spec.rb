require 'spec_helper_acceptance'

describe 'apt::force define' do
  context 'defaults' do
    it 'should work with no errors' do
      pp = <<-EOS
      include apt
      apt::force { 'vim': }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe package('vim') do
      it { should be_installed }
    end
  end

end
