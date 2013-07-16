require "midi_lyrics/version"
require "midilib"

module MidiLyrics
  class FileNotFound < StandardError; end

  class LyricSyllable
    attr_accessor :text, :start_in_pulses, :duration_in_pulses
    attr_writer :sequence

    def initialize(fields = {})
      self.start_in_pulses = fields[:start_in_pulses]
      self.duration_in_pulses = fields[:duration_in_pulses]
      self.text = fields[:text]
      self.sequence = fields[:sequence]
    end

    def start
      format_time(start_in_pulses)
    end

    def duration
      format_time(duration_in_pulses)
    end

    def as_json
      hash = {
        "start" => self.start,
        "duration" => self.duration,
        "text" => self.text
      }
    #   unless start2.nil?
    #     hash.merge!("start2" => self.seq.pulses_to_seconds(self.start2.to_f).round(3))
    #   end
    #   hash
    end

    # def similar_to?(another)
    #   self.duration == another.duration && self.text == another.text
    # end

    private
    def format_time(time)
      @sequence.pulses_to_seconds(time.to_f).round(3)
    end
  end

  class Parser
    def initialize(file)
      @file = file

      unless File.exists?(@file)
        raise MidiLyrics::FileNotFound
      end
    end

    def read_sequence_from_file
      @sequence = ::MIDI::Sequence.new()
      File.open(@file, "rb") do | file |
        @sequence.read(file)
      end
      @sequence
    end

    def load_tracks
      @lyrics_track = ::MIDI::Track.new(@sequence)
      @noteon_track = ::MIDI::Track.new(@sequence)
      @sequence.tracks[1].each do | event |
        if event.kind_of?(::MIDI::MetaEvent) && event.meta_type == ::MIDI::META_LYRIC
          text = event.data.collect{|x| x.chr(Encoding::UTF_8)}.join
          if text.gsub(" ", "") != ""
            @lyrics_track.events << event
          end
        end
        if event.kind_of?(::MIDI::NoteOn)
          @noteon_track.events << event
        end
      end
    end

    def calculate_durations
      @durations = {}
      @noteon_track.each do |event|
        @durations[event.time_from_start] = event.off.time_from_start - event.time_from_start
      end
    end

    def load_lyrics
      @lyrics = @lyrics_track.collect do |event|
        LyricSyllable.new(
          :sequence => @sequence,
          :start_in_pulses => event.time_from_start,
          :duration_in_pulses => @durations[event.time_from_start],
          :text => event.data.collect{|x| x.chr(Encoding::UTF_8)}.join,
        )
      end
    end

    def remove_heading_blank_lines
      while @lyrics.first.text.strip == ""
        @lyrics.shift
      end
    end

    def consolidate_carriage_returns
      new_lyrics = []
      @lyrics.each do |l|
        if ["\r", "\n"].include?(l.text)
          l.start_in_pulses = new_lyrics.last.start_in_pulses + new_lyrics.last.duration_in_pulses
          l.duration_in_pulses = 0
          new_lyrics << l
        else
          new_lyrics << l
        end
      end
      @lyrics = new_lyrics
    end

    def extract
      read_sequence_from_file
      load_tracks
      calculate_durations
      load_lyrics
      remove_heading_blank_lines
      consolidate_carriage_returns
      @lyrics
    end
  end
end
