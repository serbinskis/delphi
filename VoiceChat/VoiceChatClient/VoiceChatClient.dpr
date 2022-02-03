program VoiceChatClient_Created_By_WobbyChip;

uses
  Forms,
  WaveACM in 'WaveAudio\WaveACM.pas',
  WaveIn in 'WaveAudio\WaveIn.pas',
  WaveIO in 'WaveAudio\WaveIO.pas',
  WaveMixer in 'WaveAudio\WaveMixer.pas',
  WaveOut in 'WaveAudio\WaveOut.pas',
  WavePlayers in 'WaveAudio\WavePlayers.pas',
  WaveRecorders in 'WaveAudio\WaveRecorders.pas',
  WaveRedirector in 'WaveAudio\WaveRedirector.pas',
  WaveStorage in 'WaveAudio\WaveStorage.pas',
  WaveTimer in 'WaveAudio\WaveTimer.pas',
  WaveUtils in 'WaveAudio\WaveUtils.pas',
  VoiceChatClient in 'VoiceChatClient.pas' {Form1},
  LogIn in 'LogIn.pas' {Form2},
  Administrator in 'Administrator.pas' {Form3};

{$R VoiceChatClient.res}

begin
  Application.Initialize;
  Application.Title := 'Voice Chat Client';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
