# frozen_string_literal: true

require 'spec_helper'

describe 'duo_unix::pam' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:pre_condition) do
        <<-PUPPET
        class { 'duo_unix':
          package_version => 'installed',
          repo_uri        => 'https://pkg.duosecurity.com',
          usage           => 'pam',
          ikey            => 'DIXXXXXXXXXXXXXXXXXX',
          skey            => 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeef',
          host            => 'api-XXXXXXXX.duosecurity.com',
        }
        PUPPET
      end

      it { is_expected.to compile }

      it do
        is_expected.to contain_file('/etc/duo/pam_duo.conf')
          .with(
            owner: 'root',
            group: 'root',
            mode: '0600',
          )
      end

      it { is_expected.to contain_augeas('Duo Security SSH Configuration') }
      it { is_expected.to contain_augeas('PAM Configuration') }
    end
  end
end
