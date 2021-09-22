#!/usr/bin/env ruby

# Continuar daqui:
# https://www.rabbitmq.com/tutorials/tutorial-three-ruby.html
# https://www.rabbitmq.com/documentation.html

# Comandos
# docker run --rm -it --hostname rabbitmq_in_docker --name rabbitmq_in_docker -p 15672:15672 -p 5672:5672 rabbitmq:3-management

# docker container run --rm --name rb_consumer -w /srv/ -v /vagrant/teste-rabbitmq/:/srv/ --link rabbitmq_in_docker:rabbitmq_in_docker -it ruby:2.7 /bin/bash
# docker container run --rm --name rb_consumer2 -w /srv/ -v /vagrant/teste-rabbitmq/:/srv/ --link rabbitmq_in_docker:rabbitmq_in_docker -it ruby:2.7 /bin/bash
# docker container run --rm --name rb_producer -w /srv/ -v /vagrant/teste-rabbitmq/:/srv/ --link rabbitmq_in_docker:rabbitmq_in_docker -it ruby:2.7 /bin/bash
  # apt-get update -y && apt-get install -y iputils-ping && ping rabbitmq_in_docker
  # gem install bunny
  # ruby producer.rb
  # ruby consumer.rb

require 'bunny'

puts "[P] Producer initialized!"

puts "[P] Connecting to rabbitMQ ..."
connection = Bunny.new hostname: 'rabbitmq_in_docker', automatically_recover: true
connection.start
puts "[P] Connected!"

puts "[P] Creating channel and exchange, if not exists ..."
puts "[P] Do you want channel messages durable? (y/n): "
durable = gets.chomp.strip == 'y'
durable_message = durable ? 'enabled' : 'disabled'
puts "[P] Durable #{durable_message}"
channel = connection.create_channel
exchange = channel.direct('fila_do_produtor_direct', durable: durable)
exchange_name = exchange.name
puts "[P] Channel created! Direct exchange '#{exchange_name}' also created!"

puts "[P] Lets send some messages right now!"

while true
  puts "[P] Enter the message:"
  message = gets.chomp.strip
  break if message.empty?

  puts "[P] Enter the severity:"
  severity = gets.chomp.strip
  break if severity.empty?

  exchange.publish(message, routing_key: severity, persistent: durable)
  puts "[P] Message sent to exchange '#{exchange.name}': [#{severity}] '#{message}'"
end

puts "[P] Closing producer connection to RabbitMQ."
connection.close
puts "[P] Bye!"
