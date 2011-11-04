#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')
#

require "diamond"
require "diamond-touchosc"

@output = UniMIDI::Output.gets

arpeggiator_osc_controls = {
  "/1/toggle1" => {
    :accessor => :running,
    :translate => :boolean
  },
  "/1/toggle2" => {
    :accessor => :mute,
    :translate => :boolean
  },
  "/1/push1" => {
    :accessor => :reset
  },
  "/1/rotary1" => { 
    :accessor => :tempo,
    :translate => 30..230,
    :action => Proc.new { |arp, val| arp.osc_send("/1/text6", val) }
  },
  "/1/rotary2" => {
    :accessor => :rate,
    :translate => [128, 64, 32, 24, 16, 12, 8, 4, 2, 1],
    :action => Proc.new { |arp, val| arp.osc_send("/1/text1", "1 / #{val}") }
  },
  "/1/rotary3" => {
    :accessor => :gate,
    :translate => 1..200,
    :action => Proc.new { |arp, val| arp.osc_send("/1/text2", "#{val}%") }
  },
  "/1/rotary4" => {
    :accessor => :range,
    :translate => 0..7,
    :action => Proc.new { |arp, val| arp.osc_send("/1/text3", val) }
  },
  "/1/rotary5" => {
    :accessor => :interval,
    :translate => -24..24,
    :action => Proc.new { |arp, val| arp.osc_send("/1/text4", val) }
  },
  "/1/rotary6" => Proc.new do |arp, val| 
    index = arp.osc_translate(val, (0..(Diamond::Pattern.patterns.size - 1)))
    pattern = Diamond::Pattern.patterns[index]
    arp.pattern = pattern
    arp.osc_send("/1/text5", pattern.name.to_s)
  end,
  "/1/fader1" => {
    :accessor => :transpose,
    :translate => -24..24,
    :action => Proc.new { |arp, val| arp.osc_send("/1/text7", val) }
  }
}

arpeggiator_opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8,
  :resolution => 128,
  :osc_map => arpeggiator_osc_controls,
  :osc_input_port => 8000,
  :osc_output => { :host => "192.168.1.6", :port => 9000 }
}

arp = Diamond::Arpeggiator.new(110, arpeggiator_opts)

keyboard = TouchOSC::Keyboard.new do |pressure, note_num|
  note = MIDIMessage::NoteOn.new(0, note_num, 100)
  action = pressure > 0 ? :add : :remove
  arp.send(action, note)
end

keyboard.osc_start(:input_port => 8000).join
