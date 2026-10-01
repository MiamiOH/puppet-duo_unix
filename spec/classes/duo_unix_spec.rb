# frozen_string_literal: true

require 'spec_helper'

describe 'duo_unix' do
  let(:params) do
    {
      'package_version' => 'installed',
      'repo_uri'        => 'https://pkg.duosecurity.com',
      'usage'           => 'login',
      'ikey'            => 'DIXXXXXXXXXXXXXXXXXX',
      'skey'            => 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeef',
      'host'            => 'api-XXXXXXXX.duosecurity.com',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      if os_facts[:os]['family'] == 'RedHat'
        it do
          is_expected.to contain_class('duo_unix::yum')
          is_expected.to contain_class('duo_unix::generic')
          is_expected.to contain_yumrepo('duosecurity')
          is_expected.to contain_package('duo_unix')
        end
      elsif os_facts[:os]['family'] == 'Debian'
        it do
          is_expected.to contain_class('duo_unix::apt')
          is_expected.to contain_class('duo_unix::generic')
          is_expected.to contain_package('duo-unix')
        end
      end

      context 'with usage set to pam' do
        let(:params) { super().merge('usage' => 'pam') }

        it { is_expected.to contain_class('duo_unix::pam') }
      end
    end
  end

  context 'when mandatory parameters are missing or empty' do
    let(:params) do
      {
        'package_version' => 'installed',
        'repo_uri'        => 'https://pkg.duosecurity.com',
        'usage'           => 'login',
        'ikey'            => '',
        'skey'            => '',
        'host'            => '',
      }
    end

    it 'fails compilation' do
      expect { is_expected.to compile }.to raise_error(%r{ikey, skey, and host must all be defined})
    end
  end
end
