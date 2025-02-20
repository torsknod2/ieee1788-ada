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
with AUnit.Test_Caller;
with Ieee1788.Implementation;

package body Ieee1788.Tests.To_Interval_Test is
   package Ieee1788_Instance is new Ieee1788.Implementation (T => G);

   package Test_Caller is new AUnit.Test_Caller (Test_Suite);

   procedure Test_First (T : in out Test_Suite) is
      pragma Unreferenced (T);
   begin
      AUnit.Assertions.Assert
        (Ieee1788_Instance.To_String
           (Ieee1788_Instance.To_Interval (G'First)) =
         "[" & G'Image (G'First) & "," & G'Image (G'First) & "]",
         "Test First value");
   end Test_First;

   procedure Test_Last (T : in out Test_Suite) is
      pragma Unreferenced (T);
   begin
      AUnit.Assertions.Assert
        (Ieee1788_Instance.To_String (Ieee1788_Instance.To_Interval (G'Last)) =
         "[" & G'Image (G'Last) & "," & G'Image (G'Last) & "]",
         "Test Last value");
   end Test_Last;

   procedure Test_Zero (T : in out Test_Suite) is
      pragma Unreferenced (T);
   begin
      AUnit.Assertions.Assert
        (Ieee1788_Instance.To_String (Ieee1788_Instance.To_Interval (0.0)) =
         "[0.0,0.0]",
         "Test Zero value");
   end Test_Zero;

   procedure Test_Range (T : in out Test_Suite) is
      pragma Unreferenced (T);
   begin
      AUnit.Assertions.Assert
        (Ieee1788_Instance.To_String
           (Ieee1788_Instance.To_Interval (G'First, G'Last)) =
         "[" & G'Image (G'First) & "," & G'Image (G'Last) & "]",
         "Test Range value");
   end Test_Range;

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite :=
        AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test
        (Test_Caller.Create
           ("Test To_Interval First value", Test_First'Access));
      Result.Add_Test
        (Test_Caller.Create ("Test To_Interval Last value", Test_Last'Access));
      Result.Add_Test
        (Test_Caller.Create ("Test To_Interval Zero value", Test_Zero'Access));
      Result.Add_Test
        (Test_Caller.Create
           ("Test To_Interval Range value", Test_Range'Access));
      return Result;
   end Suite;
end Ieee1788.Tests.To_Interval_Test;
