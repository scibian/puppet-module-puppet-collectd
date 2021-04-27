require 'spec_helper'

describe 'collectd::plugin::memory', type: :class do
  on_supported_os(baseline_os_hash).each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      options = os_specific_options(facts)
      context ':ensure => present, default params' do
        it "Will create #{options[:plugin_conf_dir]}/10-memory.conf" do
          is_expected.to contain_file('memory.load').with(
            ensure: 'present',
            path: "#{options[:plugin_conf_dir]}/10-memory.conf",
            content: %r{LoadPlugin memory}
          )
        end
      end

      context ':ensure => present, specific params, collectd version 5.4.2' do
        let :facts do
          facts.merge(collectd_version: '5.4.2')
        end

        it "Will create #{options[:plugin_conf_dir]}/10-memory.conf for collectd < 5.5" do
          is_expected.to contain_file('memory.load').with(
            ensure: 'present',
            path: "#{options[:plugin_conf_dir]}/10-memory.conf",
            content: %r{LoadPlugin memory}
          )
        end

        it "Will not include ValuesPercentage in #{options[:plugin_conf_dir]}10-memory.conf" do
          is_expected.not_to contain_file('memory.load').with_content(%r{ValuesPercentage})
        end
      end

      context ':ensure => present, specific params, collectd version 5.5.0' do
        let :facts do
          facts.merge(collectd_version: '5.5.0')
        end

        it 'Will create /etc/collectd.d/10-memory.conf for collectd >= 5.5' do
          is_expected.to contain_file('memory.load').with(
            ensure: 'present',
            path: "#{options[:plugin_conf_dir]}/10-memory.conf",
            content: "# Generated by Puppet\n<LoadPlugin memory>\n  Globals false\n</LoadPlugin>\n\n<Plugin memory>\n  ValuesAbsolute true\n  ValuesPercentage false\n</Plugin>\n\n"
          )
        end
      end

      context ':ensure => absent' do
        let :params do
          { ensure: 'absent' }
        end

        it "Will not create #{options[:plugin_conf_dir]}/10-memory.conf" do
          is_expected.to contain_file('memory.load').with(
            ensure: 'absent',
            path: "#{options[:plugin_conf_dir]}/10-memory.conf"
          )
        end
      end
    end
  end
end
