module TouchOSC
  
  class Keyboard
    
    includes OSCAccessible
    
    attr_reader :connected, :octave
    
    DefaultOctave = 1
    
    osc_receive "/1/hold" { |keyboard, val| keyboard.hold(val == 1) }
    osc_receive "/1/octave_down" { |keyboard, val| keyboard.octave -= 1 }
    osc_receive "/1/octave_up" { |keyboard, val| keyboard.octave += 1 }
    
    def initialize(options = {}, &block)
      @octave = options[:octave] || DefaultOctave
      @maxhold = options[:max_hold] || 6
      @hold = false
      
      #@connected = [connected].flatten.compact
      initialize_keys(&block)
    end
    
    def octave=(val)
      @octave = val if val >= -1 && val <= 5
    end
    
    private
    
    def initialize_keys(&block)
      osc_receive "/1/key" do |keyboard, val| 
        keyboard.connected.each do |inst|
          scale_degree = val * 100
          note_num = scale_degree + (12 * (keyboard.octave + 1))
          yield(note_num)
        end
      end
    end

  end
  
end
