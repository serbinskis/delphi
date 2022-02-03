program WebCam_Created_By_WobbyChip;

uses
  Forms,
  VFrames in 'Include\VFrames.pas',
  DirectShow9 in 'Include\DirectShow9.pas',
  DirectSound in 'Include\DirectSound.pas',
  DXTypes in 'Include\DXTypes.pas',
  UGDIPlus in 'Include\UGDIPlus.pas',
  VSample in 'Include\VSample.pas',
  Direct3D9 in 'Include\Direct3D9.pas',
  DirectDraw in 'Include\DirectDraw.pas',
  WebCam in 'WebCam.pas' {Form1};

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
