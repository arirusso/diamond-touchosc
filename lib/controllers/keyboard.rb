module TouchOSC
  
  class Keyboard
    
    include OSCAccessible
    
    attr_reader :connected, :octave
    
    DefaultOctave = 1
    
    def initialize(options = {}, &block)
      @octave = options[:octave] || DefaultOctave
      @maxhold = options[:max_hold] || 6
      @hold = false
      @id = options[:id] || 1

      initialize_controls
      initialize_keys(&block)
    end
    
    def octave=(val)
      @octave = val if val >= 0 && val <= 5
    end
    
    def hold(active)
      @hold = active
    end
    
    private
    
    def initialize_controls
      osc_receive("/#{@id}/kb/toggle1") { |keyboard, val| keyboard.hold(val == 1) }
      osc_receive("/#{@id}/kb/push1") { |keyboard, val| keyboard.octave -= 1 }
      osc_receive("/#{@id}/kb/push2") { |keyboard, val| keyboard.octave += 1 }
    end
    
    def initialize_keys(&block)
      regex = /\/#{@id}\/kb\/key(\d+)/
      osc_receive(regex) do |keyboard, val, msg| 
        match = msg.address.scan(regex).flatten
        unless match.empty?
          scale_degree = (match.first.to_i - 1)
          note_num = scale_degree + (12 * keyboard.octave)
          yield(val, note_num.to_i)
        end
      end
    end

  end
  
end
