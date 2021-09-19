#!/usr/bin/env ruby

require 'bunny'

puts "[C] Consumer initialized!"

puts "[C] Connecting to rabbitMQ ..."
connection = Bunny.new hostname: 'rabbitmq_in_docker', automatically_recover: true
connection.start
puts "[C] Connected!"

puts "[C] Creating channel and queue, if not exists ..."
puts "[C] Do you want channel messages durable? (y/n): "
durable = gets.chomp.strip == 'y'
durable_message = durable ? 'enabled' : 'disabled'
puts "[C] Durable #{durable_message}"
channel = connection.create_channel
queue = channel.queue('fila_do_produtor', durable: durable)
queue_name = queue.name
puts "[C] Channel created! Queue '#{queue_name}' also created!"

puts "[C] Lets receive some messages right now!"
begin
  puts "[C] Do you want manual ack? (y/n):"
  manual_ack = gets.chomp.strip == 'y'
  manual_ack_message = manual_ack ? 'enabled' : 'disabled'
  puts "[C] Manual ack #{manual_ack_message}"

  puts '[C] Waiting for messages ...'

  queue.subscribe(block: true, manual_ack: manual_ack) do |delivery_info, properties, body|
    puts "[C] Received message: '#{body}'"

    if manual_ack
      puts "[C] Ack for message '#{body}'? (y/n):"
      ack = gets.chomp.strip == 'y'

      if ack
        channel.ack(delivery_info.delivery_tag)
        puts "[C] Manual acked for message '#{body}'"
      else
        puts "[C] Not acked for message '#{body}'"
      end
    else
      puts "[C] Acked automatically for message '#{body}'"
    end
  end
rescue Interrupt => _
  puts "[C] Aborting ... closing consumer connection to RabbitMQ."
  connection.close
  puts "[C] Bye!"

  exit(0)
end

puts "[C] Closing consumer connection to RabbitMQ."
connection.close
puts "[C] Bye!"
