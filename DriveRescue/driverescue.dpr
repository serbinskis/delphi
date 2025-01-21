program driverescue;

{$APPTYPE CONSOLE}

uses
  Windows, Classes, SysUtils, TNTSystem, TNTSysUtils, Functions, DateUtils;


function GetDiskSectorSize(hDisk: THandle): DWORD;
const
  IOCTL_DISK_GET_DRIVE_GEOMETRY = $00070000;
type
  {$MINENUMSIZE 4}
  TMediaType = (Unknown, F5_1Pt2_512, F3_1Pt44_512, F3_2Pt88_512, F3_20Pt8_512, F3_720_512, F5_360_512,
                F5_320_512, F5_320_1024, F5_180_512, F5_160_512, RemovableMedia, FixedMediaF3_120M_512);
  {$MINENUMSIZE 1}
  TDiskGeometry = packed record
    Cylinders: int64;
    MediaType: TMediaType;
    TracksPerCylinder: DWORD;
    SectorsPerTrack: DWORD;
    BytesPerSector: DWORD;
  end;
var
  BytesReturned: DWORD;
  DiskGeometry: TDiskGeometry;
begin
  Result := 0;
  if not DeviceIoControl(hDisk, IOCTL_DISK_GET_DRIVE_GEOMETRY, nil, 0, @DiskGeometry, SizeOf(DiskGeometry), BytesReturned, nil) then Exit;
  Result := DiskGeometry.BytesPerSector;
end;


function GetDiskLengthInBytes(hDisk: THandle): Int64;
const
  IOCTL_DISK_GET_LENGTH_INFO = $0007405C;
type
  TDiskLength = packed record
    Length: Int64;
  end;
var
  BytesReturned: DWORD;
  DiskLength: TDiskLength;
begin
  Result := -1;
  BytesReturned := 0;
  if not DeviceIoControl(hDisk, IOCTL_DISK_GET_LENGTH_INFO, nil, 0, @DiskLength, SizeOf(TDiskLength), BytesReturned, nil) then Exit;
  Result := DiskLength.Length;
end;


type
  TByteArray = array of Byte;

type
  TDiskInfo = packed record
    DiskHandle: THandle;
    DiskSize: Int64;
    SectorSize: DWORD;
  end;

const
  UPDATE_INTERVAL = 100;
  FILE_DEVICE_FILE_SYSTEM = $00000009;
  FILE_ANY_ACCESS = 0;
  METHOD_NEITHER = 3;
  DAMAGED_AREA_PATTERN = 'UNREADABLESECTOR';
  FSCTL_ALLOW_EXTENDED_DASD_IO = ((FILE_DEVICE_FILE_SYSTEM shl 16) or (FILE_ANY_ACCESS shl 14) or (32 shl 2) or METHOD_NEITHER);


function SetFilePointer(hFile: THandle; lDistanceToMove: Int64; dwMoveMethod: DWORD): DWORD;
var
  DistanceLow, DistanceHigh: Longint;
begin
  DistanceLow := lDistanceToMove and $FFFFFFFF;   // Lower 32 bits
  DistanceHigh := lDistanceToMove shr 32;         // Upper 32 bits
  Result := Windows.SetFilePointer(hFile, DistanceLow, @DistanceHigh, dwMoveMethod);
end;


function InitializeDamagedBuffer(SectorSize: Integer): TByteArray;
var
  i: Integer;
begin
  SetLength(Result, SectorSize);

  for i := 0 to SectorSize div Length(DAMAGED_AREA_PATTERN) - 1 do
    Move(DAMAGED_AREA_PATTERN[1], Result[i * Length(DAMAGED_AREA_PATTERN)], Length(DAMAGED_AREA_PATTERN));
end;


function IsDamagedBuffer(var InBuffer: TByteArray): Boolean;
var
  i: Integer;
  DamagedBuffer: TByteArray;
begin
  DamagedBuffer := InitializeDamagedBuffer(Length(InBuffer));
  Result := False;

  for i := 0 to High(InBuffer) do begin
    if (InBuffer[i] <> DamagedBuffer[i]) then Exit;
  end;

  Result := True;
end;


function IsDamagedSector(hIn: THandle; Address: Longint; SectorSize: Integer): Boolean;
var
  nr: DWORD;
  Buffer: TByteArray;
begin
  ReadFile(hIn, Buffer, SectorSize, nr, nil);
  Result := IsDamagedBuffer(Buffer);
end;


function InitializeInputDisk(InputDrive: WideString): TDiskInfo;
var
  nr: DWORD;
begin
  repeat
    Result.DiskHandle := CreateFileW(PWideChar('\\.\' + InputDrive), GENERIC_READ, FILE_SHARE_WRITE + FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
    Result.DiskSize := GetDiskLengthInBytes(Result.DiskHandle);
    if (Result.DiskSize > 0) then Result.SectorSize := GetDiskSectorSize(Result.DiskHandle);
    if (Result.DiskSize < 0) then Result.DiskHandle := INVALID_HANDLE_VALUE;
    if (Result.DiskSize < 0) then WriteLn('Drive (', InputDrive, ') is not connected.');
    if (Result.DiskSize < 0) then Sleep(1000);
  until (Result.DiskHandle <> INVALID_HANDLE_VALUE);

  //Allow to read final bytes
  DeviceIoControl(Result.DiskHandle, FSCTL_ALLOW_EXTENDED_DASD_IO, nil, 0, nil, 0, nr, nil);
end;


function IsDiskInitialized(DiskHandle: THandle): Boolean;
begin
  Result := GetDiskLengthInBytes(DiskHandle) <> -1;
end;


function ReadDiskBytes(hIn: THandle; Address: Int64; SectorSize: Integer; MaxRetry: Integer): TByteArray;
var
  nr: DWORD;
  CurrentRetry: DWORD;
begin
  SetLength(Result, SectorSize);
  SetFilePointer(hIn, Address, FILE_BEGIN);
  CurrentRetry := 0;

  repeat
    if (ReadFile(hIn, Result[0], SectorSize, nr, nil)) then Exit;
    //WriteLn(SysErrorMessage(GetLastError));
    WriteLn('Error reading data at ', IntToStr(Address), ' (CurrentRetry: ', CurrentRetry, '/', MaxRetry, ' | SectorSize: ', IntToStr(SectorSize), ')');
    Inc(CurrentRetry);
  until (CurrentRetry >= MaxRetry);

  Result := InitializeDamagedBuffer(SectorSize);
end;


procedure CopyDisk(InputPath, OutputPath: WideString; SectorCount, MaxRetry: Integer);
var
  DiskInfo: TDiskInfo;
  hOut, nw: THandle;
  TotalRead, TotalErros: Int64;
  SavedTime: TDateTime;
  Buffer: TByteArray;
begin
  hOut := CreateFileW(PWideChar(OutputPath), GENERIC_WRITE, FILE_SHARE_WRITE + FILE_SHARE_READ, nil, OPEN_ALWAYS, 0,0); //Create ouput file
  TotalRead := Q(WideFileExists(OutputPath), GetFileSize(OutputPath), 0); //Get output file size or, just initialize as 0
  SetFilePointer(hOut, TotalRead, FILE_BEGIN); //Set pointer to continue to write at the end of file
  SavedTime := Now; //Save current time for logging
  TotalErros := 0;

  //WriteLn(FormatSize(InitializeInputDisk(InputPath).DiskSize, 2));
  //WriteLn(FormatSize(InitializeInputDisk(InputPath).DiskSize - (1024 * 1024 * 20), 2));
  //SetFilePointer(hOut, InitializeInputDisk(InputPath).DiskSize - (1024 * 1024 * 20), FILE_BEGIN);
  //SetEndOfFile(hOut);
  //TerminateProcess(GetCurrentProcess, 0);

  while (true) do begin
    WriteLn('Initializing disk: ', InputPath);
    DiskInfo := InitializeInputDisk(InputPath); //Initialize disk info

    while (TotalRead < DiskInfo.DiskSize) do begin //While have bytes to read, then read them
      Buffer := ReadDiskBytes(DiskInfo.DiskHandle, TotalRead, DiskInfo.SectorSize * SectorCount, MaxRetry); //Read sector of specified size into buffer
      if (not IsDiskInitialized(DiskInfo.DiskHandle)) then Break; //Reinitialize disk (maybe disk was discconected)
      TotalRead := TotalRead + Length(Buffer); //Update total read bytes
      WriteFile(hOut, Buffer[0], Length(Buffer), nw, nil); //Write current buffer to output file
      if (IsDamagedBuffer(Buffer)) then TotalErros := TotalErros + Length(Buffer); //If buffer is damaged, just add it to statistics

      //Write total bytes progress to console with some interval
      if (MillisecondsBetween(SavedTime, Now) < UPDATE_INTERVAL) then Continue;
      SavedTime := Now; //Update time, so that we don't spam console
      WriteLn(Format('Read: %s/%s | Errors: %s (%d) %.1f%%', [FormatSize(TotalRead, 4), FormatSize(DiskInfo.DiskSize, 4), FormatSize(TotalErros, 4), (TotalErros div DiskInfo.SectorSize), (TotalErros/TotalRead*100)]));
    end;

    if (TotalRead >= DiskInfo.DiskSize) then Break;
  end;

  CloseHandle(hOut); //Close output file
  CloseHandle(DiskInfo.DiskHandle); //Close input file
  WriteLn(Format('Finished: %s | Errors: %s (%d) %.1f%%', [FormatSize(TotalRead, 4), FormatSize(TotalErros, 4), (TotalErros div DiskInfo.SectorSize), (TotalErros/TotalRead*100)]));
end;


function RepairDisk(InputPath, OutputPath: WideString; MaxRetry: Integer): Boolean;
var
  DiskInfo: TDiskInfo;
  hOut, nw: THandle;
  TotalRead, TotalFixed, TotalErrors: Int64;
  SavedTime: TDateTime;
  Buffer: TByteArray;
begin
  hOut := CreateFileW(PWideChar(OutputPath), GENERIC_READ or GENERIC_WRITE, FILE_SHARE_WRITE + FILE_SHARE_READ, nil, OPEN_ALWAYS, 0,0); //Create ouput file
  Result := True;
  SavedTime := Now; //Save current time for logging
  TotalRead := 0;
  TotalFixed := 0;
  TotalErrors := 0;

  while (true) do begin
    WriteLn('Initializing disk: ', InputPath);
    DiskInfo := InitializeInputDisk(InputPath); //Initialize disk info

    while (TotalRead < DiskInfo.DiskSize) do begin //While have bytes to read, then read them
      Buffer := ReadDiskBytes(hOut, TotalRead, DiskInfo.SectorSize, 1); //Read sector from output of specified size into buffer

      //If buffer is damaged in output file try to recover it
      if (IsDamagedBuffer(Buffer)) then begin
        Buffer := ReadDiskBytes(DiskInfo.DiskHandle, TotalRead, DiskInfo.SectorSize, MaxRetry); //Read sector of specified size into buffer
        if (not IsDiskInitialized(DiskInfo.DiskHandle)) then Break; //Reinitialize disk (maybe disk was discconected)
        if (IsDamagedBuffer(Buffer)) then Result := False; //If failed to read sector, try again in next iteration
        TotalFixed := TotalFixed + Q(IsDamagedBuffer(Buffer), 0, 1); //If sector fixed increase fixed sector statistic
        TotalErrors := TotalErrors + Q(IsDamagedBuffer(Buffer), 1, 0); //If sector not fixed increase error sector statistic
        SetFilePointer(hOut, TotalRead, FILE_BEGIN); //Set pointer to write at damaged sector location in file
        WriteFile(hOut, Buffer[0], Length(Buffer), nw, nil); //Write current buffer to output file
        WriteLn(Q(IsDamagedBuffer(Buffer), 'Failled', 'Succeeded') + ' repairing data at ', TotalRead);
      end;

      TotalRead := TotalRead + Length(Buffer); //Update total read bytes

      //Write total bytes progress to console with some interval
      if (MillisecondsBetween(SavedTime, Now) < UPDATE_INTERVAL) then Continue;
      SavedTime := Now; //Update time, so that we don't spam console
      WriteLn(Format('Reading and repairing: %s/%s | (F: %d, E: %d)', [FormatSize(TotalRead, 4), FormatSize(DiskInfo.DiskSize, 4), TotalFixed, TotalErrors]));
    end;

    if (TotalRead >= DiskInfo.DiskSize) then Break;
  end;

  CloseHandle(hOut); //Close output file
  CloseHandle(DiskInfo.DiskHandle); //Close input file
  WriteLn(Format('Repaired: %s | (F: %d, E: %d)', [FormatSize(TotalRead, 4), TotalFixed, TotalErrors]));
  SetConsoleTitle(PChar(Format('Repaired: %s | (F: %d, E: %d)', [FormatSize(TotalRead, 4), TotalFixed, TotalErrors])));
end;


function SetMediaEjected(InputDrive: WideString; Ejected: Boolean): boolean;
const
  FILE_DEVICE_FILE_SYSTEM = 9;
  FILE_ANY_ACCESS = 0;
  FILE_READ_ACCESS = 1;
  METHOD_BUFFERED = 0;
  IOCTL_STORAGE_BASE = $2D;
  FSCTL_LOCK_VOLUME = (FILE_DEVICE_FILE_SYSTEM shl 16) or (FILE_ANY_ACCESS shl 14) or (6 shl 2) or METHOD_BUFFERED;
  FSCTL_DISMOUNT_VOLUME = (FILE_DEVICE_FILE_SYSTEM shl 16) or (FILE_ANY_ACCESS shl 14) or (8 shl 2) or METHOD_BUFFERED;
  IOCTL_STORAGE_EJECT_MEDIA = (IOCTL_STORAGE_BASE shl 16) or (FILE_READ_ACCESS shl 14) or ($0202 shl 2) or METHOD_BUFFERED;
  IOCTL_STORAGE_LOAD_MEDIA = (IOCTL_STORAGE_BASE shl 16) or (FILE_READ_ACCESS shl 14) or ($0203 shl 2) or METHOD_BUFFERED;
var
  DiskHandle: THandle;
  BytesReturned: Cardinal;
begin
  Result := False;
  DiskHandle := CreateFileW(PWideChar('\\.\' + InputDrive), GENERIC_READ, FILE_SHARE_WRITE + FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if (DiskHandle = INVALID_HANDLE_VALUE) then Exit;

  if Ejected then begin
      Result := DeviceIOControl(DiskHandle, FSCTL_LOCK_VOLUME, nil, 0, nil, 0, BytesReturned, nil);
      Result := Result and DeviceIOControl(DiskHandle, FSCTL_DISMOUNT_VOLUME, nil, 0, nil, 0, BytesReturned, nil);
      Result := Result and DeviceIOControl(DiskHandle, IOCTL_STORAGE_EJECT_MEDIA, nil, 0, nil, 0, BytesReturned, nil);
  end else begin
      Result := DeviceIOControl(DiskHandle, IOCTL_STORAGE_LOAD_MEDIA, nil, 0, nil, 0, BytesReturned, nil);
  end;

  if (not Result) then WriteLn('[ERROR]: Failed to eject drive: ' + InputDrive);
  CloseHandle(DiskHandle);
end;


begin
  if (not IsAdmin) then begin
    WriteLn('You must run this as an administrator.');
    Exit;
  end;

  if (ParamCount < 6) then begin
    WriteLn('Usage: ' + WideExtractFileName(WideParamStr(0)) + ' <input_path> <output_file> <sector_count_copy> <max_retry_copy> <max_retry_repair> <eject_drive>');
    WriteLn('Usage: ' + WideExtractFileName(WideParamStr(0)) + ' E: C:\Drive.img 1 5 50 1');
    WriteLn('Usage: ' + WideExtractFileName(WideParamStr(0)) + ' PhysicalDrive1 C:\Drive.img 128 3 30 0');
    Exit;
  end;

  CopyDisk(WideParamStr(1), WideParamStr(2), StrToIntDef(ParamStr(3), 1), StrToIntDef(ParamStr(4), 5));
  while not RepairDisk(WideParamStr(1), WideParamStr(2), StrToIntDef(ParamStr(5), 50)) do;
  if (StrToIntDef(ParamStr(6), 0) = 1) then SetMediaEjected(WideParamStr(1), True);
end.
