#!/usr/bin/env ruby

# docker run --rm -it --hostname rabbitmq_in_docker --name rabbitmq_in_docker -p 15672:15672 -p 5672:5672 rabbitmq:3.7-alpine
# docker container run --rm --name rb_consumer -w /srv/ -v /vagrant/teste-rabbitmq/:/srv/ --link rabbitmq_in_docker:rabbitmq_in_docker -it docker-registry.locaweb.com.br/buster/ruby-dev:2.6 /bin/bash
# docker container run --rm --name rb_producer -w /srv/ -v /vagrant/teste-rabbitmq/:/srv/ --link rabbitmq_in_docker:rabbitmq_in_docker -it docker-registry.locaweb.com.br/buster/ruby-dev:2.6 /bin/bash
  # apt-get update -y && apt-get install -y iputils-ping && ping rabbitmq_in_docker
  # gem install bunny

require 'bunny'

connection = Bunny.new hostname: 'rabbitmq_in_docker', automatically_recover: true
connection.start

channel = connection.create_channel
exchange = channel.topic('topic_logs')
severity = ARGV.shift || 'anonymous.info'
message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

exchange.publish(message, routing_key: severity)
puts " [x] Sent #{severity}:#{message}"

connection.close
