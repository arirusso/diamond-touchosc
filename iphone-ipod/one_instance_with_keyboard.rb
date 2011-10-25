#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

#

require "diamond"
require "diamond-touchosc"

@output = UniMIDI::Output.gets

arpeggiator_osc_controls = {
  "/1/fader1" => { 
    :translate => -24..24,
    :action => Proc.new { |arpeggiator, val| arpeggiator.interval = val }
  },
  "/1/fader2" => { 
    :translate => -24..24,
    :action => Proc.new { |arpeggiator, val| arpeggiator.transpose = val }
  }
}

keyboard = TouchOSC::Keyboard.new do |note_num|
  note = MIDIMessage::NoteOn.new(note_num - 12, 0, 100)
  arp.add(note)
end

arpeggiator_opts = { 
  :gate => 90,   
  :interval => 7,
  :midi => @output,
  :pattern => Diamond::Pattern["UpDown"],
  :range => 4, 
  :rate => 8,
  :resolution => 128,
  :osc_map => arpeggiator_osc_controls,
  :osc_input_port => 8000
}

arp = Diamond::Arpeggiator.new(110, arpeggiator_opts)

keyboard.osc_start(:input_port => 8000)
   
arp.start(:focus => true)
