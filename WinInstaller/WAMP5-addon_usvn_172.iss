[Setup]
AppName=USVN
AppVerName=Userfriendly SVN
OutputBaseFilename=USVN_06_add-on_173
AppPublisher=Userfriendly SVN
AppPublisherURL=http://www.usvn.info
AppSupportURL=http://www.usvn.info
AppUpdatesURL=http://www.usvn.info
DefaultDirName=c:\wamp
;DisableDirPage=yes
DefaultGroupName=WampServer
LicenseFile=.\Files\Licence_CeCILL_V2-en.txt
SourceDir=.\

WizardImageFile=.\Files\logo.bmp
;SetupIconFile=.\Files\USVN.ico
;InfoBeforeFile=D:\wampserver\install_files\php\license.txt
;InfoAfterFile=D:\wampserver\install_files\mysql\readme.txt
AlwaysRestart=yes

[Tasks]
; NOTE: The following entry contains English phrases ("Create a desktop icon" and "Additional icons"). You are free to translate them into another language if required.
;Name: "autostart"; Description: "Automatically launch WAMP5 on startup. If you check this option, Services will be installed as automatic. Otherwise, services will be installed as manual and will start and stop with the service manager."; GroupDescription: "Auto Start:" ;Flags: unchecked;

[Files]
Source: ".\Files\svn-1.4.5-setup.exe"; DestDir: "{app}\USVN\"; Flags:  ignoreversion recursesubdirs deleteafterinstall;AfterInstall: InstallSVN('{app}\USVN\svn-1.4.5-setup.exe')
Source: ".\Files\mod_authz_svn.so"; DestDir: "{app}\Apache2\modules\"; Flags:  ignoreversion recursesubdirs;
Source: ".\Files\mod_dav_svn.so"; DestDir: "{app}\Apache2\modules\"; Flags:  ignoreversion recursesubdirs; AfterInstall: ConfigApache('{app}')
Source: ".\Files\libdb44.dll"; DestDir: "{app}\Apache2\bin\"; Flags:  ignoreversion recursesubdirs;
Source: ".\Files\intl3_svn.dll"; DestDir: "{app}\Apache2\bin\"; Flags:  ignoreversion recursesubdirs;

Source: ".\Files\usvn.conf"; DestDir: "{app}\Apache2\conf\alias\"; Flags:  ignoreversion recursesubdirs; AfterInstall: ConfigAlias('{app}')
Source: ".\Files\config.ini"; DestDir: "{app}\USVN\"; Flags:  ignoreversion recursesubdirs; AfterInstall: ConfigConfig('{app}')
Source: ".\Files\USVN\*.*"; DestDir: "{app}\USVN\"; Flags:  ignoreversion recursesubdirs ; AfterInstall: ConfigAlias('{app}')
Source: ".\Files\.htaccess"; DestDir: "{app}\USVN\"; Flags:  ignoreversion recursesubdirs;
Source: ".\Files\usvn.db"; DestDir: "{app}\USVN\files\"; Flags:  ignoreversion recursesubdirs; AfterInstall: ConfigDB('{app}')
Source: ".\Files\htpasswd"; DestDir: "{app}\USVN\files\"; Flags:  ignoreversion recursesubdirs;
Source: ".\Files\info.txt"; DestDir: "{app}\USVN\"; Flags:  ignoreversion recursesubdirs deleteafterinstall;AfterInstall: InfoBox('{app}\USVN\')
[Code]
var
  ResultCode: Integer;
  batfile: String;
  
procedure InstallSVN(FileName: String);
begin
  if Exec(ExpandConstant(FileName), '', '', SW_SHOW,
     ewWaitUntilTerminated, ResultCode) then
  begin
    // handle success if necessary; ResultCode contains the exit code
  end
  else begin
    // handle failure if necessary; ResultCode contains the error code
  end;

end;

procedure ConfigApache(FileName: String);

begin

  FileName:= ExpandConstant(FileName);

  FileCopy(FileName + '\Apache2\bin\libapr-1.dll', FileName + '\Apache2\bin\libapr.dll', false);
  FileCopy(FileName + '\Apache2\bin\libaprutil-1.dll', FileName + '\Apache2\bin\libaprutil.dll', false);
  FileCopy(FileName + '\Apache2\bin\libapriconv-1.dll', FileName + '\Apache2\bin\libapriconv.dll', false);

end;

procedure ConfigAlias(FileName: String);
var SrcContent4: String;
var FileName2: String;

begin
  FileName:= ExpandConstant(FileName);
  FileName2:= FileName;
  StringChange (FileName2, '\','/');
  LoadStringFromFile (FileName + '\Apache2\conf\alias\usvn.conf', SrcContent4);
  StringChangeEx(SrcContent4, 'Alias /usvn "c:/usvn/"', 'Alias /usvn' + ' "' + FileName2 + '/USVN/"', True);
  StringChangeEx(SrcContent4, '<Directory "c:/usvn/">', '<Directory "' + FileName2 + '/USVN/">', True);
  
  StringChangeEx(SrcContent4, '	SVNParentPath c:/usvn/', '	SVNParentPath "' + FileName2 + '/USVN/files/svn"', True);
  StringChangeEx(SrcContent4, '	AuthUserFile c:/usvn/', '	AuthUserFile "' + FileName2 + '/USVN/files/htpasswd"', True);
  StringChangeEx(SrcContent4, '	AuthzSVNAccessFile c:/usvn/', '	AuthzSVNAccessFile "' + FileName2 + '/USVN/files/authz"', True);
  
  DeleteFile (FileName + '\Apache2\conf\alias\usvn.conf');
  SaveStringToFile(FileName + '\Apache2\conf\alias\usvn.conf',SrcContent4, false);

  LoadStringFromFile (FileName + '\Apache2\conf\httpd.conf', SrcContent4);
  if Pos('Include "' + FileName2 + '/apache2/conf/alias/usvn.conf"', SrcContent4) = 0 then
  begin
    SaveStringToFile(FileName + '\Apache2\conf\httpd.conf', #13#10 + 'Include "' + FileName2 + '/apache2/conf/alias/usvn.conf"' + #13#10, true);
  end;
  
end;

procedure ConfigConfig(FileName: String);
var SrcContent4: String;
var FileName2: String;

begin
  FileName:= ExpandConstant(FileName);
  FileName2:= FileName;
  StringChange (FileName2, '\','/');
  LoadStringFromFile (FileName + '\USVN\config.ini', SrcContent4);
  StringChangeEx(SrcContent4, 'subversion.path = ""', 'subversion.path = "' + FileName2 + '/USVN/files/"', True);
  StringChangeEx(SrcContent4, 'database.options.dbname = ""', 'database.options.dbname = "' + FileName2 + '/USVN/files/usvn.db"', True);
  DeleteFile (FileName + '\USVN\config.ini');
  SaveStringToFile(FileName + '\USVN\config.ini', SrcContent4, false);
end;


procedure ConfigDB(FileName: String);
var SrcContent4: String;
var FileName2: String;

begin
  FileName:= ExpandConstant(FileName);
  FileName2:= FileName;
  StringChange (FileName2, '\','/');
  CreateDir(FileName2 + '/USVN/files/svn/');
end;

procedure InfoBox(FileName: String);
var FileName2: String;
var ErrorCode: Integer;

begin

  FileName:= ExpandConstant(FileName);
  FileName2:= FileName;
  StringChange (FileName2, '\','/');
  ShellExec('open', FileName2 + '/info.txt', '', '', SW_SHOW, ewNoWait, ErrorCode)
end;

[Run]
;Filename: "{app}\USVN\svn-1.4.3-setup.exe"; Description: "Launch SVN installation now"; Flags:shellexec postinstall skipifsilent runhidden
