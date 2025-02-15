-- IEEE 1788 Interval Arithmetic native library for Ada
-- Copyright (C) 2024,2025 Torsten Knodt

-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 3.0 of the License, or (at your option) any later version.

-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

-- As a special exception to the GNU Lesser General Public License version 3
-- ("LGPL3"), the copyright holders of this Library give you permission to convey
-- to a third party a Combined Work that links statically or dynamically to this
-- Library without providing any Minimal Corresponding Source or Minimal
-- Application Code as set out in 4d or providing the installation information set
-- out in section 4e, provided that you comply with the other provisions of LGPL3
-- and provided that you meet, for the Application the terms and conditions of the
-- license(s) which apply to the Application.

-- Except as stated in this special exception, the provisions of LGPL3 will
-- continue to comply in full to this Library. If you modify this Library, you
-- may apply this exception to your version of this Library, but you are not
-- obliged to do so. If you do not wish to do so, delete this exception statement
-- from your version. This exception does not (and cannot) modify any license terms
-- which apply to the Application, with which you must still comply.

--  @filename ieee1788.ads
--  @brief Ada native IEEE 1788 library
--
--  https://standards.ieee.org/ieee/1788/4431/
--  https://standards.ieee.org/ieee/1788.1/6074/
--

generic
   type T is delta <> ;
package Ieee1788 is
   pragma Pure;
   Invalid_Arguments_To_Division : exception;
   type Interval is private;
   type IntervalElements is array (Integer range <>) of Interval;
   type TElements is array (Integer range <>) of T;
   function To_Interval (Right : T) return Interval;
   function To_Interval (Lower_Bound, Upper_Bound : T) return Interval
   with Pre => Lower_Bound <= Upper_Bound;
   function Hull (Left, Right : Interval) return Interval;
   function Hull (Left, Right : T) return Interval;
   function Hull (Right : IntervalElements) return Interval;
   function Hull (Right : TElements) return Interval;
   function "=" (Left, Right : Interval) return Boolean;
   function "<" (Left, Right : Interval) return Boolean;
   function "<=" (Left, Right : Interval) return Boolean;
   function ">" (Left, Right : Interval) return Boolean;
   function ">=" (Left, Right : Interval) return Boolean;
   function "+" (Left, Right : Interval) return Interval;
   function "-" (Left, Right : Interval) return Interval;
   function "+" (Right : Interval) return Interval;
   function "-" (Right : Interval) return Interval;
   function "*" (Left, Right : Interval) return Interval;
   function "/" (Left, Right : Interval) return Interval;
   function "abs" (Right : Interval) return Interval;
   function Entire return Interval;
private
   type Interval is record
      Lower_Bound : T;
      Upper_Bound : T;
   end record
   with
     Type_Invariant =>
       (Lower_Bound <= Upper_Bound and Upper_Bound >= Lower_Bound);
   subtype Sign is Integer range -1 .. 1;
   function Sgn (Right : T) return Sign
   with
     Post =>
       (Right < T (0) and then Sgn'Result = -1)
       or (Right = T (0) and then Sgn'Result = 0)
       or (Right > T (0) and then Sgn'Result = 1);

   function Min (Left, Right : T) return T
   with
     Post =>
       Min'Result <= Left
       and then Min'Result <= Right
       and then (Min'Result = Left or Min'Result = Right);

   function Max (Left, Right : T) return T
   with
     Post =>
       Max'Result >= Left
       and then Max'Result >= Right
       and then (Max'Result = Left or Max'Result = Right);
end Ieee1788;
