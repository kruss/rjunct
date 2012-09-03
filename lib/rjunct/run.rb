require "rake"
require_relative "version"
require_relative "options"
require_relative "model"
require_relative "parser"
require_relative "linker"

options = Options.new()
linker = Linker.new(options)
linker.run()