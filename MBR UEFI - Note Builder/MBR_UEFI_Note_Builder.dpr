program MBR_UEFI_Note_Builder_Created_By_Serbinskis;

uses
  Forms,
  MBR_UEFI_Note_Builder in 'MBR_UEFI_Note_Builder.pas' {Form1};

{$R MBR_UEFI_Note_Builder.res}

begin
  Application.Initialize;
  Application.Title := 'MBR/UEFI - Note Builder';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
