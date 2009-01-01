#!/usr/bin/env ruby
# Copyright (c) 2008 Joel Strait
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following
# conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

SAMPLES_PER_HUB = 6

# Wave header constants.
# Hammerhead assumes that all samples are:
#   16-bit
#   1 channel (mono)
#   44100 samples per second (sample rate)
# Therefore, all output Wave files will have an identical header,
# expect for the payload size.
#
# For more on Wave file specification, see:
#   http://ccrma.stanford.edu/courses/422/projects/WaveFormat/
CHUNK_ID = "RIFF"
FORMAT = "WAVE"
SUB_CHUNK1_ID = "fmt "
SUB_CHUNK1_SIZE = 16
AUDIO_FORMAT = 1
SUB_CHUNK2_ID = "data"
HEADER_SIZE = 36
NUM_CHANNELS = 1
BITS_PER_SAMPLE = 16
BYTE_RATE = 88200
BLOCK_ALIGN = 2
SAMPLE_RATE = 44100

def main
  if ARGV[0] == nil
    puts ""
	  puts "Usage:"
    puts "  ruby clawhammer.rb [path of *.hub file]"
    puts ""
    exit()
  else
    raw_file_data = read_hub_file(ARGV[0])
  end
  
	samples = []
	hub_title = ""
	SAMPLES_PER_HUB.times{ |i|	  
    # HUB Format:
    #             0: Length of HUB title
    #          1-30: HUB title. If HUB title is less than 30 bytes, remaining bytes are garbage.
    #         31-34: Length (n) sample data for next sample, unsigned little endian format.
    #            35: Flag for whether sample should be looped in Hammerhead. Ignored by Clawhammer.
    #   36-(n + 36): Raw sample data
    # This format is repeated six times, once for each sample
  
		header = raw_file_data.slice!(0..30)
    
    # Since each sample header is identical,
    # only parse the first one.
		if i == 0
			hub_title_length = header[0]
			hub_title = header[1..hub_title_length]
			puts "HUB Title: #{hub_title}"
		end
	
		sample_length = raw_file_data.slice!(0..3).unpack("V1")[0]
		
		# Ignore the loop flag byte
		raw_file_data.slice!(0)
		
		samples[i] = raw_file_data.slice!(0...sample_length)
		save_wave_file("samples/#{hub_title}-#{i + 1}.wav", samples[i])
		puts "Sample #{i + 1} extracted, #{sample_length} bytes."
	}
end

def save_wave_file(file_name, sample_data)
  # For info on Wave file specification, see:
  #   http://ccrma.stanford.edu/courses/422/projects/WaveFormat/
  
  data_length = sample_data.length
  
  # Wave Header
  file_contents = CHUNK_ID
  file_contents += [HEADER_SIZE + data_length].pack("V")
  file_contents += FORMAT
  file_contents += SUB_CHUNK1_ID
  file_contents += [SUB_CHUNK1_SIZE].pack("V")
  file_contents += [AUDIO_FORMAT].pack("v")
  file_contents += [NUM_CHANNELS].pack("v")
  file_contents += [SAMPLE_RATE].pack("V")
  file_contents += [BYTE_RATE].pack("V")
  file_contents += [BLOCK_ALIGN].pack("v")
  file_contents += [BITS_PER_SAMPLE].pack("v")
  file_contents += SUB_CHUNK2_ID
  file_contents += [data_length].pack("V")
  # Wave Payload
  file_contents += sample_data
  
  wave_file = File.open(file_name, "w")
  wave_file.syswrite(file_contents)
  wave_file.close
end

def read_hub_file(file_name)
	raw_file_data = ""
  
	hub = File.open(file_name)
	hub.each {|line| raw_file_data += line}
	hub.close()
	
	return raw_file_data
end

main()