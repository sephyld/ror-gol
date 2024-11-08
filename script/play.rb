require_relative "../config/environment"

gs = GameOfLife::GameState.new "script/state copy.txt"

gs.custom_pretty_print

while true
  sleep 1
  (gs.rows + 2).times do |i|
    print "\e[1A"
  print "\e[K"
  end
  gs.next_generation!
  gs.custom_pretty_print
end
