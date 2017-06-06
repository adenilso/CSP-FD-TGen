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

class Utils
  def Utils.deep_hash_copy(root)
    res = {}
    root.keys.each do |k|
      res[k] = Utils.deep_hash_copy(root[k])
    end
    return res
  end

  def Utils.subsets(set)
    res = []
    (0 ... 2**set.length).each do |word|
      s = (0 ... set.length).map{|i| if word & (1 << i) > 0 then [set[i]] else [] end}.flatten
      res << s
    end
    return res
  end

  def Utils.to_csp(description, root)
    res = []
    keys = description.keys.sort
    if keys.length == 0
      res << "#{root} = STOP"
    else
      options = []
      keys.each do |e|
        eq = "#{root}_#{e}"
        options << "#{e} -> #{eq}"
        res += Utils.to_csp(description[e], eq)
      end
      res.unshift("#{root} = #{options.join(" [] ")}")
    end
    return res
  end

  def Utils.from_traces_to_description(traces)
    root = {}
    traces.each do |tr|
      descr = root
      tr.each do |e|
        descr[e] = {} unless descr[e]
        descr = descr[e]
      end
    end
    return root
  end

  def Utils.traces_of_length(set, length)
    to_process = [[]]
    res = []
    while to_process.length > 0
      tr = to_process.shift
      set.each do |e|
        new_tr = tr + [e]
	res << new_tr
        if tr.length < length
          to_process << new_tr 
        end
      end
    end
    return res
  end

  def Utils.remove_prefixes(set)
    res = []
    set.sort{|a, b| b.length <=> a.length}.each do |tr|
      len = tr.length 
      if res.none?{|tr2| tr2.slice(0, len) == tr}
        res << tr
      end
    end
    return res
  end

  def Utils.extend_process(root, events, preferencefordef = 1)
    r = root
    while true
      s = r.keys
      ns = events - s
      set = (s * preferencefordef) + ns
      e = set.shuffle.first
      if r[e]
        r = r[e]
      else
        r[e] = {}
        break
      end
    end
    return root
  end
end

