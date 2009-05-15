#! /usr/bin/env ruby -w

require 'test/unit'
require 'chat_server'
require 'rubygems'
require 'flexmock/test_unit'
require 'stringio'

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    $stdout = STDOUT
    return out
  end
end

class TestChatServer < Test::Unit::TestCase
  def setup
    @client = ChatClient.new("joshua")
    @server = ChatServer.new
  end
  
  def test_new_client_created
    assert_equal "joshua", @client.name
    assert_equal "general", @client.channel
  end
  
  def test_new_client_created_into_custom_channel
    client = ChatClient.new("joshua", "ruby")
    assert_equal "ruby", client.channel
  end
  
  def test_client_can_has_update
    other = ChatClient.new("fubar")
    actual = capture_stdout do
      @client.update(other,"this is a test message")
    end
    assert_equal "[general]fubar: this is a test message", actual.string.chomp
  end
  
  def test_client_can_has_server_update
    actual = capture_stdout do
      @client.update(nil, "This is a server message.")
    end
    assert_equal "This is a server message.", actual.string.chomp
  end
  
  def test_client_can_has_no_update_outside_of_channel
    other = ChatClient.new("fubar", "ruby")
    actual = @client.update(other,"you should not see this message")
    assert actual.nil?
  end
  
  def test_client_can_change_channel
    @client.join("ruby")
    assert_equal "ruby", @client.channel
  end
  
  def test_client_can_leave_channel
    @client.join("ruby")
    @client.leave
    assert_equal "general", @client.channel
  end
  
  def test_client_can_not_leave_general
    @client.leave
    assert_equal "general", @client.channel
  end
  
  def test_client_can_speak
    assert @client.respond_to?(:say)
    assert_nothing_raised do
      @client.say("Hello, World.")
    end
  end
  
  def test_server_has_general_channel
    assert_equal "general", ChatServer.channels.first
  end
  
  def test_server_tracks_new_channel
    ChatServer.add_channel "ruby"
    assert ChatServer.channels.include?("ruby")
  end
  
  def test_server_does_not_duplicate_channel
    ChatServer.add_channel "ruby"
    ChatServer.add_channel "ruby"
    ChatServer.add_channel "fubar"
    assert_equal 3, ChatServer.channels.size
  end
  
  def test_server_has_broadcast
    assert @server.respond_to?(:broadcast)
  end
  
  def test_server_has_join
    assert @server.respond_to?(:join)
  end
  
  def test_server_has_leave
    assert @server.respond_to?(:leave)
  end
end