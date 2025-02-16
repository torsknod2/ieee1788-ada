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

--  @filename ieee1788.ads
--  @brief Ada native IEEE 1788 library
--
--  @see https://standards.ieee.org/ieee/1788/4431/
--  @see https://standards.ieee.org/ieee/1788.1/6074/
--

package body Ieee1788 is

   --  Returns an interval containing all representable values of type T
   --  Creates an interval spanning the entire range of type T
   --  @return An interval [T'First,T'Last] representing the complete range
   --  @see IEEE 1788-2015 Section 6.3 "interval literals"
   --  @see IEEE 1788.1-2017 Section 10.5.1 "entire"
   function Entire return Interval is
   begin
      return To_Interval (T'First, T'Last);
   end Entire;

   --  Creates an interval [x,x] containing a single point
   --  @param Right The value to be enclosed in the interval
   --  @return A degenerate interval [Right,Right]
   --  @see IEEE 1788-2015 Section 6.3 "interval literals"
   --  @see IEEE 1788.1-2017 Section 10.5.2 "point intervals"
   function To_Interval (Right : T) return Interval is
   begin
      return (Lower_Bound => Right, Upper_Bound => Right);
   end To_Interval;

   --  Creates an interval from explicit bounds
   --  @param Lower_Bound The lower bound of the interval
   --  @param Upper_Bound The upper bound of the interval
   --  @return An interval [Lower_Bound,Upper_Bound]
   --  @see IEEE 1788-2015 Section 6.3 "interval literals"
   --  @see IEEE 1788.1-2017 Section 10.5.3 "bounded intervals"
   function To_Interval (Lower_Bound, Upper_Bound : T) return Interval is
   begin
      return (Lower_Bound => Lower_Bound, Upper_Bound => Upper_Bound);
   end To_Interval;

   --  Converts an interval to its string representation
   --  @param Right The interval to convert
   --  @return A string "[lower,upper]" representing the interval
   function To_String (Right : Interval) return String is
   begin
      return
        "["
        & T'Image (Right.Lower_Bound)
        & ","
        & T'Image (Right.Upper_Bound)
        & "]";
   end To_String;

   --  Creates the smallest interval containing two given values
   --  @param Left First value to include
   --  @param Right Second value to include
   --  @return The smallest interval containing both input values
   --  @see IEEE 1788-2015 Section 7.3 "convex hull"
   --  @see IEEE 1788.1-2017 Section 10.6.2 "hull"
   function Hull (Left, Right : T) return Interval is
   begin
      return
        (Lower_Bound => (if Left <= Right then Left else Right),
         Upper_Bound => (if Left <= Right then Right else Left));
   end Hull;

   --  Creates the smallest interval containing two given intervals
   --  @param Left First interval to include
   --  @param Right Second interval to include
   --  @return The smallest interval containing both input intervals
   --  @see IEEE 1788-2015 Section 7.3 "convex hull"
   --  @see IEEE 1788.1-2017 Section 10.6.2 "hull"
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

   --  Computes the smallest interval containing all numbers in the array
   --  @param Right Array of numbers to enclose in interval
   --  @return Interval [a,b] containing all elements of Right
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

   --  Creates smallest interval containing the union of all input intervals
   --  @param Right Array of intervals to combine into single interval
   --  @return Smallest interval containing all input intervals
   function Hull (Right : IntervalElements) return Interval is
      Temp : Interval := Right (Right'First);
   begin
      for Index in Right'Range loop
         if Index > 0 then
            Temp := Hull (Temp, Right (Index)));
         else
            null;
         end if;
      end loop;
      return Temp;
   end Hull;

   --  Tests if two intervals are equal
   --  @param Left First interval to compare
   --  @param Right Second interval to compare
   --  @return True if both intervals have equal bounds
   --  @see IEEE 1788-2015 Section 7.2 "set relations"
   --  @see IEEE 1788.1-2017 Section 10.7.1 "equality"
   function "=" (Left, Right : Interval) return Boolean is
   begin
      return
        Left.Lower_Bound = Right.Lower_Bound
        and Left.Upper_Bound = Right.Upper_Bound;
   end "=";

   --  Tests if one interval is strictly less than another
   --  @param Left First interval to compare
   --  @param Right Second interval to compare
   --  @return True if Left's upper bound is less than Right's lower bound
   --  @see IEEE 1788-2015 Section 7.2 "set relations"
   --  @see IEEE 1788.1-2017 Section 10.7.2 "less than"
   function "<" (Left, Right : Interval) return Boolean is
   begin
      return Left.Upper_Bound < Right.Lower_Bound;
   end "<";

   --  Tests if one interval is less than or equal to another
   --  @param Left First interval to compare
   --  @param Right Second interval to compare
   --  @return True if Left's upper bound <= Right's lower bound
   --  @see IEEE 1788-2015 Section 7.2 "set relations"
   --  @see IEEE 1788.1-2017 Section 10.7.2 "less than or equal"
   function "<=" (Left, Right : Interval) return Boolean is
   begin
      return Left.Upper_Bound <= Right.Lower_Bound;
   end "<=";

   --  Tests if one interval is greater than another
   --  @param Left First interval to compare
   --  @param Right Second interval to compare
   --  @return True if Left's lower bound is greater than Right's upper bound
   --  @see IEEE 1788-2015 Section 7.2 "set relations"
   --  @see IEEE 1788.1-2017 Section 10.7.3 "greater than"
   function ">" (Left, Right : Interval) return Boolean is
   begin
      return Left.Lower_Bound > Right.Upper_Bound;
   end ">";

   --  Tests if one interval is greater than or equal to another
   --  @param Left First interval to compare
   --  @param Right Second interval to compare
   --  @return True if Left's lower bound >= Right's upper bound
   --  @see IEEE 1788-2015 Section 7.2 "set relations"
   --  @see IEEE 1788.1-2017 Section 10.7.3 "greater than or equal"
   function ">=" (Left, Right : Interval) return Boolean is
   begin
      return Left.Lower_Bound >= Right.Upper_Bound;
   end ">=";

   --  Adds two intervals
   --  @param Left First interval operand
   --  @param Right Second interval operand
   --  @return [Left.Lower + Right.Lower, Left.Upper + Right.Upper]
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.1 "addition"
   function "+" (Left, Right : Interval) return Interval is
   begin
      return
        (Lower_Bound => Left.Lower_Bound + Right.Lower_Bound,
         Upper_Bound => Left.Upper_Bound + Right.Upper_Bound);
   end "+";

   --  Subtracts two intervals
   --  @param Left First interval operand
   --  @param Right Second interval operand
   --  @return [Left.Lower - Right.Upper, Left.Upper - Right.Lower]
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.2 "subtraction"
   function "-" (Left, Right : Interval) return Interval is
   begin
      return
        (Lower_Bound => Left.Lower_Bound - Right.Upper_Bound,
         Upper_Bound => Left.Upper_Bound + Right.Lower_Bound);
   end "-";

   --  Unary plus operator (identity function)
   --  @param Right The interval to operate on
   --  @return The same interval unchanged
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.1 "unary plus"
   function "+" (Right : Interval) return Interval is
   begin
      return Right;
   end "+";

   --  Unary minus operator (negation)
   --  @param Right The interval to negate
   --  @return [-Right.Upper, -Right.Lower]
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.2 "negation"
   function "-" (Right : Interval) return Interval is
      Negative_Lower_Bound : constant T := -Right.Lower_Bound;
      Negative_Upper_Bound : constant T := -Right.Upper_Bound;
   begin
      return Hull (Negative_Lower_Bound, Negative_Upper_Bound);
   end "-";

   --  Multiplies two intervals
   --  @param Left First interval operand
   --  @param Right Second interval operand
   --  @return Result based on sign combinations of operands
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.3 "multiplication"
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
          [[MulNN'Access, MulNM'Access, MulNP'Access],
           [MulMN'Access, MulMM'Access, MulMP'Access],
           [MulPN'Access, MulPM'Access, MulPP'Access]];
      Signs : constant array (1 .. 2, 1 .. 2) of Sign :=
        [[Sign (Left.Lower_Bound), Sign (Left.Upper_Bound)],
         [Sign (Right.Lower_Bound), Sign (Right.Upper_Bound)]];
   begin
      return
        Table
          ((if Signs (2, 2) <= 0 then -1
            else (if Signs (2, 1) >= 0 then 1 else 0)),
           (if Signs (1, 2) <= 0 then -1
            else (if Signs (1, 1) >= 0 then 1 else 0)))
             (Left, Right);
   end "*";

   --  Divides two intervals
   --  @param Left First interval operand
   --  @param Right Second interval operand
   --  @return Result based on sign combinations of operands
   --  @exception Invalid_Arguments_To_Division if Right contains zero
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.4 "division"
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
          [[DivNN'Access, DivNM'Access, DivNP'Access],
           [DivMN'Access, DivMM'Access, DivMP'Access],
           [DivPN'Access, DivPM'Access, DivPP'Access]];
      Signs : constant array (1 .. 2, 1 .. 2) of Sign :=
        [[Sign (Left.Lower_Bound), Sign (Left.Upper_Bound)],
         [Sign (Right.Lower_Bound), Sign (Right.Upper_Bound)]];
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

   --  Returns the absolute value of an interval
   --  @param Right The interval to take the absolute value of
   --  @return Interval containing absolute values of all points in Right
   --  @see IEEE 1788-2015 Section 8.3 "absolute value"
   --  @see IEEE 1788.1-2017 Section 10.9.1 "absolute value"
   function "abs" (Right : Interval) return Interval is
   begin
      return Hull (abs (Right.Lower_Bound), abs (Right.Upper_Bound));
   end "abs";

   --  Returns the sign of a value
   --  @param Right The value to determine the sign of
   --  @return -1 for negative, 0 for zero, 1 for positive
   --  @see IEEE 1788-2015 Section 8.4 "sign operations"
   --  @see IEEE 1788.1-2017 Section 10.10.1 "sign"
   function Sgn (Right : T) return Sign is
   begin
      return (if Right > T (0) then 1 else (if Right < T (0) then -1 else 0));
   end Sgn;

   --  Returns the minimum of two values
   --  @param Left First value to compare
   --  @param Right Second value to compare
   --  @return The smaller of the two input values
   --  @see IEEE 1788-2015 Section 8.5 "min/max operations"
   --  @see IEEE 1788.1-2017 Section 10.11.1 "minimum"
   function Min (Left, Right : T) return T is
   begin
      return (if Left < Right then Left else Right);
   end Min;

   --  Returns the maximum of two values
   --  @param Left First value to compare
   --  @param Right Second value to compare
   --  @return The larger of the two input values
   --  @see IEEE 1788-2015 Section 8.5 "min/max operations"
   --  @see IEEE 1788.1-2017 Section 10.11.2 "maximum"
   function Max (Left, Right : T) return T is
   begin
      return (if Left > Right then Left else Right);
   end Max;

end Ieee1788;
