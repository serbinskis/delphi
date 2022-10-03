unit Screenie;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, PNGImage, Math, Buttons, uSelection, Functions,
  Grids, TFlatGroupBoxUnit, CustoBevel;

type
  TForm1 = class(TForm)
    Image1: TImage;
    GroupBox1: TFlatGroupBox;
    Image5: TImage;
    Bevel1: TCustoBevel;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    GroupBox2: TFlatGroupBox;
    Image7: TImage;
    Bevel2: TCustoBevel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure ShapeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShapeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShapeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ObjectMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ObjectMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ObjectMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

    function GetSizeSelection(S: TSelection): TSelection;
    procedure MoveShapes(X, Y, W, H: Integer);
    procedure DrawShapes(X, Y, W, H: Integer);
    procedure DrawShape(X, Y: Integer);
    procedure DrawSelect(O, N: TSelection);
    procedure ClearShape(O, S: TSelection);
    procedure ClearShapes(O: TSelection; X, Y, W, H: Integer);
    procedure ClearSizeText(O: TSelection);
    procedure ClearSelect(O, N: TSelection);
    procedure Select(O, N: TSelection);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  RESIZE_SHAPE_SIZE = 6;
  RESIZE_BOTH = 0;
  RESIZE_HORIZONTAL = 1;
  RESIZE_VERTICAL = 2;

var
  Form1: TForm1;
  LabelFont: TFont;
  AlphaBitmap: TBitmap;
  OriginalBitmap: TBitmap;
  BMouseDown, BSelectionMove: Boolean;
  ResizeType: Integer = 0;
  DownPoint: TPoint;
  CurSelect: TSelection;

implementation

{$R *.dfm}

function TForm1.GetSizeSelection(S: TSelection): TSelection;
var
  Text: String;
  TextWidth, TextHeight: Integer;
  X, Y: Integer;
begin
  X := S.X;
  Y := S.Y;

  Text := Format('%dx%d', [S.W, S.H]);
  TextWidth := Image1.Canvas.TextWidth(Text);
  TextHeight := Image1.Canvas.TextHeight(Text);

  if (X+TextWidth+12 > Image1.Width) then begin
    X := X-(TextWidth+12)-5;
    Y := Y+TextHeight+8;
  end;

  if (Y <= TextHeight+8) then begin
    Y := Y + 5;
    X := X + 5;
  end else begin
    Y := Y-TextHeight-8;
  end;

  Result := Selection(X, Y, TextWidth+12-1, TextHeight+4-1);
end;


procedure TForm1.MoveShapes(X, Y, W, H: Integer);
var
  i: Integer;
begin
  TShape(Form1.FindComponent('ResizeShape1')).Left := X-(RESIZE_SHAPE_SIZE div 2);
  TShape(Form1.FindComponent('ResizeShape1')).Top := Y-(RESIZE_SHAPE_SIZE div 2);

  TShape(Form1.FindComponent('ResizeShape2')).Left := X+(W div 2)-(RESIZE_SHAPE_SIZE div 2);
  TShape(Form1.FindComponent('ResizeShape2')).Top := Y-(RESIZE_SHAPE_SIZE div 2);

  TShape(Form1.FindComponent('ResizeShape3')).Left := X+W-(RESIZE_SHAPE_SIZE div 2);
  TShape(Form1.FindComponent('ResizeShape3')).Top := Y-(RESIZE_SHAPE_SIZE div 2);

  TShape(Form1.FindComponent('ResizeShape4')).Left := X-(RESIZE_SHAPE_SIZE div 2);
  TShape(Form1.FindComponent('ResizeShape4')).Top := Y+(H div 2)-(RESIZE_SHAPE_SIZE div 2);

  TShape(Form1.FindComponent('ResizeShape5')).Left := X+W-(RESIZE_SHAPE_SIZE div 2);
  TShape(Form1.FindComponent('ResizeShape5')).Top := Y+(H div 2)-(RESIZE_SHAPE_SIZE div 2);

  TShape(Form1.FindComponent('ResizeShape6')).Left := X-(RESIZE_SHAPE_SIZE div 2);
  TShape(Form1.FindComponent('ResizeShape6')).Top := Y+H-(RESIZE_SHAPE_SIZE div 2);

  TShape(Form1.FindComponent('ResizeShape7')).Left := X+(W div 2)-(RESIZE_SHAPE_SIZE div 2);
  TShape(Form1.FindComponent('ResizeShape7')).Top := Y+H-(RESIZE_SHAPE_SIZE div 2);

  TShape(Form1.FindComponent('ResizeShape8')).Left := X+W-(RESIZE_SHAPE_SIZE div 2);
  TShape(Form1.FindComponent('ResizeShape8')).Top := Y+H-(RESIZE_SHAPE_SIZE div 2);

  for i := 1 to 8 do begin
    TShape(Form1.FindComponent('ResizeShape' + IntToStr(i))).Visible := True;
  end;

  GroupBox1.Top := Q((Y+H+GroupBox1.Height+5 < Image1.Height), Y+H+5, Y-GroupBox1.Height-5);
  GroupBox1.Left := X+W-GroupBox1.Width;

  if GroupBox1.Top <= 0 then begin
    GroupBox1.Top := Y+H-GroupBox1.Height-5;
    GroupBox1.Left := X+W-GroupBox1.Width-5;
  end;

  if (GroupBox1.Left < 1) then GroupBox1.Left := 1;

  GroupBox1.Visible := True;
  GroupBox2.Visible := True;
end;


procedure TForm1.DrawShape(X, Y: Integer);
begin
  Image1.Canvas.Brush.Color := clBlack;
  Image1.Canvas.Pen.Color := clWhite;
  Image1.Canvas.Rectangle(X, Y, X+RESIZE_SHAPE_SIZE, Y+RESIZE_SHAPE_SIZE);
end;


procedure TForm1.DrawShapes(X, Y, W, H: Integer);
begin
  DrawShape(X-(RESIZE_SHAPE_SIZE div 2), Y-(RESIZE_SHAPE_SIZE div 2));
  DrawShape(X+(W div 2)-(RESIZE_SHAPE_SIZE div 2), Y-(RESIZE_SHAPE_SIZE div 2));
  DrawShape(X+W-(RESIZE_SHAPE_SIZE div 2), Y-(RESIZE_SHAPE_SIZE div 2));
  DrawShape(X-(RESIZE_SHAPE_SIZE div 2), Y+(H div 2)-(RESIZE_SHAPE_SIZE div 2));
  DrawShape(X+W-(RESIZE_SHAPE_SIZE div 2), Y+(H div 2)-(RESIZE_SHAPE_SIZE div 2));
  DrawShape(X-(RESIZE_SHAPE_SIZE div 2), Y+H-(RESIZE_SHAPE_SIZE div 2));
  DrawShape(X+(W div 2)-(RESIZE_SHAPE_SIZE div 2), Y+H-(RESIZE_SHAPE_SIZE div 2));
  DrawShape(X+W-(RESIZE_SHAPE_SIZE div 2), Y+H-(RESIZE_SHAPE_SIZE div 2));
end;


procedure TForm1.DrawSelect(O, N: TSelection);
var
  i: Integer;
  Text: String;
  S: TSelection;
  diff: TArrayOfSelection;
begin
  if SelectionIntersects(N, O) or SelectionTouches(N, O, False) then begin
    diff := SelectionDifference(N, O);
    for i := 0 to Length(diff)-1 do begin
      if (isSelectionEmpty(diff[i])) then continue;
      BitBlt(Image1.Canvas.Handle, diff[i].X-1, diff[i].Y-1, diff[i].W+1, diff[i].H+1, OriginalBitmap.Canvas.Handle, diff[i].X-1, diff[i].Y-1, SRCCOPY);
    end;
  end;

  //Draw white line arround selection
  Image1.Canvas.Pen.Color := clWhite;
  Image1.Canvas.Brush.Style := bsClear;
  Image1.Canvas.Rectangle(N.X-1, N.Y-1, N.X+N.W, N.Y+N.H);

  //Draw dotted line arround selection
  Image1.Canvas.Pen.Style := psDot;
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Rectangle(N.X-1, N.Y-1, N.X+N.W, N.Y+N.H);
  Image1.Canvas.Pen.Style := psSolid;

  //Draw shapes for resize
  DrawShapes(N.X, N.Y, N.W, N.H);

  //Get text
  Text := Format('%dx%d', [N.W, N.H]);
  S := GetSizeSelection(N);

  //Draw size label
  Image1.Canvas.Brush.Color := clBlack;
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.RoundRect(S.X, S.Y, S.X+S.W, S.Y+S.H, 2, 2);
  Image1.Canvas.TextOut(S.X+6, S.Y+1, Text);
end;


procedure TForm1.ClearShape(O, S: TSelection);
var
  diff: TArrayOfSelection;
  i: Integer;
begin
  BitBlt(Image1.Canvas.Handle, S.X, S.Y, S.W, S.H, OriginalBitmap.Canvas.Handle, S.X, S.Y, SRCCOPY);

  diff := SelectionDifference(S, O);
  for i := 0 to Length(diff)-1 do begin
    if (isSelectionEmpty(diff[i])) then continue;
    BitBlt(Image1.Canvas.Handle, diff[i].X, diff[i].Y, diff[i].W, diff[i].H, AlphaBitmap.Canvas.Handle, diff[i].X, diff[i].Y, SRCCOPY);
  end;
end;


procedure TForm1.ClearShapes(O: TSelection; X, Y, W, H: Integer);
begin
  ClearShape(O, Selection(X-(RESIZE_SHAPE_SIZE div 2), Y-(RESIZE_SHAPE_SIZE div 2), RESIZE_SHAPE_SIZE, RESIZE_SHAPE_SIZE));
  ClearShape(O, Selection(X+(W div 2)-(RESIZE_SHAPE_SIZE div 2), Y-(RESIZE_SHAPE_SIZE div 2), RESIZE_SHAPE_SIZE, RESIZE_SHAPE_SIZE));
  ClearShape(O, Selection(X+W-(RESIZE_SHAPE_SIZE div 2), Y-(RESIZE_SHAPE_SIZE div 2), RESIZE_SHAPE_SIZE, RESIZE_SHAPE_SIZE));
  ClearShape(O, Selection(X-(RESIZE_SHAPE_SIZE div 2), Y+(H div 2)-(RESIZE_SHAPE_SIZE div 2), RESIZE_SHAPE_SIZE, RESIZE_SHAPE_SIZE));
  ClearShape(O, Selection(X+W-(RESIZE_SHAPE_SIZE div 2), Y+(H div 2)-(RESIZE_SHAPE_SIZE div 2), RESIZE_SHAPE_SIZE, RESIZE_SHAPE_SIZE));
  ClearShape(O, Selection(X-(RESIZE_SHAPE_SIZE div 2), Y+H-(RESIZE_SHAPE_SIZE div 2), RESIZE_SHAPE_SIZE, RESIZE_SHAPE_SIZE));
  ClearShape(O, Selection(X+(W div 2)-(RESIZE_SHAPE_SIZE div 2), Y+H-(RESIZE_SHAPE_SIZE div 2), RESIZE_SHAPE_SIZE, RESIZE_SHAPE_SIZE));
  ClearShape(O, Selection(X+W-(RESIZE_SHAPE_SIZE div 2), Y+H-(RESIZE_SHAPE_SIZE div 2), RESIZE_SHAPE_SIZE, RESIZE_SHAPE_SIZE));
end;


procedure TForm1.ClearSizeText(O: TSelection);
var
  S: TSelection;
  ImgHandle: HDC;
  diff: TArrayOfSelection;
  i: Integer;
begin
  S := GetSizeSelection(O);
  ImgHandle := Q(PointInSelection(Point(S.X, S.Y), CurSelect), OriginalBitmap.Canvas.Handle, AlphaBitmap.Canvas.Handle);
  BitBlt(Image1.Canvas.Handle, S.X, S.Y, S.W, S.H, ImgHandle, S.X, S.Y, SRCCOPY);
  if (not SelectionIntersects(S, O) and SelectionContains(O, S)) then Exit;

  diff := SelectionDifference(S, O);
  for i := 0 to Length(diff)-1 do begin
    if (isSelectionEmpty(diff[i])) then continue;
    BitBlt(Image1.Canvas.Handle, diff[i].X, diff[i].Y, diff[i].W, diff[i].H, AlphaBitmap.Canvas.Handle, diff[i].X, diff[i].Y, SRCCOPY);
  end;
end;


procedure TForm1.ClearSelect(O, N: TSelection);
var
  diff: TArrayOfSelection;
  i: Integer;
begin
  ClearSizeText(O);
  ClearShapes(O, O.X, O.Y, O.W, O.H);

  if (not SelectionIntersects(O, N)) then begin
    BitBlt(Image1.Canvas.Handle, O.X-1, O.Y-1, O.W+1, O.H+1, AlphaBitmap.Canvas.Handle, O.X-1, O.Y-1, SRCCOPY);
  end else begin
    diff := SelectionDifference(O, N);
    for i := 0 to Length(diff)-1 do begin
      if (isSelectionEmpty(diff[i])) then continue;
      BitBlt(Image1.Canvas.Handle, diff[i].X-1, diff[i].Y-1, diff[i].W+1, diff[i].H+1, AlphaBitmap.Canvas.Handle, diff[i].X-1, diff[i].Y-1, SRCCOPY);
    end;
  end;
end;


procedure TForm1.Select(O, N: TSelection);
begin
  ClearSelect(O, N);
  DrawSelect(O, N);
  CurSelect := N;
  Image1.Invalidate;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  DesktopHandle: HDC;
  ActiveMonitor: Integer;
  PNGObject: TPNGObject;
  Left, Top, i: Integer;
  Shape: TShape;
begin
  //Get active monitor
  ActiveMonitor := GetActiveMonitor;
  DesktopHandle := GetWindowDC(GetDesktopWindow);

  //Get position of monitor
  Left := Screen.Monitors[ActiveMonitor].Left;
  Top := Screen.Monitors[ActiveMonitor].Top;

  //Resize form to this monitor
  Form1.Left := Left;
  Form1.Top := Top;
  Form1.Width := Screen.Monitors[ActiveMonitor].Width;
  Form1.Height := Screen.Monitors[ActiveMonitor].Height;

  //Create screenshot of this monitor
  OriginalBitmap := TBitmap.Create;
  OriginalBitmap.Width := Screen.Monitors[ActiveMonitor].Width;
  OriginalBitmap.Height := Screen.Monitors[ActiveMonitor].Height;
  BitBlt(OriginalBitmap.Canvas.Handle, 0, 0, OriginalBitmap.Width, OriginalBitmap.Height, DesktopHandle, Left, Top, SRCCOPY);

  //Create same bitmap for darker color
  AlphaBitmap := TBitmap.Create;
  AlphaBitmap.Assign(OriginalBitmap);

  //Convert bitmap to png and back
  PNGObject := TPNGObject.CreateBlank(COLOR_RGB, 16, AlphaBitmap.Width, AlphaBitmap.Height);
  PNGObject.CreateAlpha(155); //Modified TPNGImage so I can set custom alpha
  AlphaBitmap.Canvas.Draw(0, 0, PNGObject);
  Image1.Picture.Assign(AlphaBitmap);

  //Select font for label size
  LabelFont := TFont.Create;
  LabelFont.Color := clWhite;
  LabelFont.Name := 'Calibri';
  LabelFont.Size := 11;
  LabelFont.Style := [fsBold];
  Image1.Canvas.Font.Assign(LabelFont);

  for i := 1 to 8 do begin
    Shape := TShape.Create(self);
    Shape.Parent := Form1;
    Shape.OnMouseDown := ShapeMouseDown;
    Shape.OnMouseUp := ShapeMouseUp;
    Shape.OnMouseMove := ShapeMouseMove;
    Shape.Name := 'ResizeShape' + IntToStr(i);
    Shape.Width := RESIZE_SHAPE_SIZE;
    Shape.Height := RESIZE_SHAPE_SIZE;
    Shape.Brush.Color := clBlack;
    Shape.Pen.Color := clWhite;
    Shape.Visible := False;

    case i of
      1: Shape.Cursor := crSizeNWSE;
      2: Shape.Cursor := crSizeNS;
      3: Shape.Cursor := crSizeNESW;
      4: Shape.Cursor := crSizeWE;
      5: Shape.Cursor := crSizeWE;
      6: Shape.Cursor := crSizeNESW;
      7: Shape.Cursor := crSizeNS;
      8: Shape.Cursor := crSizeNWSE;
    end;
  end;
end;


procedure TForm1.ShapeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Shape: TShape;
  i: Integer;
  R: TRect;
begin
  if (Button <> mbLeft) then Exit;

  for i := 1 to 8 do begin
    TShape(Form1.FindComponent('ResizeShape' + IntToStr(i))).Visible := False;
  end;

  R := Form1.BoundsRect;
  ClipCursor(@R);
  Shape := TShape(Sender);

  case Shape.Cursor of
    crSizeNWSE: ResizeType := RESIZE_BOTH;
    crSizeNS: ResizeType := RESIZE_VERTICAL;
    crSizeNESW: ResizeType := RESIZE_BOTH;
    crSizeWE: ResizeType := RESIZE_HORIZONTAL;
  end;

  if Shape.Name = 'ResizeShape1' then DownPoint := Point(CurSelect.X + CurSelect.W, CurSelect.Y + CurSelect.H);
  if Shape.Name = 'ResizeShape2' then DownPoint := Point(CurSelect.X, CurSelect.Y + CurSelect.H);
  if Shape.Name = 'ResizeShape3' then DownPoint := Point(CurSelect.X, CurSelect.Y + CurSelect.H);
  if Shape.Name = 'ResizeShape4' then DownPoint := Point(CurSelect.X + CurSelect.W, CurSelect.Y);
  if Shape.Name = 'ResizeShape5' then DownPoint := Point(CurSelect.X, CurSelect.Y);
  if Shape.Name = 'ResizeShape6' then DownPoint := Point(CurSelect.X + CurSelect.W, CurSelect.Y);
  if Shape.Name = 'ResizeShape7' then DownPoint := Point(CurSelect.X, CurSelect.Y);
  if Shape.Name = 'ResizeShape8' then DownPoint := Point(CurSelect.X, CurSelect.Y);

  BMouseDown := True;
end;


procedure TForm1.ShapeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ResizeType := 0;
  ObjectMouseUp(Sender, Button, Shift, X, Y);
end;


procedure TForm1.ShapeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  ObjectMouseMove(Image1, Shift, TShape(Sender).Left+X, TShape(Sender).Top+Y);
end;


procedure TForm1.ObjectMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  R: TRect;
begin
  if (Button <> mbLeft) then Exit;
  Image1.ShowHint := False;
  Application.HideHint;

  for i := 1 to 8 do begin
    TShape(Form1.FindComponent('ResizeShape' + IntToStr(i))).Visible := False;
  end;

  GroupBox1.Visible := False;
  GroupBox2.Visible := False;

  R := Form1.BoundsRect;
  ClipCursor(@R);
  DownPoint := Point(X, Y);

  if PointInSelection(Point(X, Y), CurSelect) then begin
    BSelectionMove := True;
    Exit;
  end;

  BitBlt(Image1.Canvas.Handle, 0, 0, AlphaBitmap.Width, AlphaBitmap.Height, AlphaBitmap.Canvas.Handle, 0, 0, SRCCOPY);
  Select(Selection(X, Y, 0, 0), Selection(X, Y, 0, 0));
  BMouseDown := True;
end;


procedure TForm1.ObjectMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  BSelectionMove := False;
  BMouseDown := False;
  ClipCursor(nil);

  if BSelectionMove then Exit;

  if (CurSelect.W = 0) or (CurSelect.H = 0) then begin
    Image1.ShowHint := True;
    Application.ActivateHint(ClientToScreen(Point(X, Y)));

    for i := 1 to 8 do begin
      TShape(Form1.FindComponent('ResizeShape' + IntToStr(i))).Visible := False;
    end;

    GroupBox1.Visible := False;
    GroupBox2.Visible := False;

    BitBlt(Image1.Canvas.Handle, 0, 0, AlphaBitmap.Width, AlphaBitmap.Height, AlphaBitmap.Canvas.Handle, 0, 0, SRCCOPY);
    Image1.Invalidate;
  end else begin
     MoveShapes(CurSelect.X, CurSelect.Y, CurSelect.W, CurSelect.H);
  end;
end;


procedure TForm1.ObjectMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  NewSelect: TSelection;
  CurrentPoint: TPoint;
begin
  if BMouseDown then begin
    CurrentPoint := Point(X, Y);
    NewSelect.X := Min(CurrentPoint.X, DownPoint.X);
    NewSelect.Y := Min(CurrentPoint.Y, DownPoint.Y);
    NewSelect.W := Abs(CurrentPoint.X - DownPoint.X);
    NewSelect.H := Abs(CurrentPoint.Y - DownPoint.Y);

    if (ResizeType = RESIZE_VERTICAL) then begin
      NewSelect.X := CurSelect.X;
      NewSelect.W := CurSelect.W;
    end;

    if (ResizeType = RESIZE_HORIZONTAL) then begin
      NewSelect.Y := CurSelect.Y;
      NewSelect.H := CurSelect.H;
    end;

    Select(CurSelect, NewSelect);
    Exit;
  end;

  if BSelectionMove then begin
    NewSelect := CurSelect;
    NewSelect.X := NewSelect.X - (DownPoint.X - X);
    NewSelect.Y := NewSelect.Y - (DownPoint.Y - Y);

    if NewSelect.X < 0 then begin NewSelect.W := NewSelect.W + NewSelect.X; NewSelect.X := 0 end;
    if NewSelect.Y < 0 then begin NewSelect.H := NewSelect.H + NewSelect.Y; NewSelect.Y := 0 end;
    if (NewSelect.X + NewSelect.W) > Form1.Width then NewSelect.W := NewSelect.W - (NewSelect.W - (Form1.Width - NewSelect.X));
    if (NewSelect.Y + NewSelect.H) > Form1.Height then NewSelect.H := NewSelect.H - (NewSelect.H - (Form1.Height - NewSelect.Y));

    if NewSelect.W < 0 then NewSelect.W := 0;
    if NewSelect.H < 0 then NewSelect.H := 0;

    DownPoint := Point(X, Y);
    Select(CurSelect, NewSelect);
    Exit;
  end;

  if Image1.ShowHint then Application.ActivateHint(ClientToScreen(Point(X, Y))) else Application.HideHint;
  Image1.Cursor := Q(PointInSelection(Point(X, Y), CurSelect), crSizeAll, crDefault);
end;


procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then Application.Terminate;
end;

end.
