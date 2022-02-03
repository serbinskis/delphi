unit YouTube;

interface

uses
  Windows, SysUtils, WinInet, Variants, Classes, Graphics, Controls, Forms, StdCtrls,
  TntStdCtrls, TFlatEditUnit, TFlatComboBoxUnit, uYouTubeYtDownload, TNTSystem, DateUtils,
  Functions;

type
  TForm4 = class(TForm)
    StaticText1: TStaticText;
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TFlatComboBox;
    Edit1: TTntEdit;
    Edit2: TTntEdit;
    procedure EditExit(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  pYouTube: TYouTubeYtDownload;
  DownloadThread: DWORD;
  DownloadCancel: Boolean = False;

implementation

uses Soundboard;

{$R *.dfm}

procedure ComponenetsEnabled(Enabled: Boolean);
begin
  Form4.Edit1.Enabled := Enabled;
  Form4.Edit2.Enabled := Enabled;
  Form4.Button1.Enabled := Enabled;
  Form4.Button2.Enabled := Enabled;
  Form4.ComboBox1.Enabled := Enabled;
end;


procedure TForm4.FormCreate(Sender: TObject);
begin
  pYouTube := TYouTubeYtDownload.Create;
end;


procedure TForm4.FormShow(Sender: TObject);
begin
  if SettingsDB.StayOnTop
    then SetWindowPos(Handle, HWND_TOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE)
    else SetWindowPos(Handle, HWND_NOTOPMOST, 0,0,0,0, SWP_NOMOVE or SWP_NOSIZE);

  Form4.Top := Form1.Top + Round((Form1.Height - Form4.Height)/2);
  Form4.Left := Form1.Left + Round((Form1.Width - Form4.Width)/2);
  ComponenetsEnabled(True);
  DownloadCancel := False;

  StaticText1.SetFocus;
  Edit1.Text := '';
  Edit2.Text := '';

  EditExit(Edit1);
  EditExit(Edit2);

  ComboBox1.ItemIndex := -1;
  ComboBox1.Clear;
  StaticText1.Caption := FormatSize(0, 0);
end;


procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DownloadCancel := True;
end;


procedure TForm4.EditExit(Sender: TObject);
begin
  if TEdit(Sender).Text <> '' then Exit;
  TEdit(Sender).Text := TEdit(Sender).Hint;
  TEdit(Sender).Font.Color := clGray;
end;


procedure TForm4.EditEnter(Sender: TObject);
begin
  if TEdit(Sender).Font.Color <> clGray then Exit;
  TEdit(Sender).Text := '';
  TEdit(Sender).Font.Color := clBlack;
end;


procedure TForm4.Button1Click(Sender: TObject);
var
  i: Integer;
  YouTubeMedia: PYouTubeMediaYtDownload;
begin
  if Edit1.Font.Color = clGray then Exit;

  ComponenetsEnabled(False);
  pYouTube.ParseAudio(Edit1.Text);
  ComboBox1.Clear;

  for i := 0 to pYouTube.GetAudioCount-1 do begin
    YouTubeMedia := pYouTube.GetAudioItem(i);
    ComboBox1.Items.Add(UpperCase(Copy(YouTubeMedia.Exstension, 2, Length(YouTubeMedia.Exstension))) + ' | ' + YouTubeMedia.Quality + ' | ' + YouTubeMedia.SizeString);
  end;

  if pYouTube.GetAudioCount > 0 then begin
    EditEnter(Edit2);
    ComboBox1.ItemIndex := 0;
    Edit2.Text := pYouTube.GetAudioItem(0).Name;
  end;

  ComponenetsEnabled(True);
end;


procedure DownloadProgress;
var
  hSession, hURL: HInternet;
  Buffer: array[1..1024*100] of Byte;
  SavedDate: TDateTime;
  Origin: Cardinal;
  BufferLen: DWORD;
  YouTubeMedia: PYouTubeMediaYtDownload;
  MemoryStream: TMemoryStream;
  Memory: TMemory;
begin
  ComponenetsEnabled(False);

  if Form4.ComboBox1.Items.Count <= 0 then begin
    ComponenetsEnabled(True);
    EndThread(0);
  end;

  if Form4.Edit2.Font.Color = clGray then begin
    MessageBeep(MB_ICONEXCLAMATION);
    Windows.MessageBox(0, 'Name cannot be empty.', PChar(Form1.Caption), MB_OK);
    ComponenetsEnabled(True);
    EndThread(0);
  end;

  if Length(SettingsDB.AudioTable) >= 999 then begin
    MessageBeep(MB_ICONEXCLAMATION);
    Windows.MessageBox(0, 'The limit of maximum sounds has been reached.', PChar(Form1.Caption), MB_OK);
    ComponenetsEnabled(True);
    EndThread(0);
  end;

  if not InternetGetConnectedState(@Origin, 0) then begin
    ComponenetsEnabled(True);
    EndThread(0);
  end;

  YouTubeMedia := pYouTube.GetAudioItem(Form4.ComboBox1.ItemIndex);
  hSession := InternetOpenW(PWideChar(WideParamStr(0)), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  hURL := InternetOpenUrlW(hSession, PWideChar(YouTubeMedia.URL), nil, 0, INTERNET_FLAG_NO_CACHE_WRITE, 0);

  BufferLen := 0;
  MemoryStream := TMemoryStream.Create;
  SavedDate := Now;

  repeat
    if DownloadCancel then begin
      MemoryStream.Free;
      InternetCloseHandle(hSession);
      EndThread(0);
    end;

    if (CountMemory(SettingsDB.AudioTable) + YouTubeMedia.Size) >= MAXIMUM_SIZE then begin
      MemoryStream.Free;
      InternetCloseHandle(hSession);
      MessageBeep(MB_ICONEXCLAMATION);
      Windows.MessageBox(0, PChar('The maximum size has been reached ' + FormatSize(MAXIMUM_SIZE, 0) + '.'), PChar(Form1.Caption), MB_OK);
      ComponenetsEnabled(True);
      EndThread(0);
    end;

    InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen);
    MemoryStream.Write(Buffer, BufferLen);
    YouTubeMedia.Size := MemoryStream.Size;

    if MilliSecondsBetween(Now, SavedDate) >= 50 then begin
      Form4.StaticText1.Caption := FormatSize(MemoryStream.Size, 2);
      SavedDate := Now;
    end;
  until BufferLen = 0;

  InternetCloseHandle(hSession);
  SetLength(Memory, MemoryStream.Size);
  MemoryStream.Position := 0;
  MemoryStream.Read(Memory[0], MemoryStream.Size);
  MemoryStream.Free;

  InsertToList(SettingsDB.AudioTable, Length(SettingsDB.AudioTable), Form4.Edit2.Text, '', YouTubeMedia.Exstension, False, Memory, False);
  BuildList(SettingsDB.AudioTable);
  Windows.Beep(700, 150);

  ComponenetsEnabled(True);
  EndThread(0);
end;


procedure TForm4.Button2Click(Sender: TObject);
begin
  BeginThread(nil, 0, Addr(DownloadProgress), nil, 0, DownloadThread);
end;

end.
