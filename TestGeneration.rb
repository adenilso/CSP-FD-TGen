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

class TraceGeneration
  def initialize
    @fdr = FDR.new
    @fdr.reset_definition
    @events = []
  end
  def set_events(events)
    @events = events
  end
  def set_process(process)
    @process = process
    @fdr.set_definition(@process)
    @fdr.add_definition "channel pass, inc, fail"
  end
  def add_process(process)
    @fdr.add_definition process
  end
  def continuations(root, trace)
    steps = trace + ["( #{ @events.map{|e| e + " -> STOP"}.join("[]") } )"]
    prop = "#{root} [T= #{steps.join("->")}"
    puts "#{__LINE__} prop #{prop}" if $DEBUG
    m = @fdr.check_property(prop, "plain")
    puts "#{__LINE__} m #{m}" if $DEBUG
    m = m.split("\n").join(" ")
    if m.match(/Result: Passed/)
      return @events
    else
      if m.match(/Available Events: {([^}]*)}/)
        continuations = $1.split(",")
        return continuations.map{|s| s.match(/^\s*(\S*)\s*$/); $1}
      end
    end
  end

  def extend_trace_by_one_event(root, trace)
    continuations = self.continuations(root, trace)
    return continuations.map{|e| trace + [e]}
  end

  def forbidden_continuations(root, trace)
    continuations = self.continuations(root, trace)
    forbidden_continuations = @events - continuations
  end

  def to_trace_test(trace, forbidden_continuation)
    test = trace.map{|e| ["inc", e]}.flatten
    test += ["pass", forbidden_continuation, "fail", "STOP"]
  end

  def verdict_test(root, test)
    process = "((#{root} [| { #{@events.join(", ")} } |] #{test.join(" -> ")}) \\ { #{@events.join(", ")} })"
    assert1 = "RUN({ pass, inc }) [T= #{process}"
    puts "#{__LINE__} assert1 #{assert1}" if $DEBUG
    m = @fdr.check_property(assert1, "plain")
    puts "#{__LINE__} m #{m}" if $DEBUG
    if !@fdr.has_passed?(m)
      return "fail"
    else
      assert2 = "RUN({ inc }) [T= #{process}"
      m = @fdr.check_property(assert2, "plain")
    puts "#{__LINE__} m #{m}" if $DEBUG
      if @fdr.has_passed?(m)
        return "inc"
      else
        return "pass"
      end
    end
  end

  def after(proc1, tr) 
    return "((#{proc1}) [| { #{@events.join(", ") } } |] (#{ (tr + ["RUN( { #{@events.join(", ") } } )"]).join(" -> ") }))"
  end

  def refines?(proc1, proc2)
    m = @fdr.check_property("#{proc1} [T= #{proc2}", "plain")
    return @fdr.has_passed?(m)
  end

  def parallel(proc1, proc2) 
    return "(( #{proc1} ) [| { #{ @events.join(", ") } } |] (#{proc2}))"
  end

  def refine_fault_domain_with_spec_after(fd, spec, tr)
    return self.parallel(fd, self.after(spec, tr))
  end

  def refine_fault_domain_removing_trace(fd, tr)
    return self.parallel(fd, self.not_trace_process(tr))
  end

  def not_trace_process(trace)
    event = trace[0]
    other_events = @events - [event]
    comps = []
    if trace.length > 1
      rec = not_trace_process(trace.slice(1, trace.length))
      comps += ["(#{event} -> (#{rec}))"]
    end
    comps += other_events.map{|e| "(#{e} -> RUN( { #{ @events.join(", ") } } ))"}
    return comps.join(" [] ")
  end

  def has_trace?(proc1, tr)
    prop = "( #{proc1} ) [T= ( #{(tr + ["STOP"]).join(" -> ")} )"
    m = @fdr.check_property(prop)
    puts "#{__LINE__} m #{m}" if $DEBUG
    return @fdr.has_passed?(m)
  end

  def refines?(proc1, proc2)
    prop = "( #{proc1} ) [T= ( #{proc2} )"
    m = @fdr.check_property(prop)
    puts "#{__LINE__} m #{m}" if $DEBUG
    return @fdr.has_passed?(m)
  end

end
