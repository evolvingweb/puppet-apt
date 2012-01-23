require 'spec_helper'
describe 'apt::source', :type => :define do
  let :title do
    'my_source'
  end

  let :default_params do
    {
      :location           => '',
      :release            => 'karmic',
      :repos              => 'main',
      :include_src        => true,
      :required_packages  => false,
      :key                => false,
      :key_server         => 'keyserver.ubuntu.com',
      :pin                => false,
      :key_content        => false
    }
  end

  [{},
   {
      :location           => 'somewhere',
      :release            => 'precise',
      :repos              => 'security',
      :include_src        => false,
      :required_packages  => 'apache',
      :key                => 'key_name',
      :key_server         => 'keyserver.debian.com',
      :pin                => '600',
      :key_content        => 'ABCD1234'
    }
  ].each do |param_set|
    describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
      let :param_hash do
        param_set == {} ? default_params : params
      end

      let :params do
        param_set
      end

      let :filename do
        "/etc/apt/sources.list.d/#{title}.list"
      end

      let :content do
        content = "# #{title}"
        content << "\ndeb #{param_hash[:location]} #{param_hash[:release]} #{param_hash[:repos]}\n"
        if param_hash[:include_src]
          content << "deb-src #{param_hash[:location]} #{param_hash[:release]} #{param_hash[:repos]}\n"
        end
        content
      end

      it { should contain_class("apt::params") }

      it { should contain_file("#{title}.list")\
        .with_path(filename)\
        .with_ensure("file")\
        .with_owner("root")\
        .with_group("root")\
        .with_mode(644)\
        .with_content(content)
      }

      it {
        if param_hash[:pin]
          should create_resource("apt::pin", param_hash[:release]).with_param("priority", param_hash[:pin]).with_param("before", "File[#{title}.list]")
        else
          should_not create_resource("apt::pin", param_hash[:release]).with_param("priority", param_hash[:pin]).with_param("before", "File[#{title}.list]")
        end
      }

      it {
        should contain_exec("#{title} apt update")\
          .with_command("/usr/bin/apt-get update")\
          .with_subscribe("File[#{title}.list]")\
          .with_refreshonly(true)
      }

      it {
        if param_hash[:required_packages]
          should contain_exec("/usr/bin/apt-get -y install #{param_hash[:required_packages]}")\
            .with_subscribe("File[#{title}.list]")\
            .with_refreshonly(true)
        else
          should_not contain_exec("/usr/bin/apt-get -y install #{param_hash[:required_packages]}")\
            .with_subscribe("File[#{title}.list]")\
            .with_refreshonly(true)
        end
      }

      it {
        if param_hash[:key]
          if param_hash[:key_content]
            should contain_exec("Add key: #{param_hash[:key]} from content")\
              .with_command("/bin/echo '#{param_hash[:key_content]}' | /usr/bin/apt-key add -")\
              .with_unless("/usr/bin/apt-key list | /bin/grep '#{param_hash[:key]}'")\
              .with_before("File[#{title}.list]")
            should_not contain_exec("/usr/bin/apt-key adv --keyserver #{param_hash[:key_server]} --recv-keys #{param_hash[:key]}")\
              .with_unless("/usr/bin/apt-key list | /bin/grep #{param_hash[:key]}")\
              .with_before("File[#{title}.list]")

          else
            should contain_exec("/usr/bin/apt-key adv --keyserver #{param_hash[:key_server]} --recv-keys #{param_hash[:key]}")\
              .with_unless("/usr/bin/apt-key list | /bin/grep #{param_hash[:key]}")\
              .with_before("File[#{title}.list]")
            should_not contain_exec("Add key: #{param_hash[:key]} from content")\
              .with_command("/bin/echo '#{param_hash[:key_content]}' | /usr/bin/apt-key add -")\
              .with_unless("/usr/bin/apt-key list | /bin/grep '#{param_hash[:key]}'")\
              .with_before("File[#{title}.list]")
          end
        else
          should_not contain_exec("Add key: #{param_hash[:key]} from content")\
            .with_command("/bin/echo '#{param_hash[:key_content]}' | /usr/bin/apt-key add -")\
            .with_unless("/usr/bin/apt-key list | /bin/grep '#{param_hash[:key]}'")\
            .with_before("File[#{title}.list]")
          should_not contain_exec("/usr/bin/apt-key adv --keyserver #{param_hash[:key_server]} --recv-keys #{param_hash[:key]}")\
              .with_unless("/usr/bin/apt-key list | /bin/grep #{param_hash[:key]}")\
              .with_before("File[#{title}.list]")

        end
      }
    end
  end
end

