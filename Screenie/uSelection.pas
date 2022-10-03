unit uSelection;

interface

uses
  Windows, SysUtils, Classes, Math, Functions;

type
  TSelection = record
    X, Y, W, H: Integer;
  end;

type
  TArrayOfSelection = array of TSelection;


function Selection(X, Y, W, H: Integer): TSelection; overload;
function Selection(R: TRect): TSelection; overload;
function SRect(S: TSelection): TRect;
function PointInSelection(Point: TPoint; S: TSelection): Boolean;
function isSelectionEmpty(S: TSelection): Boolean;
function SelectionTouches(A, B: TSelection; ignoreIntersects: Boolean): Boolean;
function SelectionContains(A, B: TSelection): Boolean;
function SelectionIntersects(A, B: TSelection): Boolean;
function SelectionDifference(A, B: TSelection): TArrayOfSelection;

implementation

function Selection(X, Y, W, H: Integer): TSelection; overload;
begin
  Result.X := X;
  Result.Y := Y;
  Result.W := W;
  Result.H := H;
end;


function Selection(R: TRect): TSelection; overload;
begin
  Result.X := R.Left;
  Result.Y := R.Top;
  Result.W := R.Right - R.Left;
  Result.H := R.Bottom - R.Top;
end;


function SRect(S: TSelection): TRect;
begin
  Result := Bounds(S.X, S.Y, S.W, S.H);
end;


function PointInRect(Point: TPoint; Rect: TRect): Boolean;
begin
  Result := (Point.X >= Rect.Left) and (Point.X < Rect.Right) and (Point.Y >= Rect.Top) and (Point.Y < Rect.Bottom);
end;


function RectTouches(A, B: TRect): Boolean;
begin
  Result := not ((((A.Left > B.Right) or (B.Left > A.Right))) or (((A.Top > B.Bottom) or (B.Top > A.Bottom))));
end;


function PointInSelection(Point: TPoint; S: TSelection): Boolean;
begin
  Result := PointInRect(Point, SRect(S));
end;


function isSelectionEmpty(S: TSelection): Boolean;
begin
  Result := (S.X = 0) and (S.Y = 0) and (S.W = 0) and (S.H = 0);
end;


function SelectionTouches(A, B: TSelection; ignoreIntersects: Boolean): Boolean;
begin
  Result := RectTouches(SRect(A), SRect(B));
  if not ignoreIntersects then Result := Result and not SelectionIntersects(A, B);
end;


function SelectionContains(A, B: TSelection): Boolean;
begin
  Result := (B.X >= A.X) and (B.Y >= A.Y) and (B.X + B.W <= A.X + A.W) and (B.Y + B.H <= A.Y + A.H);
end;


function SelectionIntersects(A, B: TSelection): Boolean;
begin
  Result := not ((B.X + B.W <= A.X) or (B.Y + B.H <= A.Y) or (B.X >= A.X + A.W) or (B.Y >= A.Y + A.H));
end;


function SelectionDifference(A, B: TSelection): TArrayOfSelection;
var
  raHeight: Integer;
  rbY, rbHeight: Integer;
  rectAYH, y1, y2, rcHeight: Integer;
  rcWidth: Integer;
  rbX, rdWidth: Integer;
begin
  SetLength(Result, 0);
  if (SelectionContains(B, A)) then Exit;
  SetLength(Result, 4);

  //compute the top rectangle
  raHeight := B.y - A.y;
  if (raHeight > 0) then Result[0] := Selection(A.X, A.Y, A.W, raHeight);

  //compute the bottom rectangle
  rbY := B.y + B.H;
  rbHeight := A.H - (rbY - A.y);
  if ((rbHeight > 0) and (rbY < A.y + A.H)) then Result[1] := Selection(A.X, rbY, A.W, rbHeight);

  rectAYH := A.y + A.H;
  y1 := Q((B.y > A.y), B.Y, A.Y);
  y2 := Q((rbY < rectAYH), rbY, rectAYH);
  rcHeight := y2 - y1;

  //compute the left rectangle
  rcWidth := B.x - A.x;
  if ((rcWidth > 0) and (rcHeight > 0)) then Result[2] := Selection(A.X, y1, rcWidth, rcHeight);

  //compute the right rectangle
  rbX := B.x + B.W;
  rdWidth := A.W - (rbX - A.x);
  if (rdWidth > 0) then Result[3] := Selection(rbX, y1, rdWidth, rcHeight);
end;

end.
