# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'midi_lyrics/version'

Gem::Specification.new do |spec|
  spec.name          = "midi_lyrics"
  spec.version       = MidiLyrics::VERSION
  spec.authors       = ["Mateus Del Bianco"]
  spec.email         = ["mateus@delbianco.net.br"]
  spec.description   = %q{MIDI Lyrics extractor}
  spec.summary       = %q{Extracts lyrics with timing from MIDI files}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_dependency("midilib", ["~> 2.0.0"])
end
