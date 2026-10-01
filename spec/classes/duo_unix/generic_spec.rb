# frozen_string_literal: true

require 'spec_helper'

describe 'duo_unix::generic' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

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

      it do
        is_expected.to contain_file('/usr/sbin/login_duo')
          .with(
            owner: 'root',
            group: 'root',
            mode: '4755',
          )
      end

      it do
        if os_facts[:os]['family'] == 'RedHat'
          is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-DUO')
        else
          is_expected.to contain_file('/etc/apt/DEB-GPG-KEY-DUO')
        end
      end

      it { is_expected.to contain_service(os_facts[:os]['family'] == 'RedHat' ? 'sshd' : 'ssh') }
    end
  end
end
