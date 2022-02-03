program MBRImageBuilder_Created_By_WobbyChip;

uses
  Windows, Forms,
  MBR_Image_Builder in 'MBR_Image_Builder.pas' {Form1},
  Guide in 'Guide.pas' {Form2};

{$R MBR_Image_Builder.res}

var
  hMutex: THandle;
begin
  hMutex := CreateMutex(nil, False, 'MBR_Image_Builder');
  if WaitForSingleObject(hMutex, 0) <> WAIT_TIMEOUT then begin
    Application.Initialize;
    Application.Title := 'MBR - Image Builder';
    Application.CreateForm(TForm1, Form1);
    Application.CreateForm(TForm2, Form2);
    Application.Run;
  end;
end.
