program VoiceChatServer_Created_By_WobbyChip;

uses
  Forms,
  VoiceChatServer in 'VoiceChatServer.pas' {Form1};

{$R VoiceChatServer.res}

begin
  Application.Initialize;
  Application.Title := 'Voice Chat Server';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
