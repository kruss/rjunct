require "rake"
require_relative "version"
require_relative "options"
require_relative "model"
require_relative "parser"
require_relative "linker"

if ARGV.size == 0 then
  puts HELP
else
  options = Options.new()
  linker = Linker.new(options)
  linker.run()
end