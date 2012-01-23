require 'spec_helper'
describe 'apt::pin', :type => :define do
  let(:title) { 'my_pin' }

  let :default_params do
    {
      :packages => '*',
      :priority => '0'
    }
  end

  [{},
   {
      :packages  => 'apache',
      :priority  => '1'
    }
  ].each do |param_set|
    describe "when #{param_set == {} ? "using default" : "specifying"} define parameters" do
      let :param_hash do
        param_set == {} ? default_params : params
      end

      let :params do
        param_set
      end

      it { should include_class("apt::params") }

      it { should create_file("#{title}.pref")\
        .with_path("/etc/apt/preferences.d/#{title}")\
        .with_ensure("file")\
        .with_owner("root")\
        .with_group("root")\
        .with_mode("644")\
        .with_content("# #{title}\nPackage: #{param_hash[:packages]}\nPin: release a=#{title}\nPin-Priority: #{param_hash[:priority]}")
      }
    end
  end
end
