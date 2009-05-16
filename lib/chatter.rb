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
    
    def self.run
      cs = Chatter::Server.new
      trap("INT"){ cs.broadcast(nil, "Shutting down the chat server..."); DRb.thread.kill; }
      DRb.start_service(cs.connection, cs)
      DRb.thread.join
    end
    
    def add_channel(channel)
      @channels << channel unless @channels.include?(channel)
    end
    
    def broadcast(who, msg)
      changed(true)
      notify_observers(who, msg)
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
      puts "Welcome to Chatter!"
    end

    def self.connect(name, server=SERVER, port=PORT)
      DRb.start_service
      service = DRbObject.new(nil, "druby://#{server}:#{port}")
      client = Client.new(name, service)
      client.speak
    end

    def join(channel)
      @service.broadcast self, "left #{@channel}"
      @channel = channel
      @service.broadcast self, "joined #{@channel}"
      puts "You joined the #{@channel} channel"
    end

    def update(who, msg)
      puts "[#{who.channel}]#{who.name}: #{msg}" if who != self and who.channel == self.channel
    end

    def speak
      while speaking = STDIN.gets
        if speaking =~ /^\/join\s(\S+)/
          join $1
          next
        end
        @service.broadcast(self, speaking.chomp)
      end
    end
  end
end