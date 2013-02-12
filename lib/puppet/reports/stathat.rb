require 'puppet'
require 'yaml'

begin
  require 'stathat'
rescue LoadError => e
  Puppet.info "You need the `stathat` gem to use the StatHat report"
end

Puppet::Reports.register_report(:stathat) do

  configfile = File.join([File.dirname(Puppet.settings[:config]), "stathat.yaml"])
  raise(Puppet::ParseError, "Stathat report config file #{configfile} not readable") unless File.exist?(configfile)
  config = YAML.load_file(configfile)
  STATHAT_EMAIL = config[:stathat_email]

  desc <<-DESC
  Send metrics to StatHat.
  DESC

  def process
    Puppet.debug "Sending metrics for #{self.host} to StatHat account: #{STATHAT_EMAIL}"
    self.metrics.each { |metric,data|
      data.values.each { |val|
        name = "#{self.host}.puppet.#{val[1].downcase.gsub(/\s/, '_')}_#{metric}"
        StatHat::API.ez_post_value(name, STATHAT_EMAIL, val[2])
      }
    }
  end
end
