#
# Author:: Sander Botman <sbotman@schubergphilis.com>
# Cookbook Name:: nagios
# Library:: config_helper
#
# Copyright 2015, Sander Botman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# rubocop:disable ClassLength
#
# This class holds all nagios configuration options.
#

require 'chef/log'

# Nagios configuration options
class NagiosConfig
  attr_reader :node

  def initialize(node)
    @node = node
  end

  def config
    result = []
    config_options.each do |item|
      name, regex = item[:name], item[:regex]
      item_parse(item).each { |value| result.push(item_regex_check(name, value, regex)) }
    end
    result
  end

  private

  # rubocop:disable MethodLength
  def config_options
    [
      { name: 'log_file',
        default: "#{node['nagios']['log_dir']}/#{node['nagios']['server']['name']}.log",
        regex: file
      }, {
        name: 'cfg_file',
        default: [],
        regex: file
      }, {
        name: 'cfg_dir',
        default: [node['nagios']['config_dir']],
        regex: directory
      }, {
        name: 'object_cache_file',
        default: "#{node['nagios']['cache_dir']}/objects.cache",
        regex: file
      }, {
        name: 'precached_object_file',
        default: "#{node['nagios']['cache_dir']}/objects.precache",
        regex: file
      }, {
        name: 'resource_file',
        default: "#{node['nagios']['resource_dir']}/resource.cfg",
        regex: file
      }, {
        name: 'temp_file',
        default: "#{node['nagios']['cache_dir']}/#{node['nagios']['server']['name']}.tmp",
        regex: file
      }, {
        name: 'temp_path',
        default: '/tmp',
        regex: directory
      }, {
        name: 'status_file',
        default: "#{node['nagios']['cache_dir']}/status.dat",
        regex: file
      }, {
        name: 'status_update_interval',
        default: '10',
        regex: seconds
      }, {
        name: 'nagios_user',
        default: node['nagios']['user'],
        regex: string
      }, {
        name: 'nagios_group',
        default: node['nagios']['group'],
        regex: string
      }, {
        name: 'enable_notifications',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'execute_service_checks',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'accept_passive_service_checks',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'execute_host_checks',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'accept_passive_host_checks',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'enable_event_handlers',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'log_rotation_method',
        default: 'd',
        regex: '^[n|h|d|w|m]$'
      }, {
        name: 'log_archive_path',
        default: "#{node['nagios']['log_dir']}/archives",
        regex: directory
      }, {
        name: 'check_external_commands',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'command_check_interval',
        default: '-1',
        regex: '^(-1|(\d*)[s]?)$'
      }, {
        name: 'command_file',
        default: "#{node['nagios']['state_dir']}/rw/#{node['nagios']['server']['name']}.cmd",
        regex: file
      }, {
        name: 'external_command_buffer_slots',
        default: '4096',
        regex: digit
      }, {
        name: 'check_for_updates',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'bare_update_checks',
        default: nil,
        regex: zero_or_one
      }, {
        name: 'lock_file',
        default: "#{node['nagios']['run_dir']}/#{node['nagios']['server']['vname']}.pid",
        regex: file
      }, {
        name: 'retain_state_information',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'state_retention_file',
        default: "#{node['nagios']['state_dir']}/retention.dat",
        regex: file
      }, {
        name: 'retention_update_interval',
        default: '60',
        regex: minutes
      }, {
        name: 'use_retained_program_state',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'use_retained_scheduling_info',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'use_syslog',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'log_notifications',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'log_service_retries',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'log_host_retries',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'log_event_handlers',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'log_initial_states',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'log_external_commands',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'log_passive_checks',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'global_host_event_handler',
        default: nil,
        regex: string
      }, {
        name: 'global_service_event_handler',
        default: nil,
        regex: string
      }, {
        name: 'sleep_time',
        default: '1',
        regex: seconds
      }, {
        name: 'service_inter_check_delay_method',
        default: 's',
        regex: '^(s|n|d|\d*)$'
      }, {
        name: 'max_service_check_spread',
        default: '5',
        regex: minutes
      }, {
        name: 'service_interleave_factor',
        default: 's',
        regex: '^(s|\d*)$'
      }, {
        name: 'max_concurrent_checks',
        default: '0',
        regex: digit
      }, {
        name: 'check_result_reaper_frequency',
        default: '10',
        regex: seconds
      }, {
        name: 'max_check_result_reaper_time',
        default: '30',
        regex: seconds
      }, {
        name: 'check_result_path',
        default: "#{node['nagios']['state_dir']}/spool/checkresults",
        regex: directory
      }, {
        name: 'max_check_result_file_age',
        default: '3600',
        regex: seconds
      }, {
        name: 'host_inter_check_delay_method',
        default: 's',
        regex: '^(s|n|d|\d*)$' # We might need to improve the regex.
      }, {
        name: 'max_host_check_spread',
        default: '5',
        regex: minutes
      }, {
        name: 'interval_length',
        default: '60',
        regex: seconds
      }, {
        name: 'auto_reschedule_checks',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'auto_rescheduling_interval',
        default: '30',
        regex: seconds
      }, {
        name: 'auto_rescheduling_window',
        default: '180',
        regex: seconds
      }, {
        name: 'use_aggressive_host_checking',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'translate_passive_host_checks',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'passive_host_checks_are_soft',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'enable_predictive_host_dependency_checks',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'enable_predictive_service_dependency_checks',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'cached_host_check_horizon',
        default: '15',
        regex: seconds
      }, {
        name: 'cached_service_check_horizon',
        default: '15',
        regex: seconds
      }, {
        name: 'use_large_installation_tweaks',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'free_child_process_memory',
        default: nil,
        regex: zero_or_one
      }, {
        name: 'child_processes_fork_twice',
        default: nil,
        regex: zero_or_one
      }, {
        name: 'enable_environment_macros',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'enable_flap_detection',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'low_service_flap_threshold',
        default: '5.0',
        regex: percent
      }, {
        name: 'high_service_flap_threshold',
        default: '20.0',
        regex: percent
      }, {
        name: 'low_host_flap_threshold',
        default: '5.0',
        regex: percent
      }, {
        name: 'high_host_flap_threshold',
        default: '20.0',
        regex: percent
      }, {
        name: 'soft_state_dependencies',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'service_check_timeout',
        default: '60',
        regex: seconds
      }, {
        name: 'service_check_timeout_state',
        default: 'c',
        regex: '^(c|u|w|o)$'
      }, {
        name: 'host_check_timeout',
        default: '30',
        regex: seconds
      }, {
        name: 'event_handler_timeout',
        default: '30',
        regex: seconds
      }, {
        name: 'notification_timeout',
        default: '30',
        regex: seconds
      }, {
        name: 'ocsp_timeout',
        default: '5',
        regex: seconds
      }, {
        name: 'ochp_timeout',
        default: '5',
        regex: seconds
      }, {
        name: 'perfdata_timeout',
        default: '5',
        regex: seconds
      }, {
        name: 'obsess_over_services',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'ocsp_command',
        default: nil,
        regex: string
      }, {
        name: 'obsess_over_hosts',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'ochp_command',
        default: nil,
        regex: string
      }, {
        name: 'process_performance_data',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'host_perfdata_command',
        default: nil,
        regex: string
      }, {
        name: 'host_perfdata_file',
        default: nil,
        regex: file
      }, {
        name: 'host_perfdata_file_template',
        default: nil,
        regex: string
      }, {
        name: 'host_perfdata_file_mode',
        default: nil,
        regex: '^(a|w|p)$'
      }, {
        name: 'host_perfdata_file_processing_interval',
        default: nil,
        regex: seconds
      }, {
        name: 'host_perfdata_file_processing_command',
        default: nil,
        regex: string
      }, {
        name: 'service_perfdata_command',
        default: nil,
        regex: string
      }, {
        name: 'service_perfdata_file',
        default: nil,
        regex: file
      }, {
        name: 'service_perfdata_file_template',
        default: nil,
        regex: string
      }, {
        name: 'service_perfdata_file_mode',
        default: nil,
        regex: '^(a|w|p)$'
      }, {
        name: 'service_perfdata_file_processing_interval',
        default: nil,
        regex: seconds
      }, {
        name: 'service_perfdata_file_processing_command',
        default: nil,
        regex: string
      }, {
        name: 'check_for_orphaned_services',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'check_for_orphaned_hosts',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'check_service_freshness',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'service_freshness_check_interval',
        default: '60',
        regex: seconds
      }, {
        name: 'check_host_freshness',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'host_freshness_check_interval',
        default: '60',
        regex: seconds
      }, {
        name: 'additional_freshness_latency',
        default: '15',
        regex: seconds
      }, {
        name: 'enable_embedded_perl',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'use_embedded_perl_implicitly',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'date_format',
        default: 'iso8601',
        regex: '^(us|euro|iso8601|strict-iso8601)$'
      }, {
        name: 'use_timezone',
        default: 'UTC',
        regex: string
      }, {
        name: 'p1_file',
        default: nil,
        regex: file
      }, {
        name: 'illegal_object_name_chars',
        default: '`~!$%^&*|\'"<>?,()=',
        regex: string
      }, {
        name: 'illegal_macro_output_chars',
        default: '`~$&|\'"<>#',
        regex: string
      }, {
        name: 'use_regexp_matching',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'use_true_regexp_matching',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'admin_email',
        default: node['nagios']['sysadmin_email'],
        regex: email
      }, {
        name: 'admin_pager',
        default: node['nagios']['sysadmin_sms_email'],
        regex: string
      }, {
        name: 'event_broker_options',
        default: '-1',
        regex: '^(-1|\d*)$'
      }, {
        name: 'broker_module',
        default: [],
        regex: string
      }, {
        name: 'retained_host_attribute_mask',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'retained_service_attribute_mask',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'retained_process_host_attribute_mask',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'retained_process_service_attribute_mask',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'retained_contact_host_attribute_mask',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'retained_contact_service_attribute_mask',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'daemon_dumps_core',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'debug_file',
        default: "#{node['nagios']['state_dir']}/#{node['nagios']['server']['name']}.debug",
        regex: file
      }, {
        name: 'debug_level',
        default: '0',
        regex: '^(-1|\d*)$'
      }, {
        name: 'debug_verbosity',
        default: '1',
        regex: '^(0|1|2)$'
      }, {
        name: 'max_debug_file_size',
        default: '1000000',
        regex: digit
      }, {
        name: 'allow_empty_hostgroup_assignment',
        default: '1',
        regex: zero_or_one,
        only_if: (node['nagios']['server']['install_method'] == 'source' ||
                    (node['platform_family'] == 'rhel' && node['platform_version'].to_i >= 6) ||
                    (node['platform'] == 'debian' && node['platform_version'].to_i >= 7) ||
                    (node['platform'] == 'ubuntu' && node['platform_version'].to_f >= 14.04))
      }
    ]
  end
  # rubocop:enable MethodLength

  def digit
    '^\d*$'
  end

  def directory
    # Nothing special to check, so taking same as file
    file
  end

  def email
    # Checking for something with @
    '^.*@.*$'
  end

  def file
    '^(\/)?([^\/\0]+(\/)?)+$'
  end

  def item_attribute_exists?(name)
    return true if node['nagios']['conf'].key?(name)
    false
  end

  def item_only_if(item)
    item.key?(:only_if) ? item[:only_if] : true
  end

  def item_option(item)
    name = item[:name]
    return node['nagios']['conf'][name] if item_attribute_exists?(name)
    item[:default]
  end

  def item_parse(item)
    return [] unless item_only_if(item)
    r = item_option(item)
    case r
    when String
      [r]
    when Array
      r
    else
      []
    end
  end

  def item_regex_check(name, value, regex)
    if Regexp.new(regex).match(value)
      name + '=' + value
    else
      Chef::Log.fail("Nagios error: Wrong config option: #{value} for: #{name}")
      fail
    end
  end

  def minutes
    # Nothing special to check, so taking any kind of digit
    digit
  end

  def percent
    # Not really the best regex, but will fix later
    '(?!^0*$)(?!^0*\.0*$)^\d{1,2}(\.\d{1,2})|(100|100\.0|100\.00)?$'
  end

  def seconds
    # Nothing special to check, so taking any kind of digit
    digit
  end

  def string
    '.*'
  end

  def zero_or_one
    # Check for 0 or 1
    '^[1|0]$'
  end
end
