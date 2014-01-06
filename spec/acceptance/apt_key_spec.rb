require 'spec_helper_acceptance'

describe 'apt::key' do

  context 'reset' do
    it 'clean up keys' do
      shell('apt-key del 4BD6EC30', :acceptable_exit_codes => [0,1,2])
      shell('apt-key del D50582E6', :acceptable_exit_codes => [0,1,2])
    end
  end

  context 'apt::key' do
    it 'should work with no errors' do
      pp = <<-EOS
      include '::apt'
      apt::key { 'puppetlabs':
        key        => '4BD6EC30',
        key_server => 'pgp.mit.edu',
      }

      apt::key { 'jenkins':
        key        => 'D50582E6',
        key_source => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key',
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe 'keys should exist' do
      it 'finds puppetlabs key' do
        shell('apt-key list | grep 4BD6EC30') do |r|
          expect(r.exit_code).to be_zero
        end
      end
      it 'finds jenkins key' do
        shell('apt-key list | grep D50582E6') do |r|
          expect(r.exit_code).to be_zero
        end
      end
    end
  end

  context 'reset' do
    it 'clean up keys' do
      shell('apt-key del 4BD6EC30')
      shell('apt-key del D50582E6')
    end
  end

end
