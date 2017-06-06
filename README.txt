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

To run the program:
1) install FDR4 (https://www.cs.ox.ac.uk/projects/fdr/manual/index.html).
2) change the variable FDRPROGRAM to point to the 'refines' program which was installed.
3) Run
  ./test-generation.rb SPEC.fdr SUT.fdr SpecRoot SutRoot
where 
  SPEC.fdr is the file with the specification
  SUT.fdr is the file with the implementation
  SpecRoot is the root process of the specification
  SutRoot is the root process of the SUT


