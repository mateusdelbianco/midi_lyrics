require "spec_helper"

describe MidiLyrics do
  QUARTER_NOTE_DURATION = 0.417
  HALF_NOTE_DURATION = 0.875

  it "returns an array" do
    expect(MidiLyrics::Parser.new("spec/fixtures/one_note_one_syllable.mid").extract).to be_kind_of(Array)
  end

  context "parsing" do
    it "parses one_note_one_syllable.mid correctly" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/one_note_one_syllable.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, duration: x.duration } }
      expect(lyrics).to eq([
        { :text => "Test ", :start => 0.0, :duration => QUARTER_NOTE_DURATION },
        { :text => "\r", :start => QUARTER_NOTE_DURATION, :duration => 0.0 },
        { :text => "\n", :start => QUARTER_NOTE_DURATION, :duration => 0.0 }
      ])
    end

    it "parses two_notes_one_syllable.mid correctly" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/two_notes_one_syllable.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, duration: x.duration } }
      expect(lyrics).to eq([
        { text: "Test ", start: 0, duration: 0.5 + QUARTER_NOTE_DURATION },
        { text: "\r", start: 0.5 + QUARTER_NOTE_DURATION, duration: 0 },
        { text: "\n", start: 0.5 + QUARTER_NOTE_DURATION, duration: 0 }
      ])
    end

    it "parses two_notes_two_syllables.mid correctly" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/two_notes_two_syllables.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, duration: x.duration } }
      expect(lyrics).to eq([
        { text: "Test", start: 0, duration: QUARTER_NOTE_DURATION },
        { text: "ing ", start: 0.5, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 0.5 + QUARTER_NOTE_DURATION, duration: 0 },
        { text: "\n", start: 0.5 + QUARTER_NOTE_DURATION, duration: 0 }
      ])
    end

    it "parses spaces_and_returns.mid correctly" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/spaces_and_returns.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, duration: x.duration } }
      expect(lyrics).to eq([
        { text: "Test", start: 0.5, duration: QUARTER_NOTE_DURATION },
        { text: "ing ", start: 1, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 1 + QUARTER_NOTE_DURATION, duration: 0 },
        { text: "One", start: 1.5, duration: HALF_NOTE_DURATION },
        { text: "Two", start: 2.5, duration: HALF_NOTE_DURATION },
        { text: "Three ", start: 3.5, duration: HALF_NOTE_DURATION },
        { text: "\r", start: 3.5 + HALF_NOTE_DURATION, duration: 0 },
        { text: "\n", start: 3.5 + HALF_NOTE_DURATION, duration: 0 }
      ])
    end
  end

  context "error handling" do
    it "raises MidiLyrics::FileNotFound if file does not exist" do
      expect { MidiLyrics::Parser.new("test.mid").extract }.to raise_error(MidiLyrics::FileNotFound)
    end
  end
end
