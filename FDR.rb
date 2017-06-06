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
class FDR
  FDRPROGRAM = "/home/adenilso/Downloads/fdr/bin/refines"
  def set_definition(str)
    @definitions = str
  end
  def reset_definition
    self.set_definition ""
  end
  def add_definition(str)
    self.reset_definition unless @definitions
    @definitions += "\n#{str}\n"
  end
  def set_property(str)
    @property = str
  end
  def check_property(str = nil, format = "plain")
    self.set_property str if str
    content = @definitions + "\n assert " + @property
    result = nil
    popen3(FDRPROGRAM, "--format", format, "-") do |stdin, stdout, stderr|
      stdin.puts content
      stdin.close_write
      result = stdout.read
    end
    return result
  end

  def has_passed?(m)
    return m.match(/Result: Passed/)
  end
end
