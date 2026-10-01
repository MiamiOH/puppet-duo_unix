# frozen_string_literal: true

require 'spec_helper'

describe 'duo_unix::login' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      
      # Declare the parent class with its mandatory parameters so the subclass can read them
      let(:pre_condition) do
        <<-PUPPET
        class { 'duo_unix':
          package_version => 'installed',
          repo_uri        => 'https://pkg.duosecurity.com',
          usage           => 'login',
          ikey            => 'DIXXXXXXXXXXXXXXXXXX',
          skey            => 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeef',
          host            => 'api-XXXXXXXX.duosecurity.com',
        }
        PUPPET
      end

      it { is_expected.to compile }
      it { is_expected.to contain_file('/etc/duo/login_duo.conf').with_ensure('file') }
      it { is_expected.to contain_augeas('Duo Security SSH Configuration') }
    end
  end
end
