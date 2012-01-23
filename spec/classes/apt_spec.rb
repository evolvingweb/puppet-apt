require 'spec_helper'
describe 'apt', :type => :class do
  let :default_params do
    {
      :disable_keys => false,
      :always_apt_update => false
    }
  end

  [{},
   {
      :disable_keys => true,
      :always_apt_update => true
    }
  ].each do |param_set|
    describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
      let :param_hash do
        param_set == {} ? default_params : params
      end

      let :params do
        param_set
      end

      let :refresh_only_apt_update do
        if param_hash[:always_apt_update]
          false
        else
          true
        end
      end

      it { should include_class("apt::params") }

      it { should contain_package("python-software-properties") }

      it {
        should create_file("sources.list")\
          .with_path("/etc/apt/sources.list")\
          .with_ensure("present")\
          .with_owner("root")\
          .with_group("root")\
          .with_mode(644)
      }

      it {
        should create_file("sources.list.d")\
          .with_path("/etc/apt/sources.list.d")\
          .with_ensure("directory")\
          .with_owner("root")\
          .with_group("root")
      }

      it {
        should create_exec("apt_update")\
          .with_command("/usr/bin/apt-get update")\
          .with_subscribe(["File[sources.list]", "File[sources.list.d]"])\
          .with_refreshonly(refresh_only_apt_update)
      }

      it {
        if param_hash[:disable_keys]
          should create_exec("make-apt-insecure")\
            .with_command('/bin/echo "APT::Get::AllowUnauthenticated 1;" >> /etc/apt/apt.conf.d/99unauth')\
            .with_creates('/etc/apt/apt.conf.d/99unauth')
        else
          should_not create_exec("make-apt-insecure")\
            .with_command('/bin/echo "APT::Get::AllowUnauthenticated 1;" >> /etc/apt/apt.conf.d/99unauth')\
            .with_creates('/etc/apt/apt.conf.d/99unauth')
        end
      }
    end
  end
end
