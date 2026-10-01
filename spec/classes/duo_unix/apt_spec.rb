# frozen_string_literal: true

require 'spec_helper'

describe 'duo_unix::apt' do
  on_supported_os.select { |os, _| os.start_with?('debian-', 'ubuntu-') }.each do |os, os_facts|
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
        is_expected.to contain_file('/etc/apt/sources.list.d/duosecurity.list')
          .with(
            owner: 'root',
            group: 'root',
            mode: '0644',
          )
      end

      it { is_expected.to contain_exec('duo-security-apt-update') }
      it { is_expected.to contain_exec('Duo Security GPG Import') }
      it { is_expected.to contain_package('duo-unix') }
      it { is_expected.to contain_package('openssh-server') }
    end
  end
end
