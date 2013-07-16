require "spec_helper"

describe MidiLyrics do
  QUARTER_NOTE_DURATION = 0.417
  HALF_NOTE_DURATION = 0.875

  it "returns an array" do
    expect(MidiLyrics::Parser.new("spec/fixtures/one_note_one_syllable.mid").extract).to be_kind_of(Array)
  end

  context "one_note_one_syllable.mid" do
    before do
      @lyrics = MidiLyrics::Parser.new("spec/fixtures/one_note_one_syllable.mid").extract
    end

    it "returns an array with 3 elements" do
      expect(@lyrics.size).to eq(3)
    end

    it "sets the first syllable" do
      expect(@lyrics[0].text).to eq("Test ")
      expect(@lyrics[0].start).to eq(0)
      expect(@lyrics[0].duration).to eq(QUARTER_NOTE_DURATION)
    end

    it "sets the second and third syllable" do
      expect(@lyrics[1].text).to eq("\r")
      expect(@lyrics[1].start).to eq(QUARTER_NOTE_DURATION)
      expect(@lyrics[1].duration).to eq(0)

      expect(@lyrics[2].text).to eq("\n")
      expect(@lyrics[2].start).to eq(QUARTER_NOTE_DURATION)
      expect(@lyrics[2].duration).to eq(0)
    end
  end

  context "two_notes_one_syllable.mid" do
    before do
      @lyrics = MidiLyrics::Parser.new("spec/fixtures/two_notes_one_syllable.mid").extract
    end

    it "returns an array with 3 elements" do
      expect(@lyrics.size).to eq(3)
    end

    it "sets the first syllable" do
      expect(@lyrics[0].text).to eq("Test ")
      expect(@lyrics[0].start).to eq(0)
      expect(@lyrics[0].duration).to eq(0.5 + QUARTER_NOTE_DURATION)
    end

    it "sets the second and third syllable" do
      expect(@lyrics[1].text).to eq("\r")
      expect(@lyrics[1].start).to eq(0.5 + QUARTER_NOTE_DURATION)
      expect(@lyrics[1].duration).to eq(0)

      expect(@lyrics[2].text).to eq("\n")
      expect(@lyrics[2].start).to eq(0.5 + QUARTER_NOTE_DURATION)
      expect(@lyrics[2].duration).to eq(0)
    end
  end

  context "two_notes_two_syllables.mid" do
    before do
      @lyrics = MidiLyrics::Parser.new("spec/fixtures/two_notes_two_syllables.mid").extract
    end

    it "returns an array with 4 elements" do
      expect(@lyrics.size).to eq(4)
    end

    it "sets the first syllable" do
      expect(@lyrics[0].text).to eq("Test")
      expect(@lyrics[0].start).to eq(0)
      expect(@lyrics[0].duration).to eq(QUARTER_NOTE_DURATION)
    end

    it "sets the second syllable" do
      expect(@lyrics[1].text).to eq("ing ")
      expect(@lyrics[1].start).to eq(0.5)
      expect(@lyrics[1].duration).to eq(QUARTER_NOTE_DURATION)
    end

    it "sets the third and fourth syllable" do
      expect(@lyrics[2].text).to eq("\r")
      expect(@lyrics[2].start).to eq(0.5 + QUARTER_NOTE_DURATION)
      expect(@lyrics[2].duration).to eq(0)

      expect(@lyrics[3].text).to eq("\n")
      expect(@lyrics[3].start).to eq(0.5 + QUARTER_NOTE_DURATION)
      expect(@lyrics[3].duration).to eq(0)
    end
  end

  context "spaces_and_returns.mid" do
    before do
      @lyrics = MidiLyrics::Parser.new("spec/fixtures/spaces_and_returns.mid").extract
    end

    it "returns an array with 8 elements" do
      expect(@lyrics.size).to eq(8)
    end

    it "sets the first syllable" do
      expect(@lyrics[0].text).to eq("Test")
      expect(@lyrics[0].start).to eq(0.5)
      expect(@lyrics[0].duration).to eq(QUARTER_NOTE_DURATION)
    end

    it "sets the second syllable" do
      expect(@lyrics[1].text).to eq("ing ")
      expect(@lyrics[1].start).to eq(1)
      expect(@lyrics[1].duration).to eq(QUARTER_NOTE_DURATION)
    end

    it "sets the third and fourth syllable" do
      expect(@lyrics[2].text).to eq("\r")
      expect(@lyrics[2].start).to eq(1 + QUARTER_NOTE_DURATION)
      expect(@lyrics[2].duration).to eq(0)
    end

    it "sets the fifth syllable" do
      expect(@lyrics[3].text).to eq("One")
      expect(@lyrics[3].start).to eq(1.5)
      expect(@lyrics[3].duration).to eq(HALF_NOTE_DURATION)
    end

    it "sets the sixth syllable" do
      expect(@lyrics[4].text).to eq("Two")
      expect(@lyrics[4].start).to eq(2.5)
      expect(@lyrics[4].duration).to eq(HALF_NOTE_DURATION)
    end

    it "sets the seventh syllable" do
      expect(@lyrics[5].text).to eq("Three ")
      expect(@lyrics[5].start).to eq(3.5)
      expect(@lyrics[5].duration).to eq(HALF_NOTE_DURATION)
    end

    it "sets the eigth and nineth syllable" do
      expect(@lyrics[6].text).to eq("\r")
      expect(@lyrics[6].start).to eq(3.5 + HALF_NOTE_DURATION)
      expect(@lyrics[6].duration).to eq(0)

      expect(@lyrics[7].text).to eq("\n")
      expect(@lyrics[7].start).to eq(3.5 + HALF_NOTE_DURATION)
      expect(@lyrics[7].duration).to eq(0)
    end
  end

  context "error handling" do
    it "raises MidiLyrics::FileNotFound if file does not exist" do
      expect { MidiLyrics::Parser.new("test.mid").extract }.to raise_error(MidiLyrics::FileNotFound)
    end
  end
end
