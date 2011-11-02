module TouchOSC
  
  class Keyboard
    
    include OSCAccessible
    
    attr_reader :connected, :octave
    
    DefaultOctave = 1
    
    def initialize(options = {}, &block)
      @octave = options[:octave] || DefaultOctave
      @maxhold = options[:max_hold] || 6
      @holding = nil
      @on_play = block
      @id = options[:id] || 1

      initialize_controls
      initialize_keys(&@on_play)
    end
    
    def octave=(val)
      @octave = val if val >= 0 && val <= 5
    end
    
    def hold=(active)
      if !active
        @holding.each { |note_num| @on_play.call(0, note_num) } unless @holding.nil?
        @holding = nil
      else
        @holding = []
      end
      !@holding.nil?      
    end
    
    def hold?
      !@holding.nil?
    end
    alias_method :hold, :hold?
    
    protected
    
    def update_octave_label
      osc_send(:octave)
    end
    
    private
    
    def initialize_controls
      osc_receive("/#{@id}/kb/toggle1", :accessor => :hold)
      osc_receive("/#{@id}/kb/label3", :initialize => :octave)
      osc_receive("/#{@id}/kb/push1") do |keyboard, val| 
        keyboard.octave -= 1 if val > 0
        keyboard.send(:update_octave_label)
      end
      osc_receive("/#{@id}/kb/push2") do |keyboard, val| 
        keyboard.octave += 1 if val > 0
        keyboard.send(:update_octave_label)
      end
    end
    
    def initialize_keys(&block)
      regex = /\/#{@id}\/kb\/key(\d+)/
      osc_receive(regex) do |keyboard, val, msg| 
        match = msg.address.scan(regex).flatten
        unless match.empty?
          scale_degree = (match.first.to_i - 1)
          note_num = scale_degree + (12 * keyboard.octave)
          if val.to_i.zero? && hold?
            @holding.shift if @holding.size >= @maxhold
            @holding << note_num.to_i
          else
            yield(val, note_num.to_i)
          end
        end
      end
    end

  end
  
end
