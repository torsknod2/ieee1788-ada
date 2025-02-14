generic
   type T is mod <>;
package Ieee1788.Integer is
   type Interval is private;
   function "mod" (Left, Right : Interval) return Interval;
   function "rem" (Left, Right : Interval) return Interval;
private
   type Interval is record
      Lower_Bound : T;
      Upper_Bound : T;
   end record with
     Type_Invariant =>
      (Lower_Bound <= Upper_Bound and then Upper_Bound >= Lower_Bound);
end Ieee1788.Integer;
