#! /usr/bin/env ruby -w

require 'drb'
require 'drb/observer'

module Chatter
  VERSION = '1.0.0'
  SERVER = 'localhost'
  PORT = '31337'
  
  class Server
    include DRb::DRbObservable
    attr_reader :connection, :channels
    
    def initialize(server=SERVER, port=PORT)
      @connection = "druby://#{server}:#{port}"
      @channels = []
    end
    
    def self.channels
      @@channels
    end
    
    def self.run
      cs = Chatter::Server.new
      trap("INT"){ cs.broadcast(nil, "Shutting down the chat server..."); DRb.thread.kill; }
      DRb.start_service(cs.connection, cs)
      DRb.thread.join
    end
    
    def self.add_channel(channel)
      @@channels << channel unless @@channels.include?(channel)
    end
    
    def add_channel(channel)
      @channels << channel unless @channels.include?(channel)
    end
    
    def broadcast(who, msg)
      changed(true)
      notify_observers(who, msg)
    end
    
    def join(who)
      self.add_channel(who.channel)
      broadcast(nil, "#{who.name} joined #{who.channel}")
    end

    def leave(who)
      broadcast(nil, "#{who.name} left #{who.channel}")
    end
  end
  
  class Client
    include DRbUndumped
    attr_reader :name, :channel, :service
    HOME = "general"
    
    def initialize(name, service)
      @name = name
      @channel = HOME
      @service = service
      service.add_observer(self)
      self.join(@channel)
    end

    def self.connect(name, server=SERVER, port=PORT)
      DRb.start_service
      service = DRbObject.new(nil, "druby://#{server}:#{port}")
      client = Client.new(name, service)
      client.speak
    end

    def join(channel)
      @channel = channel
      @service.broadcast self, "joined #{@channel}" if defined? @service
      puts "You joined the #{@channel} channel"
    end

    def leave
      @service.broadcast self, "left #{@channel}" if defined? @service
      self.join(HOME)
    end

    def update(who, msg)
      if who
        puts "[#{who.channel}]#{who.name}: #{msg}" if who != self and who.channel == self.channel
      else  
        puts "#{msg}"
      end
    end

    def speak
      while speaking = STDIN.gets
        @service.broadcast(self, speaking.chomp) if defined? @service
      end
    end
  end
end