require 'rspec'
require 'socket'

module Fluent
  class Plugin; end
  class Output
    def start; end
  end
  class OpenTsdbOutput < Output; end
end

describe "fluentd opentsdb plugin" do
  before do
    Fluent::Plugin.should_receive(:register_output).at_most(:once)
    Fluent::OpenTsdbOutput.should_receive(:config_param).at_most(7).times
    require File.join(File.dirname(__FILE__), '..','lib/fluent/plugin/out_opentsdb')
    $log = log
  end

  let(:log) {
    l = double('log')
    l.stub :info
    l.stub :debug
    l
  }
  let(:monitor_key_tag) { "some_monitor_key_tag" }

  let(:plugin) {
    p = Fluent::OpenTsdbOutput.new
    p.instance_variable_set("@monitor_key_tag", monitor_key_tag)
    p
  }

  let(:metric_name)      { "some_metric_name" }
  let(:metric_value)     { 3.14159 }
  let(:timestamp)        { Time.now.to_i }
  let(:monitor_key_name) { "some_monitor_key_name" }

  describe "#put_metric" do

    subject { plugin.put_metric metric_name, metric_value, timestamp, monitor_key_name }

    it "creates proper TSD put string" do
      s = double('socket')
      TCPSocket.should_receive(:new).and_return(s)
      s.should_receive(:puts).with "put #{metric_name} #{timestamp} #{metric_value} #{monitor_key_tag}=#{monitor_key_name}"
      s.should_receive :close
      subject
    end

    let(:error) { Errno::ECONNREFUSED.new "None shall pass!" }
    it "handles 'connection refused' error gracefully" do
      TCPSocket.should_receive(:new).and_raise(error)
      log.should_receive(:warn).with /refused/, kind_of(Hash)
      expect { subject }.to_not raise_error
    end
  end
end
