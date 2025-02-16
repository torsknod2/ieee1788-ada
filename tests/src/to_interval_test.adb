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
--  License along with this library; if not, write to the
--  Free Software Foundation, Inc.
--  51 Franklin Street, Fifth Floor, Boston, MA 2110-1301, USA
--
--  As a special exception to the GNU Lesser General Public License version 3
--  ("LGPL3"), the copyright holders of this Library give you permission to
--  convey to a third party a Combined Work that links statically or
--  dynamically to this Library without providing any Minimal Corresponding
--  Source or Minimal Application Code as set out in 4d or providing the
--  installation information set out in section 4e, provided that you comply
--  with the other provisions of LGPL3 and provided that you meet, for the
--  Application the terms and conditions of the license(s) which apply to the
--  Application.
--
--  Except as stated in this special exception, the provisions of LGPL3 will
--  continue to comply in full to this Library. If you modify this Library, you
--  may apply this exception to your version of this Library, but you are not
--  obliged to do so. If you do not wish to do so, delete this exception
--  statement from your version. This exception does not (and cannot) modify
--  any license terms which apply to the Application, with which you must
--  still comply.

with AUnit.Assertions;
with IEEE1788;

package body To_Interval_Test is
   package IEEE1788_Instance is new IEEE1788 (G);
   function Name (T : Test) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Test IEEE1788 To_Interval function");
   end Name;

   procedure Run_Test (T : in out Test) is
      pragma Unreferenced (T);
   begin
      AUnit.Assertions.Assert
        (IEEE1788_Instance.IntervalToText
           (IEEE1788_Instance.To_Interval (G'First)),
         "[" & G'Image (G'First) & "," & G'Image (G'First) & "]",
         "Test Low");
      if G'First < 0.0 and G'Last > 0.0 then
         AUnit.Assertions.Assert
           (IEEE1788_Instance.IntervalToText
              (IEEE1788_Instance.To_Interval (0.0)),
            "[" & G'Image (0.0) & "," & G'Image (0.0) & "]",
            "Test High");
      end if;
      AUnit.Assertions.Assert
        (IEEE1788_Instance.IntervalToText
           (IEEE1788_Instance.To_Interval (G'Last)),
         "[" & G'Image (G'Last) & "," & G'Image (G'Last) & "]",
         "Test High");
   end Run_Test;
end To_Interval_Test;
