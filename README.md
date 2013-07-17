# MidiLyrics

[![Build Status](https://travis-ci.org/mateusdelbianco/midi_lyrics.png)](https://travis-ci.org/mateusdelbianco/midi_lyrics)
[![Code Climate](https://codeclimate.com/github/mateusdelbianco/midi_lyrics.png)](https://codeclimate.com/github/mateusdelbianco/midi_lyrics)
[![Coverage Status](https://coveralls.io/repos/mateusdelbianco/midi_lyrics/badge.png?branch=master)](https://coveralls.io/r/mateusdelbianco/midi_lyrics?branch=master)
 
## Installation

Add this line to your application's Gemfile:

    gem 'midi_lyrics'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install midi_lyrics

## Usage

    >> MidiLyrics::Parser.new("test.mid").extract
    => [
        { text: "Test", start: 0,     start2: 0.0, duration: 0.417 },
        { text: "ing ", start: 0.5,   start2: 0.0, duration: 0.417 },
        { text: "\r",   start: 0.917, start2: 0.0, duration: 0     },
        { text: "\n",   start: 0.917, start2: 0.0, duration: 0     }
      ]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
