[![Build Status](https://travis-ci.org/bnugmanov/fluent-plugin-opentsdb.png)](https://travis-ci.org/bnugmanov/fluent-plugin-opentsdb)

# fluent-plugin-opentsdb, a plugin for [Fluentd](http://fluentd.org)

## Component

### OpenTsdbOutput

Plugin to graph fluent-plugin-numeric-monitor values in OpenTSDB

## Configuration

### OpenTsdbOutput

Given a fluent-plugin-numeric-monitor configuration like the following:

    <match apache.log.**>
      type numeric_monitor
      unit minute
      tag monitor.duration
      aggregate tag
      input_tag_remove_prefix apache.log
      monitor_key duration
      percentiles 90,95
    </match>

To graph in OpenTSDB:

	<match monitor.duration>
	    type opentsdb
	    host localhost
	    port 4242
		metric_prefix    http
		metric_num	     hits
		metric_durations latency
		monitor_key_tag	action
		tags	env, localhost
	</match>

Will send OpenTSDB put commands like the following:

	put http.latency.pct90 1358206603 79668.0 action=samplepage, env=localhost
	put http.latency.pct90 1358206603 85224.0 action=samplepage, env=localhost
	put http.hits 1358206603 103 action=samplepage, env=localhost

## TODO

* more tests
* more documents

## License

* License
  * Apache License, Version 2.0
