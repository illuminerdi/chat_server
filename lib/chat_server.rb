#! /usr/bin/env ruby -w

require 'drb'
require 'drb/observer'

class ChatServer
  include DRb::DRbObservable
  VERSION = '0.0.1'
  @@channels = ["general"]
  attr_reader :connection
  
  def initialize(server='localhost', port='31337')
    @connection = "druby://#{server}:#{port}"
  end
  
  def self.channels
    @@channels
  end
  
  def self.run
    cs = ChatServer.new
    trap("INT"){ cs.broadcast(nil, "Shutting down the chat server..."); DRb.thread.kill; }
    DRb.start_service(cs.connection, cs)
    DRb.thread.join
  end
  
  def self.add_channel(channel)
    @@channels << channel unless @@channels.include?(channel)
  end
  
  def broadcast(who, msg)
    changed(true)
    notify_observers(who, msg)
  end
  
  def join(who)
    broadcast(nil, "#{who.name} joined #{who.channel}")
  end
  
  def leave(who)
    broadcast(nil, "#{who.name} left #{who.channel}")
  end
end

class ChatClient
  include DRbUndumped
  attr_reader :name, :channel
  HOME = "general"
  def initialize(name, channel=HOME, server='localhost', port='31337')
    @name = name
    @channel = channel
    @connection = "druby://#{server}:#{port}"
  end
  
  def connect
    DRb.start_service
    server = DRbObject.new(nil, @connection)
    @service = server
    server.add_observer(self)
  end
  
  def join(channel)
    @channel = channel
    @service.join self if @service
  end
  
  def leave
    @service.leave self if @service
    self.join(HOME)
  end
  
  def update(who, msg)
    if who
      puts "[#{who.channel}]#{who.name}: #{msg}" if who.channel == self.channel
    else  
      puts "#{msg}"
    end
  end
  
  def say(msg)
    @service.broadcast(self, msg) if @service
  end
end