module Fluent
class OpenTsdbOutput < Output
  Fluent::Plugin.register_output("opentsdb", self)

  config_param :host, :string, :default => 'localhost'
  config_param :port, :integer, :default => 4242
  config_param :metric_prefix, :string, :default => 'monitor'
  config_param :metric_num, :string, :default => 'num'
  config_param :metric_durations, :string, :default => 'duration'
  config_param :tags, :string, :default => nil
  config_param :monitor_key_tag, :string, :default => 'key'

  def configure(conf)
    super
  end

  def start
    super
    # try a connection so can fail the process on incorrect host and port config
    @socket = TCPSocket.new(@host, @port)
    $log.info "connected to opentsdb at #{@host}:#{@port}"
    @socket.close
  end
  
  def shutdown
    super
    @socket.shutdown(Socket::SHUT_RDWR) unless @socket.nil?
  end

  def emit(tag, es, chain)
    es.each do |time,record|
      $log.debug "opentsdb output processing record #{record}"
      record.each do |metric, value|
        value = 0 if value.nil? or value.to_s.empty?
        #$log.debug "metric[-4,4]=#{metric[-4,4]}, metric[-14..-3]=#{metric[-14..-3]}"
        if metric[-4, 4] == '_num'
          name = [@metric_prefix, @metric_num].join('.')
          put_metric(name, value, time, metric[0..-5])
        elsif metric[-14..-3] == '_percentile_'
          name = [@metric_prefix, @metric_durations, 'pct' + metric[-2,2]].join('.')        
          put_metric(name, value, time, metric[0..-15])
        else
          name = [@metric_prefix, @metric_durations, metric[-3, 3]].join('.')
          put_metric(name, value, time, metric[0..-5])
        end
      end      
    end

    chain.next
  end
  
  def put_metric(name, value, time, monitor_key_name)
    tags = [@monitor_key_tag, monitor_key_name].join('=')
    unless @tags.nil? 
      i = 0;
      @tags.gsub(/ /, '').split(',').each do |val|
        tags << (i == 0 ? ' ' : '')
        tags << (i % 2 == 0 ? "#{val}=" : "#{val} ")
        i += 1
      end
    end
    message = ['put', name, time, value, tags].join(' ')
    #$log.debug message
    begin
      @socket = TCPSocket.new(@host, @port)
      $log.debug "connected to opentsdb at #{@host}:#{@port}"
      @socket.puts(message)
      @socket.close
    rescue SocketError => e
      $log.warn("Error connecting to opentsdb server",
                 :exception => e, :host => @host, :port => @port)
    end
  end   
end
end
