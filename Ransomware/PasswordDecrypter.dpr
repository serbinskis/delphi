program PasswordDecrypter;

{$APPTYPE CONSOLE}

uses
  uCryptoKey;

var
  SeedKey, EncryptedKey: String;
begin
  Write('ID: ');
  ReadLn(SeedKey);

  Write('Key: ');
  ReadLn(EncryptedKey);

  Write('DecryptedKey -> ', DecryptKey(EncryptedKey, SeedKey));
  ReadLn;
end.
