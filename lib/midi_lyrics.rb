require "midi_lyrics/version"
require "midilib"

module MidiLyrics
  class FileNotFound < StandardError; end

  class LyricSyllable
    attr_accessor :text, :start_in_pulses, :start2_in_pulses, :duration_in_pulses
    attr_writer :sequence

    def initialize(fields = {})
      self.start_in_pulses = fields[:start_in_pulses]
      self.start2_in_pulses = fields[:start2_in_pulses]
      self.duration_in_pulses = fields[:duration_in_pulses]
      self.text = fields[:text]
      self.sequence = fields[:sequence]
    end

    def start
      format_time(start_in_pulses)
    end

    def start2
      format_time(start2_in_pulses)
    end

    def duration
      format_time(duration_in_pulses)
    end

    def similar_to?(another)
      self.duration_in_pulses == another.duration_in_pulses && self.text == another.text
    end

    def as_json
      {
        text: text,
        start: start,
        start2: start2,
        duration: duration
      }
    end

    private
    def format_time(time)
      @sequence.pulses_to_seconds(time.to_f).round(3)
    end
  end

  class Parser
    attr_reader :file, :repeating

    def initialize(file, options = {})
      options = { repeating: false }.merge(options)
      @file = file
      @repeating = options[:repeating]

      unless File.exists?(file)
        raise MidiLyrics::FileNotFound
      end
    end

    def read_sequence_from_file
      @sequence = ::MIDI::Sequence.new()
      File.open(file, "rb") do | file |
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
          sequence: @sequence,
          start_in_pulses: event.time_from_start,
          duration_in_pulses: @durations[event.time_from_start],
          text: event.data.collect{|x| x.chr(Encoding::UTF_8)}.join,
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

    def half_is_equal
      half = @lyrics.count / 2
      (0..(half-1)).each do |x|
        unless @lyrics[x].similar_to?(@lyrics[x + half])
          return false
        end
      end
      return true
    end

    def merge_half_lyrics
      half = @lyrics.count / 2
      (0..(half-1)).collect do |x|
        @lyrics[x].start2_in_pulses = @lyrics.delete_at(half).start_in_pulses
      end
    end

    def remove_repeating
      if half_is_equal
        merge_half_lyrics
      end
    end

    def extract
      read_sequence_from_file
      load_tracks
      calculate_durations
      load_lyrics
      remove_heading_blank_lines
      consolidate_carriage_returns
      remove_repeating unless repeating
      @lyrics
    end
  end
end
