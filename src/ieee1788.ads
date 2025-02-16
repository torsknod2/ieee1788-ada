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

--  @summary
--  A native Ada implementation of IEEE 1788 interval arithmetic.
--
--  @description
--  This library implements the IEEE 1788.1 specification for interval
--  arithmetic. It provides basic arithmetic operations and comparisons
--  for intervals.
--
--  @see https://standards.ieee.org/ieee/1788/4431/
--  @see https://standards.ieee.org/ieee/1788.1/6074/

generic
   --  The underlying numeric type for interval bounds
   --  Must be a fixed or numeric type supporting exact arithmetic
   --  @see IEEE 1788-2015 Section 7.2 "computational data types"
   type T is delta <>;
package Ieee1788 is
   pragma Pure;

   --  Exception for division by interval containing zero
   --  Raised by "/" operator when Right operand contains zero
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   Invalid_Arguments_To_Division : exception;

   --  Represents a closed interval [a,b] where a <= b
   --  Basic interval type supporting IEEE 1788 operations
   --  @see IEEE 1788-2015 Section 6.2 "interval types"
   type Interval is private;

   --  Array of intervals for bulk operations
   --  Used for operations on multiple intervals
   --  @see IEEE 1788-2015 Section 6.2 "interval types"
   type IntervalElements is array (Integer range <>) of Interval;

   --  Array of numbers for bulk operations
   --  Used for operations on multiple numbers
   --  @see IEEE 1788-2015 Section 6.2 "interval types"
   type TElements is array (Integer range <>) of T;

   --  Creates a degenerate interval [x,x]
   --  @param Right The value to enclose
   --  @return An interval containing only Right
   --  @see IEEE 1788-2015 Section 6.3 "interval literals"
   function To_Interval (Right : T) return Interval;

   --  Creates an interval from explicit bounds
   --  @param Lower_Bound The lower bound
   --  @param Upper_Bound The upper bound
   --  @return Interval [Lower_Bound,Upper_Bound]
   --  @pre Lower_Bound <= Upper_Bound
   --  @see IEEE 1788-2015 Section 6.3 "interval literals"
   function To_Interval (Lower_Bound, Upper_Bound : T) return Interval
   with Pre => Lower_Bound <= Upper_Bound;

   --  Converts interval to string representation
   --  @param Right The interval to convert
   --  @return String in format "[lower,upper]"
   --  @see IEEE 1788-2015 Section 6.3 "interval literals"
   function To_String (Right : Interval) return String;

   --  Computes interval hull of two intervals
   --  @param Left First interval
   --  @param Right Second interval
   --  @return Smallest interval containing both inputs
   --  @see IEEE 1788-2015 Section 6.4 "interval hulls"
   function Hull (Left, Right : Interval) return Interval;

   --  Computes interval hull of two numbers
   --  @param Left First number
   --  @param Right Second number
   --  @return Smallest interval containing both inputs
   --  @see IEEE 1788-2015 Section 6.4 "interval hulls"
   function Hull (Left, Right : T) return Interval;

   --  Computes hull of interval array
   --  @param Right Array of intervals
   --  @return Smallest interval containing all inputs
   --  @see IEEE 1788-2015 Section 6.4 "interval hulls"
   function Hull (Right : IntervalElements) return Interval;

   --  Computes hull of number array
   --  @param Right Array of numbers
   --  @return Smallest interval containing all inputs
   --  @see IEEE 1788-2015 Section 6.4 "interval hulls"
   function Hull (Right : TElements) return Interval;

   --  Tests interval equality
   --  @param Left First interval
   --  @param Right Second interval
   --  @return True if intervals are equal
   --  @see IEEE 1788-2015 Section 8.1 "set relations"
   function "=" (Left, Right : Interval) return Boolean;

   --  Tests strict containment
   --  @param Left First interval
   --  @param Right Second interval
   --  @return True if Left strictly contains Right
   --  @see IEEE 1788-2015 Section 8.1 "set relations"
   function "<" (Left, Right : Interval) return Boolean;

   --  Tests non-strict containment
   --  @param Left First interval
   --  @param Right Second interval
   --  @return True if Left contains or equals Right
   --  @see IEEE 1788-2015 Section 8.1 "set relations"
   --  @see IEEE 1788.1-2017 Section 10.7.2 "less than or equal"
   function "<=" (Left, Right : Interval) return Boolean;

   --  Tests if interval is strictly greater
   --  @param Left First interval
   --  @param Right Second interval
   --  @return True if Left is entirely greater than Right
   --  @see IEEE 1788-2015 Section 8.1 "set relations"
   --  @see IEEE 1788.1-2017 Section 10.7.3 "greater than"
   function ">" (Left, Right : Interval) return Boolean;

   --  Tests if interval is greater or equal
   --  @param Left First interval
   --  @param Right Second interval
   --  @return True if Left is greater than or equal to Right
   --  @see IEEE 1788-2015 Section 8.1 "set relations"
   --  @see IEEE 1788.1-2017 Section 10.7.3 "greater than or equal"
   function ">=" (Left, Right : Interval) return Boolean;

   --  Adds two intervals
   --  @param Left First interval operand
   --  @param Right Second interval operand
   --  @return [Left.Lower + Right.Lower, Left.Upper + Right.Upper]
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.1 "addition"
   function "+" (Left, Right : Interval) return Interval;

   --  Subtracts two intervals
   --  @param Left First interval operand
   --  @param Right Second interval operand
   --  @return [Left.Lower - Right.Upper, Left.Upper - Right.Lower]
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.2 "subtraction"
   function "-" (Left, Right : Interval) return Interval;

   --  Unary plus operator (identity function)
   --  @param Right The interval to operate on
   --  @return The same interval unchanged
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.1 "unary plus"
   function "+" (Right : Interval) return Interval;

   --  Unary minus operator (negation)
   --  @param Right The interval to negate
   --  @return [-Right.Upper, -Right.Lower]
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.2 "negation"
   function "-" (Right : Interval) return Interval;

   --  Multiplies two intervals
   --  @param Left First interval operand
   --  @param Right Second interval operand
   --  @return Result based on sign combinations of operands
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.3 "multiplication"
   function "*" (Left, Right : Interval) return Interval;

   --  Divides two intervals
   --  @param Left First interval operand
   --  @param Right Second interval operand
   --  @return Result based on sign combinations of operands
   --  @exception Invalid_Arguments_To_Division if Right contains zero
   --  @see IEEE 1788-2015 Section 8.2 "arithmetic operations"
   --  @see IEEE 1788.1-2017 Section 10.8.4 "division"
   function "/" (Left, Right : Interval) return Interval;

   --  Returns the absolute value of an interval
   --  @param Right The interval to take the absolute value of
   --  @return Interval containing absolute values of all points in Right
   --  @see IEEE 1788-2015 Section 8.3 "absolute value"
   --  @see IEEE 1788.1-2017 Section 10.9.1 "absolute value"
   function "abs" (Right : Interval) return Interval;

   --  Returns an interval containing all representable values
   --  Creates an interval spanning the entire range of type T
   --  @return An interval [T'First,T'Last]
   --  @see IEEE 1788-2015 Section 6.3 "interval literals"
   --  @see IEEE 1788.1-2017 Section 10.5.1 "entire"
   function Entire return Interval;
private
   --  Internal interval representation
   --  Stores bounds with invariant Lower_Bound <= Upper_Bound
   --  @field Lower_Bound Lower bound of interval
   --  @field Upper_Bound Upper bound of interval
   type Interval is record
      Lower_Bound : T;
      Upper_Bound : T;
   end record
   with Type_Invariant => Lower_Bound <= Upper_Bound;

   --  Sign indicator for numbers
   --  -1 for negative, 0 for zero, 1 for positive
   subtype Sign is Integer range -1 .. 1;

   --  Returns sign of a number
   --  @param Right The number to test
   --  @return Sign indicator (-1,0,1)
   --  @see IEEE 1788-2015 Section 8.3
   function Sgn (Right : T) return Sign
   with
     Post =>
       (Right < T (0) and then Sgn'Result = -1)
       or (Right = T (0) and then Sgn'Result = 0)
       or (Right > T (0) and then Sgn'Result = 1);

   --  Returns minimum of two numbers
   --  @param Left First number
   --  @param Right Second number
   --  @return The smaller value
   --  @see IEEE 1788-2015 Section 8.3
   function Min (Left, Right : T) return T
   with
     Post =>
       Min'Result <= Left
       and then Min'Result <= Right
       and then (Min'Result = Left or Min'Result = Right);

   --  Returns maximum of two numbers
   --  @param Left First number
   --  @param Right Second number
   --  @return The larger value
   --  @see IEEE 1788-2015 Section 8.3
   function Max (Left, Right : T) return T
   with
     Post =>
       Max'Result >= Left
       and then Max'Result >= Right
       and then (Max'Result = Left or Max'Result = Right);

end Ieee1788;
