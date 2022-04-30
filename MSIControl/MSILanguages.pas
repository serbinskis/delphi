unit MSILanguages;

interface

uses
  Windows, SysUtils, Classes, MMSystem, TNTRegistry, TNTClasses, uHotKey,
  MSISettings, Functions;

const
  DEFAULT_LANGUAGE_KEY = '\Software\MSIControl\Languages';

var
  lOldHotKey: Integer;
  lNewHotKey: Integer;

procedure LoadLanguageSetting;
procedure GetLanguageList(List: TStrings);
procedure SetLanguageHotKey(kbLayout: HKL; oHotKey, nHotKey: Integer);
function GetLanguageHotKey(kbLayout: HKL): Integer;
function LayoutActive(kbLayout: HKL):Boolean;
function ChangeKeyboardLayout(kbLayout: HKL): Boolean;

implementation

uses
  MSIControl;

procedure LanguageHotKeyCallback(Key, ShortCut: Integer; CustomValue: Variant);
begin
  if GetSettingByName('LANGUAGES_HOTKEY_SOUNDS') then PlaySound('HOTKEY', 0, SND_RESOURCE or SND_ASYNC);
  ChangeKeyboardLayout(CustomValue);
end;

procedure LoadLanguageSetting;
var
  Registry: TTNTRegistry;
  SubList: TTNTStringList;
  i, HotKey: Integer;
  kbLayout: HKL;
begin
  SubList := TTNTStringList.Create;
  Registry := TTNTRegistry.Create;
  Registry.RootKey := DEFAULT_ROOT_KEY;
  Registry.OpenKey(DEFAULT_LANGUAGE_KEY, True);
  Registry.GetValueNames(SubList);

  for i := 0 to SubList.Count-1 do begin
    HotKey := Registry.ReadInteger(SubList.Strings[i]);
    kbLayout := StrToInt64(SubList.Strings[i]);
    if (HotKey > 0) and LayoutActive(kbLayout) then SetShortCut(LanguageHotKeyCallback, HotKey, kbLayout);
  end;

  SubList.Free;
  Registry.Free;
end;

procedure GetLanguageList(List: TStrings);
var
  HklList: array [0..9] of HKL;
  AklName: array [0..255] of WideChar;
  i: Integer;
begin
  List.Clear;
  List.AddObject('Next', Pointer(1));
  List.AddObject('Previous', Pointer(0));

  for i := 0 to GetKeyboardLayoutList(SizeOf(HklList), HklList)-1 do begin
    GetLocaleInfoW(LoWord(HklList[i]), LOCALE_SLANGUAGE, AklName, SizeOf(AklName));
    List.AddObject(AklName, Pointer(HklList[i]));
  end;
end;

procedure SetLanguageHotKey(kbLayout: HKL; oHotKey, nHotKey: Integer);
var
  Key: Integer;
begin
  if nHotKey > 0 then begin
    SaveRegistryInteger(nHotKey, DEFAULT_ROOT_KEY, DEFAULT_LANGUAGE_KEY, IntToStr(kbLayout));
    if oHotKey <> 0 then Key := ShortCutToHotKey(oHotKey) else Key := -1;
    if Key > -1 then ChangeShortCut(Key, nHotKey) else SetShortCut(LanguageHotKeyCallback, nHotKey, kbLayout);
  end else begin
    DeleteRegistryValue(DEFAULT_ROOT_KEY, DEFAULT_LANGUAGE_KEY, IntToStr(kbLayout));
  end;
end;

function GetLanguageHotKey(kbLayout: HKL): Integer;
begin
  Result := 0;
  LoadRegistryInteger(Result, DEFAULT_ROOT_KEY, DEFAULT_LANGUAGE_KEY, IntToStr(kbLayout));
end;

function LayoutActive(kbLayout: HKL):Boolean;
var
  HklList: array [0..9] of HKL;
  i: Integer;
begin
  Result := True;
  if (kbLayout = 0) or (kbLayout = 1) then Exit;
  Result := False;

  for i := 0 to GetKeyboardLayoutList(SizeOf(HklList), HklList)-1 do begin
    if HklList[i] = kbLayout then Result := True;
  end;
end;

function WndProc(hWnd, Msg: Longint; wParam: WPARAM; lParam: LPARAM): Longint; stdcall;
begin
  Result := DefWindowProc(hWnd, Msg, wParam, lParam);
end;

procedure MessageLoop(Parameter: Pointer);
var
  LWndClass: TWndClass;
  Msg: TMsg;
begin
  FillChar(LWndClass, SizeOf(LWndClass), 0);
  LWndClass.hInstance := HInstance;
  LWndClass.lpszClassName := PChar(IntToStr(Random(MaxInt)) + 'Wnd');
  LWndClass.Style := CS_PARENTDC;
  LWndClass.lpfnWndProc := @WndProc;

  Windows.RegisterClass(LWndClass);
  CreateWindow(LWndClass.lpszClassName, nil, 0,0,0,0,0,0,0, HInstance, nil);
  String(Parameter^) := LWndClass.lpszClassName;

  while GetMessage(Msg, 0,0,0) do begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;

//This causes memory leak, idk where and how to fix it
function ChangeKeyboardLayout(kbLayout: HKL): Boolean;
const
  WM_INPUTLANGCHANGEREQUEST = $0050;
var
  Dummy: DWORD;
  fWindow: HWND;
  WinHandle: HWND;
  ThreadID: Cardinal;
  lpszClassName: String;
begin
  ThreadID := BeginThread(nil, 0, Addr(MessageLoop), Addr(lpszClassName), 0, ThreadID);
  while lpszClassName = '' do Sleep(1);
  WinHandle := FindWindow(PChar(lpszClassName), nil);

  fWindow := GetForegroundWindow;
  SetForegroundWindow(WinHandle);
  Result := SendMessageTimeOut(WinHandle, WM_INPUTLANGCHANGEREQUEST, 0, kbLayout, SMTO_ABORTIFHUNG, 200, Dummy) <> 0;
  SetForegroundWindow(fWindow);

  TerminateThread(ThreadID, 0);
  DestroyWindow(WinHandle);
  Windows.UnregisterClass(PChar(lpszClassName), HInstance);
end;

end.