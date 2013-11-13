require "midi_lyrics/version"
require "midilib"

module MidiLyrics
  class FileNotFound < StandardError; end

  class Tempo
    attr_accessor :start, :duration, :tempo

    def initialize(fields = {})
      self.start = fields[:start].to_f
      self.tempo = fields[:tempo].to_f
    end
  end

  class TempoCalculator
    attr_accessor :tempo_track
    attr_accessor :sequence

    def initialize(fields = {})
      self.tempo_track = fields[:tempo_track]
      self.sequence = fields[:sequence]
    end

    def calculate(pulses)
      pulses = pulses.to_f
      value = 0.0
      last_tempo = @tempo_track.first
      @tempo_track.each do |t|
        if t.start < pulses
          value += (((t.start - last_tempo.start) / sequence.ppqn.to_f / ::MIDI::Tempo.mpq_to_bpm(last_tempo.tempo)) * 60.0)
          last_tempo = t
        end
      end
      if last_tempo.start < pulses
        value += (((pulses - last_tempo.start) / sequence.ppqn.to_f / ::MIDI::Tempo.mpq_to_bpm(last_tempo.tempo)) * 60.0)
      end
      value
    end
  end

  class LyricSyllable
    attr_accessor :text, :start_in_pulses, :start2_in_pulses, :duration_in_pulses
    attr_accessor :start, :start2, :duration

    def initialize(fields = {})
      self.start_in_pulses = fields[:start_in_pulses]
      self.start2_in_pulses = fields[:start2_in_pulses]
      self.duration_in_pulses = fields[:duration_in_pulses]
      self.text = fields[:text]
    end

    def end_in_pulses
      start_in_pulses + duration_in_pulses
    end

    def blank?
      text.gsub('-', '').strip == ""
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

    def extract
      read_sequence_from_file
      load_tempo_track
      load_tracks
      calculate_durations
      load_lyrics
      remove_heading_blank_lines
      consolidate_empty_syllables
      remove_lines_trailing_spaces
      fix_durations
      remove_repeating unless repeating
      calculate_seconds
      @lyrics.collect(&:as_json)
    end

    private
    def read_sequence_from_file
      @sequence = ::MIDI::Sequence.new()
      File.open(file, "rb") do |file|
        @sequence.read(file)
      end
      @sequence
    end

    def load_tempo_track
      @tempo_track = []

      @sequence.tracks[0].each do |event|
        if event.kind_of?(::MIDI::Tempo)
          @tempo_track << Tempo.new(
            start: event.time_from_start,
            tempo: event.data
          )
        end
      end

      if @tempo_track.size == 0
        @tempo_track << Tempo.new(start: 0, tempo: ::MIDI::Tempo.bpm_to_mpq(120))
      end
    end

    def load_tracks
      @lyrics_track = ::MIDI::Track.new(@sequence)
      @noteon_track = ::MIDI::Track.new(@sequence)

      @sequence.tracks[1].each do |event|
        if event.kind_of?(::MIDI::MetaEvent) && event.meta_type == ::MIDI::META_LYRIC
          @lyrics_track.events << event
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
      @lyrics = []
      @lyrics_track.each do |event|
        event_text = event.data.collect{|x| x.chr(Encoding::UTF_8)}.join
        letters = event_text.gsub(/^[\s-]+|[\s-]+$/, '')

        heading_space = event_text.match(/^([\s-]+)[^[\s-]]/)
        heading_space = heading_space[1] unless heading_space.nil?

        trailing_space = event_text.match(/([\s-]+)$/)
        trailing_space = trailing_space[1] unless trailing_space.nil?

        [heading_space, letters, trailing_space].each do |text|
          unless text.nil?
            @lyrics << LyricSyllable.new(
              start_in_pulses: event.time_from_start,
              duration_in_pulses: @durations[event.time_from_start],
              text: text
            )
          end
        end
      end
    end

    def remove_heading_blank_lines
      while @lyrics.first.blank?
        @lyrics.shift
      end
    end

    def consolidate_empty_syllables
      new_lyrics = []
      @lyrics.each do |l|
        if l.blank?
          if new_lyrics.last.blank?
            new_lyrics.last.text += l.text
          else
            l.start_in_pulses = new_lyrics.last.start_in_pulses + new_lyrics.last.duration_in_pulses
            l.duration_in_pulses = 0.0
            new_lyrics << l
          end
        else
          new_lyrics << l
        end
      end
      @lyrics = new_lyrics
    end

    def remove_lines_trailing_spaces
      @lyrics.each do |l|
        l.text.gsub!(/^[ -]*([\r\n])/, '\1')
      end
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

    def lyric_starting_at time_in_pulses
      @lyrics.find{ |l| l.duration_in_pulses != 0.0 && l.start_in_pulses == time_in_pulses }
    end

    def fix_durations
      @lyrics.each do |lyric|
        while @durations.has_key?(lyric.end_in_pulses) && lyric_starting_at(lyric.end_in_pulses).nil?
          lyric.duration_in_pulses += @durations[lyric.end_in_pulses]
        end
      end
    end

    def calculate_seconds
      tempo_calculator = TempoCalculator.new(tempo_track: @tempo_track, sequence: @sequence)

      @lyrics.each do |l|
        l.start = tempo_calculator.calculate(l.start_in_pulses).round(3)
        l.start2 = tempo_calculator.calculate(l.start2_in_pulses).round(3)
        l.duration = (tempo_calculator.calculate(l.start_in_pulses + l.duration_in_pulses) - l.start).round(3)
      end
    end
  end
end
