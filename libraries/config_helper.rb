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
      n = item[:name]
      r = item[:regex]
      parse_item(item).each do |v|
        if Regexp.new(r).match(v)
          config_item = n + '=' + v
          result.push(config_item)
        else
          Chef::Log.warn("Cannot process: #{item[:name]}, please check your configuration")
          Chef::Log.warn("Wrong value: #{v}")
        end
      end
    end
    result
  end

  private

  def attribute_exists?(name)
    return true if node['nagios']['conf'].key?(name)
    false
  end

  def item_option(item)
    name = item[:name]
    return node['nagios']['conf'][name] if attribute_exists?(name)
    item[:default]
  end

  def parse_item(item)
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

  def digit
    '^\d*$'
  end

  def file
    '^(\/)?([^\/\0]+(\/)?)+$'
  end

  def string
    '.*'
  end

  def zero_or_one
    '^[1|0]$'
  end

  def seconds
    '^(-1|(\d*)[s]?)$'
  end

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
        regex: file
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
        regex: file
      }, {
        name: 'status_file',
        default: "#{node['nagios']['cache_dir']}/status.dat",
        regex: file
      }, {
        name: 'status_update_interval',
        default: '10',
        regex: digit
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
        regex: file
      }, {
        name: 'check_external_commands',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'command_check_interval',
        default: '',
        regex: seconds
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
        regex: digit
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
        regex: digit
      }, {
        name: 'service_inter_check_delay_method',
        default: 's',
        regex: '^(s|n|d|\d*)$'
      }, {
        name: 'max_service_check_spread',
        default: '5',
        regex: digit
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
        regex: digit
      }, {
        name: 'max_check_result_reaper_time',
        default: '30',
        regex: digit
      }, {
        name: 'check_result_path',
        default: "#{node['nagios']['state_dir']}/spool/checkresults",
        regex: file
      }, {
        name: 'max_check_result_file_age',
        default: '3600',
        regex: digit
      }, {
        name: 'host_inter_check_delay_method',
        default: 's',
        regex: '^(s|n|d|\d*)$'
      }, {
        name: 'max_host_check_spread',
        default: '5',
        regex: digit
      }, {
        name: 'interval_length',
        default: '60',
        regex: digit
      }, {
        name: 'auto_reschedule_checks',
        default: '0',
        regex: zero_or_one
      }, {
        name: 'auto_rescheduling_interval',
        default: '30',
        regex: digit
      }, {
        name: 'auto_rescheduling_window',
        default: '180',
        regex: digit
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
        regex: digit
      }, {
        name: 'cached_service_check_horizon',
        default: '15',
        regex: digit
      }, {
        name: 'use_large_installation_tweaks',
        default: '15',
        regex: digit
      }, {
        name: 'free_child_process_memory',
        default: '1',
        regex: zero_or_one
      }, {
        name: 'child_processes_fork_twice',
        default: '1',
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
        default: '',
        regex: '.*'
      }, {
        name: 'high_service_flap_threshold',
        default: '',
        regex: '.*'
      }, {
        name: 'low_host_flap_threshold',
        default: '',
        regex: '.*'
      }, {
        name: 'high_host_flap_threshold',
        default: '',
        regex: '.*'
      }, {
        name: 'soft_state_dependencies',
        default: '',
        regex: '.*'
      }, {
        name: 'service_check_timeout',
        default: '',
        regex: '.*'
      }, {
        name: 'service_check_timeout_state',
        default: '',
        regex: '.*'
      }, {
        name: 'host_check_timeout',
        default: '',
        regex: '.*'
      }, {
        name: 'event_handler_timeout',
        default: '',
        regex: '.*'
      }, {
        name: 'notification_timeout',
        default: '',
        regex: '.*'
      }, {
        name: 'ocsp_timeout',
        default: '',
        regex: '.*'
      }, {
        name: 'ochp_timeout',
        default: '',
        regex: '.*'
      }, {
        name: 'perfdata_timeout',
        default: '',
        regex: '.*'
      }, {
        name: 'obsess_over_services',
        default: '',
        regex: '.*'
      }, {
        name: 'ocsp_command',
        default: '',
        regex: '.*'
      }, {
        name: 'obsess_over_hosts',
        default: '',
        regex: '.*'
      }, {
        name: 'ochp_command',
        default: '',
        regex: '.*'
      }, {
        name: 'process_performance_data',
        default: '',
        regex: '.*'
      }, {
        name: 'host_perfdata_command',
        default: '',
        regex: '.*'
      }, {
        name: 'service_perfdata_command',
        default: '',
        regex: '.*'
      }, {
        name: 'host_perfdata_file',
        default: '',
        regex: '.*'
      }, {
        name: 'service_perfdata_file',
        default: '',
        regex: '.*'
      }, {
        name: 'host_perfdata_file_template',
        default: '',
        regex: '.*'
      }, {
        name: 'service_perfdata_file_template',
        default: '',
        regex: '.*'
      }, {
        name: 'host_perfdata_file_mode',
        default: '',
        regex: '.*'
      }, {
        name: 'service_perfdata_file_mode',
        default: '',
        regex: '.*'
      }, {
        name: 'host_perfdata_file_processing_interval',
        default: '',
        regex: '.*'
      }, {
        name: 'service_perfdata_file_processing_interval',
        default: '',
        regex: '.*'
      }, {
        name: 'host_perfdata_file_processing_command',
        default: '',
        regex: '.*'
      }, {
        name: 'service_perfdata_file_processing_command',
        default: '',
        regex: '.*'
      }, {
        name: 'check_for_orphaned_services',
        default: '',
        regex: '.*'
      }, {
        name: 'check_for_orphaned_hosts',
        default: '',
        regex: '.*'
      }, {
        name: 'check_service_freshness',
        default: '',
        regex: '.*'
      }, {
        name: 'service_freshness_check_interval',
        default: '',
        regex: '.*'
      }, {
        name: 'check_host_freshness',
        default: '',
        regex: '.*'
      }, {
        name: 'host_freshness_check_interval',
        default: '',
        regex: '.*'
      }, {
        name: 'additional_freshness_latency',
        default: '',
        regex: '.*'
      }, {
        name: 'enable_embedded_perl',
        default: '',
        regex: '.*'
      }, {
        name: 'use_embedded_perl_implicitly',
        default: '',
        regex: '.*'
      }, {
        name: 'date_format',
        default: '',
        regex: '.*'
      }, {
        name: 'use_timezone',
        default: '',
        regex: '.*'
      }, {
        name: 'illegal_object_name_chars',
        default: '',
        regex: '.*'
      }, {
        name: 'illegal_macro_output_chars',
        default: '',
        regex: '.*'
      }, {
        name: 'use_regexp_matching',
        default: '',
        regex: '.*'
      }, {
        name: 'use_true_regexp_matching',
        default: '',
        regex: '.*'
      }, {
        name: 'admin_email',
        default: node['nagios']['sysadmin_email'],
        regex: '.*',
        attribute: node['nagios']['sysadmin_email']
      }, {
        name: 'admin_pager',
        default: '',
        regex: '.*'
      }, {
        name: 'event_broker_options',
        default: '',
        regex: '.*'
      }, {
        name: 'broker_module',
        default: '',
        regex: '.*'
      }, {
        name: 'debug_file',
        default: '',
        regex: '.*'
      }, {
        name: 'debug_level',
        default: '',
        regex: '.*'
      }, {
        name: 'debug_verbosity',
        default: '',
        regex: '.*'
      }, {
        name: 'max_debug_file_size',
        default: '',
        regex: '.*'
      }, {
        name: 'allow_empty_hostgroup_assignment',
        default: '',
        regex: '.*'
      }
    ]
  end
end
