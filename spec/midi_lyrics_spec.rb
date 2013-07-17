require "spec_helper"

describe MidiLyrics do
  QUARTER_NOTE_DURATION = 0.417
  HALF_NOTE_DURATION = 0.875

  it "returns an array" do
    expect(MidiLyrics::Parser.new("spec/fixtures/one_note_one_syllable.mid").extract).to be_kind_of(Array)
  end

  context "file parsing" do
    it "parses one_note_one_syllable.mid correctly" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/one_note_one_syllable.mid").extract
      ).to eq([
        { text: "Test", start: 0.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r\n", start: QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 }
      ])
    end

    it "parses one_note_two_syllable.mid correctly" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/one_note_two_syllable.mid").extract
      ).to eq([
        { text: "Test One", start: 0.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r\n", start: QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 }
      ])
    end

    it "parses two_notes_one_syllable.mid correctly" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/two_notes_one_syllable.mid").extract
      ).to eq([
        { text: "Test", start: 0, start2: 0.0, duration: 0.5 + QUARTER_NOTE_DURATION },
        { text: "\r\n", start: 0.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 }
      ])
    end

    it "parses two_notes_two_syllables.mid correctly" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/two_notes_two_syllables.mid").extract
      ).to eq([
        { text: "Test", start: 0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing", start: 0.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r\n", start: 0.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 }
      ])
    end

    it "parses two_notes_three_syllables.mid correctly" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/two_notes_three_syllables.mid").extract
      ).to eq([
        { text: "Hello, test", start: 0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing", start: 0.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r\n", start: 0.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 }
      ])
    end

    it "parses spaces_and_returns.mid correctly" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/spaces_and_returns.mid").extract
      ).to eq([
        { text: "Test", start: 0.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing", start: 1, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 1 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "One", start: 1.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: " ", start: 1.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Two", start: 2.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: " ", start: 2.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Three", start: 3.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "\r\n", start: 3.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 }
      ])
    end

    it "parses repeating_lyrics.mid correctly repeating" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/repeating_lyrics.mid", repeating: true).extract
      ).to eq([
        { text: "Test", start: 0.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing", start: 0.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 0.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "One", start: 1.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: " ", start: 1.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Two", start: 1.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: " ", start: 1.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Three", start: 2.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r\n", start: 2.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Test", start: 2.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing", start: 3.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 3.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "One", start: 3.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: " ", start: 3.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Two", start: 4.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: " ", start: 4.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Three", start: 4.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r\n", start: 4.5 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 }
      ])
    end

    it "parses repeating_lyrics.mid correctly not repeating" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/repeating_lyrics.mid").extract
      ).to eq([
        { text: "Test", start: 0.0, start2: 2.5, duration: QUARTER_NOTE_DURATION },
        { text: "ing", start: 0.5, start2: 3.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 0.5 + QUARTER_NOTE_DURATION, start2: 3.0 + QUARTER_NOTE_DURATION, duration: 0.0 },
        { text: "One", start: 1.0, start2: 3.5, duration: QUARTER_NOTE_DURATION },
        { text: " ", start: 1.0 + QUARTER_NOTE_DURATION, start2: 3.5 + QUARTER_NOTE_DURATION, duration: 0.0 },
        { text: "Two", start: 1.5, start2: 4.0, duration: QUARTER_NOTE_DURATION },
        { text: " ", start: 1.5 + QUARTER_NOTE_DURATION, start2: 4.0 + QUARTER_NOTE_DURATION, duration: 0.0 },
        { text: "Three", start: 2.0, start2: 4.5, duration: QUARTER_NOTE_DURATION },
        { text: "\r\n", start: 2.0 + QUARTER_NOTE_DURATION, start2: 4.5 + QUARTER_NOTE_DURATION, duration: 0.0 }
      ])
    end

    let :parsed_complete_example do
      [
        { text: "Test", start: 0.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing", start: 1.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 1.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "One", start: 1.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: " ", start: 1.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Two", start: 2.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: " ", start: 2.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Three", start: 3.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "\r\n", start: 3.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Test", start: 4.5, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "ing", start: 5.0, start2: 0.0, duration: QUARTER_NOTE_DURATION },
        { text: "\r", start: 5.0 + QUARTER_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Four", start: 5.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: " ", start: 5.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Five", start: 6.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: " ", start: 6.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
        { text: "Six", start: 7.5, start2: 0.0, duration: HALF_NOTE_DURATION },
        { text: "\r\n", start: 7.5 + HALF_NOTE_DURATION, start2: 0.0, duration: 0.0 },
      ]
    end

    it "parses complete_example.mid correctly repeating" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/complete_example.mid").extract
      ).to eq(parsed_complete_example)
    end

    it "parses complete_example.mid correctly not repeating" do
      expect(
        MidiLyrics::Parser.new("spec/fixtures/complete_example.mid", repeating: true).extract
      ).to eq(parsed_complete_example)
    end
  end

  context "error handling" do
    it "raises MidiLyrics::FileNotFound if file does not exist" do
      expect { MidiLyrics::Parser.new("test.mid").extract }.to raise_error(MidiLyrics::FileNotFound)
    end
  end
end
