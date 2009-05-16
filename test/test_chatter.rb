#! /usr/bin/env ruby -w

require 'test/unit'
require 'chatter'
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

class TestChatter < Test::Unit::TestCase
  def setup
    @server = Chatter::Server.new
    capture_stdout do
      @client = Chatter::Client.new("joshua", @server)
    end
  end

  def test_new_client_created
    assert_equal "joshua", @client.name
    assert_equal "general", @client.channel
  end

  def test_client_can_has_update
    actual = capture_stdout do
      other = Chatter::Client.new("fubar", @server)
      @client.update(other,"this is a test message")
    end
    assert_match /\[general\]fubar: this is a test message/, actual.string.chomp
  end

  def test_client_can_has_server_update
    actual = capture_stdout do
      @client.join "ruby"
    end
    assert_equal "You joined the ruby channel", actual.string.chomp
  end

  def test_client_can_has_no_update_outside_of_channel
    actual = capture_stdout do
      other = Chatter::Client.new("fubar", @server)
      other.join "ruby"
      @client.update(other,"you should not see this message")
    end
    assert !actual.string.match(/you should not see this message/)
  end

  def test_client_can_change_channel
    capture_stdout do
      @client.join("ruby")
    end
    assert_equal "ruby", @client.channel
  end

  def test_client_can_leave_channel
    actual = capture_stdout do
      @client.join("ruby")
      @client.join("general")
    end
    actual.string.split("\n").each do |line|
      assert_match /You joined the (ruby|general) channel/, line
    end
    assert_equal "general", @client.channel
  end

  def test_server_has_no_channels_at_start
    assert_equal [], @server.channels
  end

  def test_server_tracks_new_channel
    @server.add_channel "ruby"
    assert @server.channels.include?("ruby")
  end

  def test_server_does_not_duplicate_channel
    @server.add_channel "ruby"
    @server.add_channel "ruby"
    @server.add_channel "fubar"
    assert_equal 2, @server.channels.size
  end

  def test_server_has_broadcast
    assert @server.respond_to?(:broadcast)
  end

  def test_basic_conversation
    actual = capture_stdout do
      other = Chatter::Client.new("fubar", @server)
      @server.broadcast other, "Hello"
      @server.broadcast @client, "Hey there!"
      other.join "ruby"
    end
    expected = "[general]fubar: Hello\n[general]joshua: Hey there!\n[general]fubar: left general\nYou joined the ruby channel"
    assert_equal expected, actual.string.chomp
  end

  def test_person_leaves_and_broadcasts_and_other_person_does_not_receive
    actual = capture_stdout do
      other = Chatter::Client.new("fubar", @server)
      @client.join "ruby"
      @server.broadcast other, "H... Hello?"
    end
    assert !actual.string.match("H... Hello?")
  end
end