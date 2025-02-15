--  IEEE 1788 Interval Arithmetic native library for Ada
--  Copyright (C) 2024,2025 Torsten Knodt
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 3.0 of the License, or (at your option) any later version.
--
--  This library is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Lesser General Public License for more details.
--
--  You should have received a copy of the GNU Lesser General Public
--  License along with this library; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
--
--  As a special exception to the GNU Lesser General Public License version 3
--  ("LGPL3"), the copyright holders of this Library give you permission to convey
--  to a third party a Combined Work that links statically or dynamically to this
--  Library without providing any Minimal Corresponding Source or Minimal
--  Application Code as set out in 4d or providing the installation information set
--  out in section 4e, provided that you comply with the other provisions of LGPL3
--  and provided that you meet, for the Application the terms and conditions of the
--  license(s) which apply to the Application.
--
--  Except as stated in this special exception, the provisions of LGPL3 will
--  continue to comply in full to this Library. If you modify this Library, you
--  may apply this exception to your version of this Library, but you are not
--  obliged to do so. If you do not wish to do so, delete this exception statement
--  from your version. This exception does not (and cannot) modify any license terms
--  which apply to the Application, with which you must still comply.

with AUnit.Test_Suites;
with AUnit.Test_Cases;
with To_Interval_Test;

package body A_Suite is

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Ret : constant Access_Test_Suite := new Test_Suite;
   begin
      Ret.Add_Test
        (AUnit.Test_Cases.Test_Case_Access'
           (new To_Interval_Test.To_Interval_Test));
      return Ret;
   end Suite;
end A_Suite;
