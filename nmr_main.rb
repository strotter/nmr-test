# nmr_main.rb - Uses console input to generate signal output using NMR::Predictor

require_relative 'nmr_predictor'

include NMR

# Loop input on the console and generate signals based on alkane names.
input = ""
while true
  begin
    puts "\n-- Alkane name ('q' to quit): "
    input = readline.chomp
    break if input == 'q'
    puts "-- Signals for " + input + ":\n"
    predictor = Predictor.new(input)
    predictor.signal_names.each { |signal| puts signal }
  rescue ArgumentError => ae
    puts "An argument exception occurred: " + ae.message
    puts ae.backtrace.inspect
  rescue Exception => e
    puts "A fatal error occurred: " + e.message
    puts e.backtrace.inspect
  end
end