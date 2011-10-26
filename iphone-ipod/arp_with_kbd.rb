#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#

require "diamond"
require "diamond-touchosc"

@output = UniMIDI::Output.gets

arpeggiator_osc_controls = {
  "/1/rotary1" => { 
    :translate => 30..230,
    :action => Proc.new { |arpeggiator, val| arpeggiator.tempo = val }
  },
  "/1/multifader1/1" => {
    :translate => [128, 64, 32, 24, 16, 12, 8, 4, 2, 1],
    :action => Proc.new { |arpeggiator, val| arpeggiator.rate = val }
  },
  "/1/multifader1/2" => {
    :translate => 1..200,
    :action => Proc.new { |arpeggiator, val| arpeggiator.gate = val }
  },
  "/1/multifader1/3" => {
    :translate => 0..7,
    :action => Proc.new { |arpeggiator, val| arpeggiator.range = val }
  },
  "/1/multifader1/4" => {
    :translate => -24..24,
    :action => Proc.new { |arpeggiator, val| arpeggiator.interval = val }
  },
  "/1/multifader1/5" => {
    :translate => -10..10,
    :action => Proc.new { |arpeggiator, val| arpeggiator.pattern_offset = val }
  },
  "/1/multifader1/6" => {
    :translate => -24..24,
    :action => Proc.new { |arpeggiator, val| p val; arpeggiator.transpose = val }
  },
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
  :osc_output => { :host => "192.168.1.5", :port => 9000 }
}

arp = Diamond::Arpeggiator.new(110, arpeggiator_opts)

arp.osc_send("/1/rotary1", (arp.tempo / 1000))

keyboard = TouchOSC::Keyboard.new do |pressure, note_num|
  note = MIDIMessage::NoteOn.new(0, note_num, 100)
  action = pressure > 0 ? :add : :remove
  arp.send(action, note)
end

keyboard.osc_start(:input_port => 8000)

arp.start(:focus => true)
