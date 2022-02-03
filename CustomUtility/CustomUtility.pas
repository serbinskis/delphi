unit CustomUtility;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellAPI, ComCtrls, TntStdCtrls, WinXP, TFlatEditUnit,
  TFlatSpinEditUnit, ExtCtrls, Functions, TNTClipBrd, TNTGraphics, TNTSystem,
  OleCtrls, SHDocVw, uZeroWipe, uDiacriticsRemover, uCompressImages, uReplaceText,
  uZeroRename, uTraceApplication;


type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    Timer1: TTimer;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TNTListBox1: TTNTListBox;
    TNTListBox2: TTntListBox;
    TNTListBox3: TTntListBox;
    TNTListBox4: TTntListBox;
    TNTListBox5: TTntListBox;
    TNTListBox6: TTntListBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    FlatSpinEdit1: TFlatSpinEditInteger;
    TNTEdit1: TTntEdit;
    TNTEdit2: TTntEdit;
    Button1: TButton;
    Others: TTabSheet;
    Button2: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TNTListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TNTListBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  protected
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
    { Public declarations }
  end;

type
  TChangeWindowMessageFilter = function(msg: Cardinal; Action: Dword): BOOL; stdcall;

const
  WM_COPYGLOBALDATA = 73;
  MSGFLT_ADD = 1;

var
  Form1: TForm1;
  User32Module: THandle;
  ChangeWindowMessageFilterPtr: Pointer;

implementation

{$R *.dfm}


//WMDropFiles
procedure TForm1.WMDropFiles(var Msg: TMessage);
begin
  SetActiveWindow(Handle);
  SetForegroundWindow(Handle);

  if PageControl1.Pages[PageControl1.TabIndex].Caption = 'Zero Wipe' then begin
    ProceedZeroWipe(Msg);
    Exit;
  end;

  if PageControl1.Pages[PageControl1.TabIndex].Caption = 'Remove Diacritics' then begin
    ProceedRemoveDiacritics(Msg);
    Exit;
  end;

  if PageControl1.Pages[PageControl1.TabIndex].Caption = 'Compress Images' then begin
    ProceedImageCompress(Msg);
    Exit;
  end;

  if PageControl1.Pages[PageControl1.TabIndex].Caption = 'Replace Text' then begin
    ProceedReplaceText(Msg);
    Exit;
  end;

  if PageControl1.Pages[PageControl1.TabIndex].Caption = 'Zero Rename' then begin
    ProceedZeroRename(Msg);
    Exit;
  end;

  if PageControl1.Pages[PageControl1.TabIndex].Caption = 'Trace Application' then begin
    TraceApplication(Msg);
    Exit;
  end;
end;
//WMDropFiles


//CheckUser32Module
function CheckUser32Module: Boolean;
begin
  if User32Module = 0 then User32Module := SafeLoadLibrary('USER32.DLL');
  Result := User32Module > HINSTANCE_ERROR;
end;
//CheckUser32Module


//CheckUser32ModuleFunc
function CheckUser32ModuleFunc(const Name: String; var Ptr: Pointer): Boolean;
begin
  Result := CheckUser32Module;
  if Result then begin
    Ptr := GetProcAddress(User32Module, PChar(Name));
    Result := Assigned(Ptr);
    if not Result then Ptr := Pointer(1);
  end;
end;
//CheckUser32ModuleFunc


//ChangeWindowMessageFilter
function ChangeWindowMessageFilter(msg: Cardinal; Action: Dword): BOOL;
var
  B1, B2: Boolean;
begin
  B1 := Integer(ChangeWindowMessageFilterPtr) > 1;
  B2 := CheckUser32ModuleFunc('ChangeWindowMessageFilter', ChangeWindowMessageFilterPtr);

  if B1 or B2
    then Result := TChangeWindowMessageFilter(ChangeWindowMessageFilterPtr)(Cardinal(Msg), Action)
    else Result := False;
end;
//ChangeWindowMessageFilter


procedure TForm1.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
  ChangeWindowMessageFilter(WM_DROPFILES, MSGFLT_ADD);
  ChangeWindowMessageFilter(WM_COPYGLOBALDATA, MSGFLT_ADD);
  PageControl1.ActivePageIndex := 0;
end;


procedure TForm1.FormShow(Sender: TObject);
begin
  SetForegroundWindow(Application.MainForm.Handle);
end;


procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  TerminateProcess(OpenProcess(PROCESS_TERMINATE, False, GetCurrentProcessId), 0);
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (TNTEDit1.Text = '') and (not TNTEDit1.Focused) then SetPlaceholder(TNTEDit1, TNTEDit1.Font, TNTEDit1.Hint);
  if (TNTEDit2.Text = '') and (not TNTEDit2.Focused) then SetPlaceholder(TNTEDit2, TNTEDit2.Font, TNTEDit2.Hint);
end;


procedure TForm1.TNTListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and ((Key = Ord('c')) or (Key = Ord('C'))) then begin
    TNTClipboard.AsWideText := TTNTListBox(Sender).Items[TTNTListBox(Sender).ItemIndex];
  end;
end;


procedure TForm1.TNTListBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with Control as TTNTListBox do begin
    Canvas.FillRect(Rect);
    Canvas.Font.Color := TColor(Items.Objects[Index]);
    WideCanvasTextOut(Canvas, Rect.Left + 2, Rect.Top, Items[Index]);
  end;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  ExecuteProcess(WideParamStr(0), '-WakeOnLan', SW_SHOW);
  Application.Terminate;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  ExecuteProcess(WideParamStr(0), '-CryptoGraph', SW_SHOW);
  Application.Terminate;
end;


end.
