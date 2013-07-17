require "spec_helper"

describe MidiLyrics do
  QUARTER_NOTE_DURATION = 0.417
  HALF_NOTE_DURATION = 0.875

  it "returns an array" do
    expect(MidiLyrics::Parser.new("spec/fixtures/one_note_one_syllable.mid").extract).to be_kind_of(Array)
  end

  context "accessing LyricSyllable attributes" do
    let(:lyrics) { MidiLyrics::Parser.new("spec/fixtures/repeating_lyrics.mid").extract }

    it "has text method" do
      expect(lyrics[1].text).to eq("ing ")
    end

    it "has start_in_pulses method" do
      expect(lyrics[1].start_in_pulses).to eq(192)
    end

    it "has start method" do
      expect(lyrics[1].start).to eq(0.5)
    end

    it "has start2_in_pulses method" do
      expect(lyrics[1].start2_in_pulses).to eq(1152)
    end

    it "has start2 method" do
      expect(lyrics[1].start2).to eq(3.0)
    end

    it "has duration_in_pulses method" do
      expect(lyrics[1].duration_in_pulses).to eq(160)
    end

    it "has duration method" do
      expect(lyrics[1].duration).to eq(QUARTER_NOTE_DURATION)
    end
  end

  context "file parsing" do
    it "parses one_note_one_syllable.mid correctly" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/one_note_one_syllable.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, start2: x.start2, duration: x.duration } }
      expect(lyrics).to eq([
        { text: "Test ", start: 0.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "\n", start: QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 }
      ])
    end

    it "parses two_notes_one_syllable.mid correctly" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/two_notes_one_syllable.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, start2: x.start2, duration: x.duration } }
      expect(lyrics).to eq([
        { text: "Test ", start: 0, start2: 0.0, duration: 0.5 + QUARTER_NOTE_DURATION },
        { text: "\r", start: 0.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0 },
        { text: "\n", start: 0.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0 }
      ])
    end

    it "parses two_notes_two_syllables.mid correctly" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/two_notes_two_syllables.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, start2: x.start2, duration: x.duration } }
      expect(lyrics).to eq([
        { text: "Test", start: 0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing ", start: 0.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 0.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0 },
        { text: "\n", start: 0.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0 }
      ])
    end

    it "parses spaces_and_returns.mid correctly" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/spaces_and_returns.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, start2: x.start2, duration: x.duration } }
      expect(lyrics).to eq([
        { text: "Test", start: 0.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing ", start: 1, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 1 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0 },
        { text: "One", start: 1.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "Two", start: 2.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "Three ", start: 3.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "\r", start: 3.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0 },
        { text: "\n", start: 3.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0 }
      ])
    end

    it "parses repeating_lyrics.mid correctly repeating" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/repeating_lyrics.mid", repeating: true).extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, start2: x.start2, duration: x.duration } }
      expect(lyrics).to eq([
        { text: "Test", start: 0.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing ", start: 0.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 0.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "One", start: 1.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "Two", start: 1.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "Three ", start: 2.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 2.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "\n", start: 2.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Test", start: 2.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing ", start: 3.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 3.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "One", start: 3.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "Two", start: 4.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "Three ", start: 4.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 4.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "\n", start: 4.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
      ])
    end

    it "parses repeating_lyrics.mid correctly not repeating" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/repeating_lyrics.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, start2: x.start2, duration: x.duration } }
      expect(lyrics).to eq([
        { text: "Test", start: 0.0, start2: 2.5, duration: QUARTER_NOTE_DURATION },
        { text: "ing ", start: 0.5, start2: 3.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 0.5 + QUARTER_NOTE_DURATION, start2: 3.0 + QUARTER_NOTE_DURATION, duration: 0.0 },
        { text: "One", start: 1.0, start2: 3.5, duration: QUARTER_NOTE_DURATION },
        { text: "Two", start: 1.5, start2: 4.0, duration: QUARTER_NOTE_DURATION },
        { text: "Three ", start: 2.0, start2: 4.5, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 2.0 + QUARTER_NOTE_DURATION, start2: 4.5 + QUARTER_NOTE_DURATION, duration: 0.0 },
        { text: "\n", start: 2.0 + QUARTER_NOTE_DURATION, start2: 4.5 + QUARTER_NOTE_DURATION, duration: 0.0 },
      ])
    end

    let :parsed_complete_example do
      [
        { text: "Test", start: 0.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing ", start: 1.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 1.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "One", start: 1.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "Two", start: 2.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "Three ", start: 3.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "\r", start: 3.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "\n", start: 3.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Test", start: 4.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing ", start: 5.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 5.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Four", start: 5.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "Five", start: 6.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "Six ", start: 7.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "\r", start: 7.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "\n", start: 7.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
      ]
    end

    it "parses complete_example.mid correctly repeating" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/complete_example.mid").extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, start2: x.start2, duration: x.duration } }
      expect(lyrics).to eq(parsed_complete_example)
    end

    it "parses complete_example.mid correctly not repeating" do
      lyrics = MidiLyrics::Parser.new("spec/fixtures/complete_example.mid", repeating: true).extract
      lyrics = lyrics.collect{|x| { text: x.text, start: x.start, start2: x.start2, duration: x.duration } }
      expect(lyrics).to eq(parsed_complete_example)
    end
  end

  context "error handling" do
    it "raises MidiLyrics::FileNotFound if file does not exist" do
      expect { MidiLyrics::Parser.new("test.mid").extract }.to raise_error(MidiLyrics::FileNotFound)
    end
  end
end
