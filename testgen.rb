#!/usr/bin/ruby
#This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# For information, please contact: adenilso@icmc.usp.br

require 'json'
require 'open3'
include Open3
require('./Utils.rb')
require('./FDR.rb')
require('./TestGeneration.rb')

$DEBUG = false

tg = TraceGeneration.new


specfilename = ARGV.shift
sutfilename = ARGV.shift
specroot = ARGV.shift
sutroot = ARGV.shift

spec = File.readlines(specfilename).join("")

spec.match(/([A-Z]+)/)
events = []
spec.scan(/channel .*/).each do |l|
  l.scan(/[.a-z0-9_]+/).each do |e|
    events << e
  end
end
events -= ["channel"]
puts "spec #{spec}" if $DEBUG
puts "specroot #{specroot}" if $DEBUG

sut = File.readlines(sutfilename).join("")
puts "sut #{sut}" if $DEBUG
puts "sutroot #{sutroot}" if $DEBUG
puts "||| #{sut.split("\n").join(":")}" if $DEBUG
fd   = "RUN( { #{events.join(", ")} } )"
tg.set_events(events)
tg.add_process(spec)
tg.add_process(sut)
tg.add_process("channel inc, pass, fail")

result_method = "none"
result_model_checking = nil
decided = false
to_process = [[]]
all_right = true
while not decided
  if to_process.length == 0
    result_method = "correct"
    break
  end
  puts __LINE__ if $DEBUG
  if tg.refines?(specroot, fd)
  puts __LINE__ if $DEBUG
    puts ">>>(#{specroot} [T= #{sutroot})"
    decided = true
    result_method = "correct"
    break
  end
  puts __LINE__ if $DEBUG
  tr = to_process.shift
  to_process -= [tr]
  puts "#{__LINE__} tr #{tr}" if $DEBUG
  next unless tg.has_trace?(fd, tr)
  forbidden_continuations = tg.forbidden_continuations(tg.parallel(specroot, fd), tr)
  puts "#{__LINE__} #{forbidden_continuations}" if $DEBUG
  forbidden_continuations.each do |f|
    verdict = tg.verdict_test(sutroot, tg.to_trace_test(tr, f))
    puts "T_T(<#{tr.join(",")}>, #{f}) = #{verdict}"
    if verdict == "fail"
      puts ">>>not (#{specroot} [T= #{sutroot})"
      decided = true
      result_method = "faulty"
      break
    elsif verdict == "pass"
      fd = tg.refine_fault_domain_removing_trace(fd, tr + [f])
    else
      fd = tg.refine_fault_domain_removing_trace(fd, tr)
    end
  end
  if tr.length < 100
    trs = tg.extend_trace_by_one_event(specroot, tr)
    to_process += trs
  end
end
if tg.refines?(specroot, sutroot)
  puts "<<<(#{specroot} [T= #{sutroot})"
  result_model_checking = "correct"
else
  puts "<<<not (#{specroot} [T= #{sutroot})"
  result_model_checking = "faulty"
end
puts sut
puts spec
puts fd
all_right = all_right and (result_method != result_model_checking)
puts "@@@ #{result_method} #{result_model_checking} #{all_right}"
puts "!!! bug" unless all_right
