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

--   @filename ieee1788.ads
--   @brief Ada native IEEE 1788 library
--
--   https://standards.ieee.org/ieee/1788/4431/
--   https://standards.ieee.org/ieee/1788.1/6074/
--

package body Ieee1788 is
   function Entire return Interval is
   begin
      return To_Interval (T'First, T'Last);
   end Entire;

   function To_Interval (Right : T) return Interval is
   begin
      return (Lower_Bound => Right, Upper_Bound => Right);
   end To_Interval;

   function To_Interval (Lower_Bound, Upper_Bound : T) return Interval is
   begin
      return (Lower_Bound => Lower_Bound, Upper_Bound => Upper_Bound);
   end To_Interval;

   function To_String (Right : Interval) return String is
   begin
      return
        "["
        & T'Image (Right.Lower_Bound)
        & ","
        & T'Image (Right.Upper_Bound)
        & "]";
   end To_String;

   function Hull (Left, Right : T) return Interval is
   begin
      return
        (Lower_Bound => (if Left <= Right then Left else Right),
         Upper_Bound => (if Left <= Right then Right else Left));
   end Hull;

   function Hull (Left, Right : Interval) return Interval is
   begin
      return
        (Lower_Bound =>
           (if Left.Lower_Bound <= Right.Lower_Bound then Left.Lower_Bound
            else Right.Lower_Bound),
         Upper_Bound =>
           (if Left.Upper_Bound <= Right.Upper_Bound then Right.Upper_Bound
            else Left.Upper_Bound));
   end Hull;

   function Hull (Right : TElements) return Interval is
      Temp : Interval := To_Interval (Right (Right'First));
   begin
      for Index in Right'Range loop
         if Index > 0 then
            Temp := Hull (Temp, To_Interval (Right (Index)));
         else
            null;
         end if;
      end loop;
      return Temp;
   end Hull;

   function Hull (Right : IntervalElements) return Interval is
      Temp : Interval := Right (Right'First);
   begin
      for Index in Right'Range loop
         if Index > 0 then
            Temp := Hull (Temp, Right (Index));
         else
            null;
         end if;
      end loop;
      return Temp;
   end Hull;

   function "=" (Left, Right : Interval) return Boolean is
   begin
      return
        Left.Lower_Bound = Right.Lower_Bound
        and Left.Upper_Bound = Right.Upper_Bound;
   end "=";

   function "<" (Left, Right : Interval) return Boolean is
   begin
      return Left.Upper_Bound < Right.Lower_Bound;
   end "<";

   function "<=" (Left, Right : Interval) return Boolean is
   begin
      return Left.Upper_Bound <= Right.Lower_Bound;
   end "<=";

   function ">" (Left, Right : Interval) return Boolean is
   begin
      return Left.Lower_Bound > Right.Upper_Bound;
   end ">";

   function ">=" (Left, Right : Interval) return Boolean is
   begin
      return Left.Lower_Bound >= Right.Upper_Bound;
   end ">=";

   function "+" (Left, Right : Interval) return Interval is
   begin
      return
        (Lower_Bound => Left.Lower_Bound + Right.Lower_Bound,
         Upper_Bound => Left.Upper_Bound + Right.Upper_Bound);
   end "+";
   function "-" (Left, Right : Interval) return Interval is
   begin
      return
        (Lower_Bound => Left.Lower_Bound - Right.Upper_Bound,
         Upper_Bound => Left.Upper_Bound + Right.Lower_Bound);
   end "-";

   function "+" (Right : Interval) return Interval is
   begin
      return Right;
   end "+";

   function "-" (Right : Interval) return Interval is
      Negative_Lower_Bound : constant T := -Right.Lower_Bound;
      Negative_Upper_Bound : constant T := -Right.Upper_Bound;
   begin
      return Hull (Negative_Lower_Bound, Negative_Upper_Bound);
   end "-";

   function "*" (Left, Right : Interval) return Interval is
      function MulNN (Left, Right : Interval) return Interval;
      function MulNM (Left, Right : Interval) return Interval;
      function MulNP (Left, Right : Interval) return Interval;
      function MulMN (Left, Right : Interval) return Interval;
      function MulMM (Left, Right : Interval) return Interval;
      function MulMP (Left, Right : Interval) return Interval;
      function MulPN (Left, Right : Interval) return Interval;
      function MulPM (Left, Right : Interval) return Interval;
      function MulPP (Left, Right : Interval) return Interval;
      function MulNN (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Upper_Bound * Right.Upper_Bound,
              Left.Lower_Bound * Right.Lower_Bound);
      end MulNN;
      function MulNM (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Lower_Bound * Right.Upper_Bound,
              Left.Lower_Bound * Right.Lower_Bound);
      end MulNM;
      function MulNP (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Lower_Bound * Right.Upper_Bound,
              Left.Upper_Bound * Right.Lower_Bound);
      end MulNP;
      function MulMN (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Upper_Bound * Right.Lower_Bound,
              Left.Lower_Bound * Right.Lower_Bound);
      end MulMN;
      function MulMM (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Min
                (Left.Lower_Bound * Right.Upper_Bound,
                 Left.Upper_Bound * Right.Lower_Bound),
              Max
                (Left.Lower_Bound * Right.Lower_Bound,
                 Left.Upper_Bound * Right.Upper_Bound));
      end MulMM;
      function MulMP (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Lower_Bound * Right.Upper_Bound,
              Left.Upper_Bound * Right.Upper_Bound);
      end MulMP;
      function MulPN (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Upper_Bound * Right.Lower_Bound,
              Left.Lower_Bound * Right.Upper_Bound);
      end MulPN;
      function MulPM (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Upper_Bound * Right.Lower_Bound,
              Left.Upper_Bound * Right.Upper_Bound);
      end MulPM;
      function MulPP (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Lower_Bound * Right.Upper_Bound,
              Left.Upper_Bound * Right.Upper_Bound);
      end MulPP;
      Table :
        constant array (Sign, Sign)
        of access function (Left, Right : Interval) return Interval :=
          ((MulNN'Access, MulNM'Access, MulNP'Access),
           (MulMN'Access, MulMM'Access, MulMP'Access),
           (MulPN'Access, MulPM'Access, MulPP'Access));
      Signs : constant array (1 .. 2, 1 .. 2) of Sign :=
        ((Sign (Left.Lower_Bound), Sign (Left.Upper_Bound)),
         (Sign (Right.Lower_Bound), Sign (Right.Upper_Bound)));
   begin
      return
        Table
          ((if Signs (2, 2) <= 0 then -1
            else (if Signs (2, 1) >= 0 then 1 else 0)),
           (if Signs (1, 2) <= 0 then -1
            else (if Signs (1, 1) >= 0 then 1 else 0)))
             (Left, Right);
   end "*";

   function "/" (Left, Right : Interval) return Interval is
      function DivNN (Left, Right : Interval) return Interval;
      function DivNM (Left, Right : Interval) return Interval;
      function DivNP (Left, Right : Interval) return Interval;
      function DivMN (Left, Right : Interval) return Interval;
      function DivMM (Left, Right : Interval) return Interval;
      function DivMP (Left, Right : Interval) return Interval;
      function DivPN (Left, Right : Interval) return Interval;
      function DivPM (Left, Right : Interval) return Interval;
      function DivPP (Left, Right : Interval) return Interval;
      function DivNN (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Upper_Bound / Right.Lower_Bound,
              Left.Lower_Bound * Right.Upper_Bound);
      end DivNN;
      function DivNM (Left, Right : Interval) return Interval is
      begin
         pragma Assert (False);
         pragma Unreferenced (Left, Right);
         return raise Invalid_Arguments_To_Division;
      end DivNM;
      function DivNP (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Lower_Bound * Right.Lower_Bound,
              Left.Upper_Bound * Right.Upper_Bound);
      end DivNP;
      function DivMN (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Upper_Bound * Right.Upper_Bound,
              Left.Lower_Bound * Right.Upper_Bound);
      end DivMN;
      function DivMM (Left, Right : Interval) return Interval is
      begin
         pragma Assert (False);
         pragma Unreferenced (Left, Right);
         return raise Invalid_Arguments_To_Division;
      end DivMM;
      function DivMP (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Lower_Bound * Right.Lower_Bound,
              Left.Upper_Bound * Right.Lower_Bound);
      end DivMP;
      function DivPN (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Upper_Bound * Right.Upper_Bound,
              Left.Lower_Bound * Right.Lower_Bound);
      end DivPN;
      function DivPM (Left, Right : Interval) return Interval is
      begin
         pragma Assert (False);
         pragma Unreferenced (Left, Right);
         return raise Invalid_Arguments_To_Division;
      end DivPM;
      function DivPP (Left, Right : Interval) return Interval is
      begin
         return
           To_Interval
             (Left.Lower_Bound * Right.Upper_Bound,
              Left.Upper_Bound * Right.Lower_Bound);
      end DivPP;
      Table :
        constant array (Sign, Sign)
        of access function (Left, Right : Interval) return Interval :=
          ((DivNN'Access, DivNM'Access, DivNP'Access),
           (DivMN'Access, DivMM'Access, DivMP'Access),
           (DivPN'Access, DivPM'Access, DivPP'Access));
      Signs : constant array (1 .. 2, 1 .. 2) of Sign :=
        ((Sign (Left.Lower_Bound), Sign (Left.Upper_Bound)),
         (Sign (Right.Lower_Bound), Sign (Right.Upper_Bound)));
   begin
      --- FIXME https://www.math.kit.edu/ianm2/~kulisch/media/compl1788.pdf p.8
      return
        Table
          ((if Signs (2, 2) <= 0 then -1
            else (if Signs (2, 1) >= 0 then 1 else 0)),
           (if Signs (1, 2) <= 0 then -1
            else (if Signs (1, 1) >= 0 then 1 else 0)))
             (Left, Right);
   end "/";

   function "abs" (Right : Interval) return Interval is
   begin
      return Hull (abs (Right.Lower_Bound), abs (Right.Upper_Bound));
   end "abs";

   function Sgn (Right : T) return Sign is
   begin
      return (if Right > T (0) then 1 else (if Right < T (0) then -1 else 0));
   end Sgn;

   function Min (Left, Right : T) return T is
   begin
      return (if Left < Right then Left else Right);
   end Min;

   function Max (Left, Right : T) return T is
   begin
      return (if Left > Right then Left else Right);
   end Max;

end Ieee1788;
