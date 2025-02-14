package body Ieee1788.Integer is
  function "mod" (Left, Right : Interval) return Interval is
  begin
    --- FIXME Optimize this implementation
    return
     Hull
      ((To_Interval (Left.Lower_Bound mod Right.Lower_Bound),
        To_Interval (Left.Upper_Bound mod Right.Lower_Bound),
        To_Interval (Left.Lower_Bound mod Right.Upper_Bound),
        To_Interval (Left.Upper_Bound mod Right.Upper_Bound)));
  end "mod";
  function "rem" (Left, Right : Interval) return Interval is
  begin
    --- FIXME Optimize this implementation
    return
     Hull
      ((To_Interval (Left.Lower_Bound rem Right.Lower_Bound),
        To_Interval (Left.Upper_Bound rem Right.Lower_Bound),
        To_Interval (Left.Lower_Bound rem Right.Upper_Bound),
        To_Interval (Left.Upper_Bound rem Right.Upper_Bound)));
  end "rem";

end Ieee1788.Integer;
