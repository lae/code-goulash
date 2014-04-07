#!/usr/bin/ruby

r = s = t = "_"

if ARGV[0] then
  r = "x" if ARGV[0].include?("r")
  s = "x" if ARGV[0].include?("s")
  t = "x" if ARGV[0].include?("t")
end

puts "[#{r}] rude [#{s}] same [#{t}] true"
