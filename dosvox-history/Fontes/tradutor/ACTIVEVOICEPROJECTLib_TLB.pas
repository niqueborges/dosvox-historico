unit ACTIVEVOICEPROJECTLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.130  $
// File generated on 29/03/2016 19:41:59 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\WINDOWS\speech\XVoice.dll (1)
// LIBID: {EEE78583-FE22-11D0-8BEF-0060081841DE}
// LCID: 0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINDOWS\SysWOW64\stdvcl40.dll)
// Errors:
//   Hint: Parameter 'object' of IDirectSS.InitAudioDestObject changed to 'object_'
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}

interface

uses ActiveX, Classes, Graphics, OleCtrls, OleServer, StdVCL, Variants, 
Windows;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  ACTIVEVOICEPROJECTLibMajorVersion = 1;
  ACTIVEVOICEPROJECTLibMinorVersion = 0;

  LIBID_ACTIVEVOICEPROJECTLib: TGUID = '{EEE78583-FE22-11D0-8BEF-0060081841DE}';

  DIID__DirectSSEvents: TGUID = '{EEE78597-FE22-11D0-8BEF-0060081841DE}';
  IID_IDirectSS: TGUID = '{EEE78590-FE22-11D0-8BEF-0060081841DE}';
  CLASS_DirectSS: TGUID = '{EEE78591-FE22-11D0-8BEF-0060081841DE}';
  CLASS_VoiceProp: TGUID = '{EEE78592-FE22-11D0-8BEF-0060081841DE}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DirectSSEvents = dispinterface;
  IDirectSS = interface;
  IDirectSSDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  DirectSS = IDirectSS;
  VoiceProp = IUnknown;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PInteger1 = ^Integer; {*}
  PWideString1 = ^WideString; {*}


// *********************************************************************//
// DispIntf:  _DirectSSEvents
// Flags:     (4096) Dispatchable
// GUID:      {EEE78597-FE22-11D0-8BEF-0060081841DE}
// *********************************************************************//
  _DirectSSEvents = dispinterface
    ['{EEE78597-FE22-11D0-8BEF-0060081841DE}']
    procedure ClickIn(x: Integer; y: Integer); dispid 1;
    procedure ClickOut(x: Integer; y: Integer); dispid 2;
    procedure AudioStart(hi: Integer; lo: Integer); dispid 3;
    procedure AudioStop(hi: Integer; lo: Integer); dispid 4;
    procedure AttribChanged(which_attribute: Integer); dispid 5;
    procedure Visual(timehi: Integer; timelo: Integer; Phoneme: Smallint; EnginePhoneme: Smallint; 
                     hints: Integer; MouthHeight: Smallint; bMouthWidth: Smallint; 
                     bMouthUpturn: Smallint; bJawOpen: Smallint; TeethUpperVisible: Smallint; 
                     TeethLowerVisible: Smallint; TonguePosn: Smallint; LipTension: Smallint); dispid 6;
    procedure WordPosition(hi: Integer; lo: Integer; byteoffset: Integer); dispid 7;
    procedure BookMark(hi: Integer; lo: Integer; MarkNum: Integer); dispid 8;
    procedure TextDataStarted(hi: Integer; lo: Integer); dispid 9;
    procedure TextDataDone(hi: Integer; lo: Integer; Flags: Integer); dispid 10;
    procedure ActiveVoiceStartup(init: Integer; init2: Integer); dispid 11;
    procedure Debugging; dispid 12;
    procedure Error(warning: LongWord; const Details: WideString; const Message: WideString); dispid 13;
    procedure warning(warning: LongWord; const Details: WideString; const Message: WideString); dispid 14;
    procedure VisualFuture(milliseconds: Integer; timehi: Integer; timelo: Integer; 
                           Phoneme: Smallint; EnginePhoneme: Smallint; hints: Integer; 
                           MouthHeight: Smallint; bMouthWidth: Smallint; bMouthUpturn: Smallint; 
                           bJawOpen: Smallint; TeethUpperVisible: Smallint; 
                           TeethLowerVisible: Smallint; TonguePosn: Smallint; LipTension: Smallint); dispid 15;
  end;

// *********************************************************************//
// Interface: IDirectSS
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EEE78590-FE22-11D0-8BEF-0060081841DE}
// *********************************************************************//
  IDirectSS = interface(IDispatch)
    ['{EEE78590-FE22-11D0-8BEF-0060081841DE}']
    function  Get_debug: Smallint; safecall;
    procedure Set_debug(pVal: Smallint); safecall;
    function  Get_Initialized: Smallint; safecall;
    procedure Set_Initialized(pVal: Smallint); safecall;
    procedure Speak(const text: WideString); safecall;
    function  Get_Pitch: Integer; safecall;
    procedure Set_Pitch(pVal: Integer); safecall;
    function  Get_MaxPitch: Integer; safecall;
    procedure Set_MaxPitch(pVal: Integer); safecall;
    function  Get_MinPitch: Integer; safecall;
    procedure Set_MinPitch(pVal: Integer); safecall;
    function  Get_Speed: Integer; safecall;
    procedure Set_Speed(pVal: Integer); safecall;
    function  Get_MaxSpeed: Integer; safecall;
    procedure Set_MaxSpeed(pVal: Integer); safecall;
    function  Get_MinSpeed: Integer; safecall;
    procedure Set_MinSpeed(pVal: Integer); safecall;
    function  Get_VolumeRight: Integer; safecall;
    procedure Set_VolumeRight(pVal: Integer); safecall;
    function  Get_MinVolumeRight: Integer; safecall;
    procedure Set_MinVolumeRight(pVal: Integer); safecall;
    function  Get_MaxVolumeRight: Integer; safecall;
    procedure Set_MaxVolumeRight(pVal: Integer); safecall;
    procedure Select(index: SYSINT); safecall;
    function  EngineID(index: SYSINT): WideString; safecall;
    function  Get_CountEngines: Integer; safecall;
    function  ModeName(index: SYSINT): WideString; safecall;
    function  MfgName(index: SYSINT): WideString; safecall;
    function  ProductName(index: SYSINT): WideString; safecall;
    function  ModeID(index: SYSINT): WideString; safecall;
    function  Speaker(index: SYSINT): WideString; safecall;
    function  Style(index: SYSINT): WideString; safecall;
    function  Gender(index: SYSINT): Integer; safecall;
    function  Age(index: SYSINT): Integer; safecall;
    function  Features(index: SYSINT): Integer; safecall;
    function  Interfaces(index: SYSINT): Integer; safecall;
    function  EngineFeatures(index: SYSINT): Integer; safecall;
    function  LanguageID(index: SYSINT): Integer; safecall;
    function  Dialect(index: SYSINT): WideString; safecall;
    function  Get_RealTime: Integer; safecall;
    procedure Set_RealTime(pVal: Integer); safecall;
    function  Get_MaxRealTime: Integer; safecall;
    function  Get_MinRealTime: Integer; safecall;
    procedure Set_MinRealTime(pVal: Integer); safecall;
    procedure AudioPause; safecall;
    procedure AudioReset; safecall;
    procedure AudioResume; safecall;
    procedure Inject(const value: WideString); safecall;
    function  Get_Tagged: Integer; safecall;
    procedure Set_Tagged(pVal: Integer); safecall;
    function  Phonemes(charset: Integer; Flags: Integer; const input: WideString): WideString; safecall;
    procedure PosnGet(var hi: Integer; var lo: Integer); safecall;
    procedure TextData(characterset: Integer; Flags: Integer; const text: WideString); safecall;
    procedure InitAudioDestMM(deviceid: Integer); safecall;
    procedure AboutDlg(hWnd: Integer; const title: WideString); safecall;
    procedure GeneralDlg(hWnd: Integer; const title: WideString); safecall;
    procedure LexiconDlg(hWnd: Integer; const title: WideString); safecall;
    procedure TranslateDlg(hWnd: Integer; const title: WideString); safecall;
    function  FindEngine(const EngineID: WideString; const MfgName: WideString; 
                         const ProductName: WideString; const ModeID: WideString; 
                         const ModeName: WideString; LanguageID: Integer; 
                         const Dialect: WideString; const Speaker: WideString; 
                         const Style: WideString; Gender: Integer; Age: Integer; Features: Integer; 
                         Interfaces: Integer; EngineFeatures: Integer; RankEngineID: Integer; 
                         RankMfgName: Integer; RankProductName: Integer; RankModeID: Integer; 
                         RankModeName: Integer; RankLanguage: Integer; RankDialect: Integer; 
                         RankSpeaker: Integer; RankStyle: Integer; RankGender: Integer; 
                         RankAge: Integer; RankFeatures: Integer; RankInterfaces: Integer; 
                         RankEngineFeatures: Integer): Integer; safecall;
    function  Get_MouthHeight: Smallint; safecall;
    procedure Set_MouthHeight(pVal: Smallint); safecall;
    function  Get_MouthWidth: Smallint; safecall;
    procedure Set_MouthWidth(pVal: Smallint); safecall;
    function  Get_MouthUpturn: Smallint; safecall;
    procedure Set_MouthUpturn(pVal: Smallint); safecall;
    function  Get_JawOpen: Smallint; safecall;
    procedure Set_JawOpen(pVal: Smallint); safecall;
    function  Get_TeethUpperVisible: Smallint; safecall;
    procedure Set_TeethUpperVisible(pVal: Smallint); safecall;
    function  Get_TeethLowerVisible: Smallint; safecall;
    procedure Set_TeethLowerVisible(pVal: Smallint); safecall;
    function  Get_TonguePosn: Smallint; safecall;
    procedure Set_TonguePosn(pVal: Smallint); safecall;
    function  Get_LipTension: Smallint; safecall;
    procedure Set_LipTension(pVal: Smallint); safecall;
    function  Get_CallBacksEnabled: Smallint; safecall;
    procedure Set_CallBacksEnabled(pVal: Smallint); safecall;
    function  Get_MouthEnabled: Smallint; safecall;
    procedure Set_MouthEnabled(pVal: Smallint); safecall;
    function  Get_LastError: Integer; safecall;
    procedure Set_LastError(pVal: Integer); safecall;
    function  Get_SuppressExceptions: Smallint; safecall;
    procedure Set_SuppressExceptions(pVal: Smallint); safecall;
    function  Get_Speaking: Smallint; safecall;
    procedure Set_Speaking(pVal: Smallint); safecall;
    function  Get_LastWordPosition: Integer; safecall;
    procedure Set_LastWordPosition(pVal: Integer); safecall;
    function  Get_LipType: Smallint; safecall;
    procedure Set_LipType(pVal: Smallint); safecall;
    procedure GetPronunciation(charset: Integer; const text: WideString; Sense: Integer; 
                               var Pronounce: WideString; var PartOfSpeech: Integer; 
                               var EngineInfo: WideString); safecall;
    procedure InitAudioDestDirect(direct: Integer); safecall;
    function  Get_Sayit: WideString; safecall;
    procedure Set_Sayit(const newVal: WideString); safecall;
    procedure InitAudioDestObject(object_: Integer); safecall;
    function  Get_FileName: WideString; safecall;
    procedure Set_FileName(const pVal: WideString); safecall;
    function  Get_CurrentMode: Integer; safecall;
    procedure Set_CurrentMode(pVal: Integer); safecall;
    function  Get_hWnd: Integer; safecall;
    function  Find(const RankList: WideString): Integer; safecall;
    function  Get_VolumeLeft: Integer; safecall;
    procedure Set_VolumeLeft(pVal: Integer); safecall;
    function  Get_MinVolumeLeft: Integer; safecall;
    procedure Set_MinVolumeLeft(pVal: Integer); safecall;
    function  Get_MaxVolumeLeft: Integer; safecall;
    procedure Set_MaxVolumeLeft(pVal: Integer); safecall;
    function  Get_AudioDest: Integer; safecall;
    function  Get_Attributes(Attrib: Integer): Integer; safecall;
    procedure Set_Attributes(Attrib: Integer; pVal: Integer); safecall;
    function  Get_AttributeString(Attrib: Integer): WideString; safecall;
    procedure Set_AttributeString(Attrib: Integer; const pVal: WideString); safecall;
    function  Get_AttributeMemory(Attrib: Integer; var size: Integer): Integer; safecall;
    procedure Set_AttributeMemory(Attrib: Integer; var size: Integer; pVal: Integer); safecall;
    procedure LexAddTo(lex: LongWord; charset: Integer; const text: WideString; 
                       const Pronounce: WideString; PartOfSpeech: Integer; EngineInfo: Integer; 
                       engineinfosize: Integer); safecall;
    procedure LexGetFrom(lex: Integer; charset: Integer; const text: WideString; Sense: Integer; 
                         var Pronounce: WideString; var PartOfSpeech: Integer; 
                         var EngineInfo: Integer; var sizeofengineinfo: Integer); safecall;
    procedure LexRemoveFrom(lex: Integer; const text: WideString; Sense: Integer); safecall;
    procedure QueryLexicons(f: Integer; var pdw: Integer); safecall;
    procedure ChangeSpelling(lex: Integer; const stringa: WideString; const stringb: WideString); safecall;
    property debug: Smallint read Get_debug write Set_debug;
    property Initialized: Smallint read Get_Initialized write Set_Initialized;
    property Pitch: Integer read Get_Pitch write Set_Pitch;
    property MaxPitch: Integer read Get_MaxPitch write Set_MaxPitch;
    property MinPitch: Integer read Get_MinPitch write Set_MinPitch;
    property Speed: Integer read Get_Speed write Set_Speed;
    property MaxSpeed: Integer read Get_MaxSpeed write Set_MaxSpeed;
    property MinSpeed: Integer read Get_MinSpeed write Set_MinSpeed;
    property VolumeRight: Integer read Get_VolumeRight write Set_VolumeRight;
    property MinVolumeRight: Integer read Get_MinVolumeRight write Set_MinVolumeRight;
    property MaxVolumeRight: Integer read Get_MaxVolumeRight write Set_MaxVolumeRight;
    property CountEngines: Integer read Get_CountEngines;
    property RealTime: Integer read Get_RealTime write Set_RealTime;
    property MaxRealTime: Integer read Get_MaxRealTime;
    property MinRealTime: Integer read Get_MinRealTime write Set_MinRealTime;
    property Tagged: Integer read Get_Tagged write Set_Tagged;
    property MouthHeight: Smallint read Get_MouthHeight write Set_MouthHeight;
    property MouthWidth: Smallint read Get_MouthWidth write Set_MouthWidth;
    property MouthUpturn: Smallint read Get_MouthUpturn write Set_MouthUpturn;
    property JawOpen: Smallint read Get_JawOpen write Set_JawOpen;
    property TeethUpperVisible: Smallint read Get_TeethUpperVisible write Set_TeethUpperVisible;
    property TeethLowerVisible: Smallint read Get_TeethLowerVisible write Set_TeethLowerVisible;
    property TonguePosn: Smallint read Get_TonguePosn write Set_TonguePosn;
    property LipTension: Smallint read Get_LipTension write Set_LipTension;
    property CallBacksEnabled: Smallint read Get_CallBacksEnabled write Set_CallBacksEnabled;
    property MouthEnabled: Smallint read Get_MouthEnabled write Set_MouthEnabled;
    property LastError: Integer read Get_LastError write Set_LastError;
    property SuppressExceptions: Smallint read Get_SuppressExceptions write Set_SuppressExceptions;
    property Speaking: Smallint read Get_Speaking write Set_Speaking;
    property LastWordPosition: Integer read Get_LastWordPosition write Set_LastWordPosition;
    property LipType: Smallint read Get_LipType write Set_LipType;
    property Sayit: WideString read Get_Sayit write Set_Sayit;
    property FileName: WideString read Get_FileName write Set_FileName;
    property CurrentMode: Integer read Get_CurrentMode write Set_CurrentMode;
    property hWnd: Integer read Get_hWnd;
    property VolumeLeft: Integer read Get_VolumeLeft write Set_VolumeLeft;
    property MinVolumeLeft: Integer read Get_MinVolumeLeft write Set_MinVolumeLeft;
    property MaxVolumeLeft: Integer read Get_MaxVolumeLeft write Set_MaxVolumeLeft;
    property AudioDest: Integer read Get_AudioDest;
    property Attributes[Attrib: Integer]: Integer read Get_Attributes write Set_Attributes;
    property AttributeString[Attrib: Integer]: WideString read Get_AttributeString write Set_AttributeString;
    property AttributeMemory[Attrib: Integer; var size: Integer]: Integer read Get_AttributeMemory write Set_AttributeMemory;
  end;

// *********************************************************************//
// DispIntf:  IDirectSSDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EEE78590-FE22-11D0-8BEF-0060081841DE}
// *********************************************************************//
  IDirectSSDisp = dispinterface
    ['{EEE78590-FE22-11D0-8BEF-0060081841DE}']
    property debug: Smallint dispid 1;
    property Initialized: Smallint dispid 2;
    procedure Speak(const text: WideString); dispid 6;
    property Pitch: Integer dispid 7;
    property MaxPitch: Integer dispid 8;
    property MinPitch: Integer dispid 9;
    property Speed: Integer dispid 10;
    property MaxSpeed: Integer dispid 11;
    property MinSpeed: Integer dispid 12;
    property VolumeRight: Integer dispid 13;
    property MinVolumeRight: Integer dispid 14;
    property MaxVolumeRight: Integer dispid 15;
    procedure Select(index: SYSINT); dispid 16;
    function  EngineID(index: SYSINT): WideString; dispid 17;
    property CountEngines: Integer readonly dispid 18;
    function  ModeName(index: SYSINT): WideString; dispid 19;
    function  MfgName(index: SYSINT): WideString; dispid 20;
    function  ProductName(index: SYSINT): WideString; dispid 21;
    function  ModeID(index: SYSINT): WideString; dispid 22;
    function  Speaker(index: SYSINT): WideString; dispid 23;
    function  Style(index: SYSINT): WideString; dispid 24;
    function  Gender(index: SYSINT): Integer; dispid 25;
    function  Age(index: SYSINT): Integer; dispid 26;
    function  Features(index: SYSINT): Integer; dispid 27;
    function  Interfaces(index: SYSINT): Integer; dispid 28;
    function  EngineFeatures(index: SYSINT): Integer; dispid 29;
    function  LanguageID(index: SYSINT): Integer; dispid 30;
    function  Dialect(index: SYSINT): WideString; dispid 31;
    property RealTime: Integer dispid 32;
    property MaxRealTime: Integer readonly dispid 33;
    property MinRealTime: Integer dispid 34;
    procedure AudioPause; dispid 35;
    procedure AudioReset; dispid 36;
    procedure AudioResume; dispid 37;
    procedure Inject(const value: WideString); dispid 38;
    property Tagged: Integer dispid 39;
    function  Phonemes(charset: Integer; Flags: Integer; const input: WideString): WideString; dispid 40;
    procedure PosnGet(var hi: Integer; var lo: Integer); dispid 41;
    procedure TextData(characterset: Integer; Flags: Integer; const text: WideString); dispid 42;
    procedure InitAudioDestMM(deviceid: Integer); dispid 43;
    procedure AboutDlg(hWnd: Integer; const title: WideString); dispid 44;
    procedure GeneralDlg(hWnd: Integer; const title: WideString); dispid 45;
    procedure LexiconDlg(hWnd: Integer; const title: WideString); dispid 46;
    procedure TranslateDlg(hWnd: Integer; const title: WideString); dispid 47;
    function  FindEngine(const EngineID: WideString; const MfgName: WideString; 
                         const ProductName: WideString; const ModeID: WideString; 
                         const ModeName: WideString; LanguageID: Integer; 
                         const Dialect: WideString; const Speaker: WideString; 
                         const Style: WideString; Gender: Integer; Age: Integer; Features: Integer; 
                         Interfaces: Integer; EngineFeatures: Integer; RankEngineID: Integer; 
                         RankMfgName: Integer; RankProductName: Integer; RankModeID: Integer; 
                         RankModeName: Integer; RankLanguage: Integer; RankDialect: Integer; 
                         RankSpeaker: Integer; RankStyle: Integer; RankGender: Integer; 
                         RankAge: Integer; RankFeatures: Integer; RankInterfaces: Integer; 
                         RankEngineFeatures: Integer): Integer; dispid 48;
    property MouthHeight: Smallint dispid 49;
    property MouthWidth: Smallint dispid 50;
    property MouthUpturn: Smallint dispid 51;
    property JawOpen: Smallint dispid 52;
    property TeethUpperVisible: Smallint dispid 53;
    property TeethLowerVisible: Smallint dispid 54;
    property TonguePosn: Smallint dispid 55;
    property LipTension: Smallint dispid 56;
    property CallBacksEnabled: Smallint dispid 57;
    property MouthEnabled: Smallint dispid 58;
    property LastError: Integer dispid 59;
    property SuppressExceptions: Smallint dispid 60;
    property Speaking: Smallint dispid 61;
    property LastWordPosition: Integer dispid 62;
    property LipType: Smallint dispid 63;
    procedure GetPronunciation(charset: Integer; const text: WideString; Sense: Integer; 
                               var Pronounce: WideString; var PartOfSpeech: Integer; 
                               var EngineInfo: WideString); dispid 64;
    procedure InitAudioDestDirect(direct: Integer); dispid 65;
    property Sayit: WideString dispid 66;
    procedure InitAudioDestObject(object_: Integer); dispid 67;
    property FileName: WideString dispid 68;
    property CurrentMode: Integer dispid 69;
    property hWnd: Integer readonly dispid 70;
    function  Find(const RankList: WideString): Integer; dispid 71;
    property VolumeLeft: Integer dispid 72;
    property MinVolumeLeft: Integer dispid 73;
    property MaxVolumeLeft: Integer dispid 74;
    property AudioDest: Integer readonly dispid 75;
    property Attributes[Attrib: Integer]: Integer dispid 76;
    property AttributeString[Attrib: Integer]: WideString dispid 77;
    property AttributeMemory[Attrib: Integer; var size: Integer]: Integer dispid 78;
    procedure LexAddTo(lex: LongWord; charset: Integer; const text: WideString; 
                       const Pronounce: WideString; PartOfSpeech: Integer; EngineInfo: Integer; 
                       engineinfosize: Integer); dispid 79;
    procedure LexGetFrom(lex: Integer; charset: Integer; const text: WideString; Sense: Integer; 
                         var Pronounce: WideString; var PartOfSpeech: Integer; 
                         var EngineInfo: Integer; var sizeofengineinfo: Integer); dispid 80;
    procedure LexRemoveFrom(lex: Integer; const text: WideString; Sense: Integer); dispid 81;
    procedure QueryLexicons(f: Integer; var pdw: Integer); dispid 82;
    procedure ChangeSpelling(lex: Integer; const stringa: WideString; const stringb: WideString); dispid 83;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TDirectSS
// Help String      : Microsoft Direct Speech Synthesis Class
// Default Interface: IDirectSS
// Def. Intf. DISP? : No
// Event   Interface: _DirectSSEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
  TDirectSSClickIn = procedure(Sender: TObject; x: Integer; y: Integer) of object;
  TDirectSSClickOut = procedure(Sender: TObject; x: Integer; y: Integer) of object;
  TDirectSSAudioStart = procedure(Sender: TObject; hi: Integer; lo: Integer) of object;
  TDirectSSAudioStop = procedure(Sender: TObject; hi: Integer; lo: Integer) of object;
  TDirectSSAttribChanged = procedure(Sender: TObject; which_attribute: Integer) of object;
  TDirectSSVisual = procedure(Sender: TObject; timehi: Integer; timelo: Integer; Phoneme: Smallint; 
                                               EnginePhoneme: Smallint; hints: Integer; 
                                               MouthHeight: Smallint; bMouthWidth: Smallint; 
                                               bMouthUpturn: Smallint; bJawOpen: Smallint; 
                                               TeethUpperVisible: Smallint; 
                                               TeethLowerVisible: Smallint; TonguePosn: Smallint; 
                                               LipTension: Smallint) of object;
  TDirectSSWordPosition = procedure(Sender: TObject; hi: Integer; lo: Integer; byteoffset: Integer) of object;
  TDirectSSBookMark = procedure(Sender: TObject; hi: Integer; lo: Integer; MarkNum: Integer) of object;
  TDirectSSTextDataStarted = procedure(Sender: TObject; hi: Integer; lo: Integer) of object;
  TDirectSSTextDataDone = procedure(Sender: TObject; hi: Integer; lo: Integer; Flags: Integer) of object;
  TDirectSSActiveVoiceStartup = procedure(Sender: TObject; init: Integer; init2: Integer) of object;
  TDirectSSError = procedure(Sender: TObject; warning: LongWord; const Details: WideString; 
                                              const Message: WideString) of object;
  TDirectSSwarning = procedure(Sender: TObject; warning: LongWord; const Details: WideString; 
                                                const Message: WideString) of object;
  TDirectSSVisualFuture = procedure(Sender: TObject; milliseconds: Integer; timehi: Integer; 
                                                     timelo: Integer; Phoneme: Smallint; 
                                                     EnginePhoneme: Smallint; hints: Integer; 
                                                     MouthHeight: Smallint; bMouthWidth: Smallint; 
                                                     bMouthUpturn: Smallint; bJawOpen: Smallint; 
                                                     TeethUpperVisible: Smallint; 
                                                     TeethLowerVisible: Smallint; 
                                                     TonguePosn: Smallint; LipTension: Smallint) of object;

  TDirectSS = class(TOleControl)
  private
    FOnClickIn: TDirectSSClickIn;
    FOnClickOut: TDirectSSClickOut;
    FOnAudioStart: TDirectSSAudioStart;
    FOnAudioStop: TDirectSSAudioStop;
    FOnAttribChanged: TDirectSSAttribChanged;
    FOnVisual: TDirectSSVisual;
    FOnWordPosition: TDirectSSWordPosition;
    FOnBookMark: TDirectSSBookMark;
    FOnTextDataStarted: TDirectSSTextDataStarted;
    FOnTextDataDone: TDirectSSTextDataDone;
    FOnActiveVoiceStartup: TDirectSSActiveVoiceStartup;
    FOnDebugging: TNotifyEvent;
    FOnError: TDirectSSError;
    FOnwarning: TDirectSSwarning;
    FOnVisualFuture: TDirectSSVisualFuture;
    FIntf: IDirectSS;
    function  GetControlInterface: IDirectSS;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function  Get_Attributes(Attrib: Integer): Integer;
    procedure Set_Attributes(Attrib: Integer; pVal: Integer);
    function  Get_AttributeString(Attrib: Integer): WideString;
    procedure Set_AttributeString(Attrib: Integer; const pVal: WideString);
    function  Get_AttributeMemory(Attrib: Integer; var size: Integer): Integer;
    procedure Set_AttributeMemory(Attrib: Integer; var size: Integer; pVal: Integer);
  public
    procedure Speak(const text: WideString);
    procedure Select(index: SYSINT);
    function  EngineID(index: SYSINT): WideString;
    function  ModeName(index: SYSINT): WideString;
    function  MfgName(index: SYSINT): WideString;
    function  ProductName(index: SYSINT): WideString;
    function  ModeID(index: SYSINT): WideString;
    function  Speaker(index: SYSINT): WideString;
    function  Style(index: SYSINT): WideString;
    function  Gender(index: SYSINT): Integer;
    function  Age(index: SYSINT): Integer;
    function  Features(index: SYSINT): Integer;
    function  Interfaces(index: SYSINT): Integer;
    function  EngineFeatures(index: SYSINT): Integer;
    function  LanguageID(index: SYSINT): Integer;
    function  Dialect(index: SYSINT): WideString;
    procedure AudioPause;
    procedure AudioReset;
    procedure AudioResume;
    procedure Inject(const value: WideString);
    function  Phonemes(charset: Integer; Flags: Integer; const input: WideString): WideString;
    procedure PosnGet(var hi: Integer; var lo: Integer);
    procedure TextData(characterset: Integer; Flags: Integer; const text: WideString);
    procedure InitAudioDestMM(deviceid: Integer);
    procedure AboutDlg(hWnd: Integer; const title: WideString);
    procedure GeneralDlg(hWnd: Integer; const title: WideString);
    procedure LexiconDlg(hWnd: Integer; const title: WideString);
    procedure TranslateDlg(hWnd: Integer; const title: WideString);
    function  FindEngine(const EngineID: WideString; const MfgName: WideString; 
                         const ProductName: WideString; const ModeID: WideString; 
                         const ModeName: WideString; LanguageID: Integer; 
                         const Dialect: WideString; const Speaker: WideString; 
                         const Style: WideString; Gender: Integer; Age: Integer; Features: Integer; 
                         Interfaces: Integer; EngineFeatures: Integer; RankEngineID: Integer; 
                         RankMfgName: Integer; RankProductName: Integer; RankModeID: Integer; 
                         RankModeName: Integer; RankLanguage: Integer; RankDialect: Integer; 
                         RankSpeaker: Integer; RankStyle: Integer; RankGender: Integer; 
                         RankAge: Integer; RankFeatures: Integer; RankInterfaces: Integer; 
                         RankEngineFeatures: Integer): Integer;
    procedure GetPronunciation(charset: Integer; const text: WideString; Sense: Integer; 
                               var Pronounce: WideString; var PartOfSpeech: Integer; 
                               var EngineInfo: WideString);
    procedure InitAudioDestDirect(direct: Integer);
    procedure InitAudioDestObject(object_: Integer);
    function  Find(const RankList: WideString): Integer;
    procedure LexAddTo(lex: LongWord; charset: Integer; const text: WideString; 
                       const Pronounce: WideString; PartOfSpeech: Integer; EngineInfo: Integer; 
                       engineinfosize: Integer);
    procedure LexGetFrom(lex: Integer; charset: Integer; const text: WideString; Sense: Integer; 
                         var Pronounce: WideString; var PartOfSpeech: Integer; 
                         var EngineInfo: Integer; var sizeofengineinfo: Integer);
    procedure LexRemoveFrom(lex: Integer; const text: WideString; Sense: Integer);
    procedure QueryLexicons(f: Integer; var pdw: Integer);
    procedure ChangeSpelling(lex: Integer; const stringa: WideString; const stringb: WideString);
    property  ControlInterface: IDirectSS read GetControlInterface;
    property  DefaultInterface: IDirectSS read GetControlInterface;
    property CountEngines: Integer index 18 read GetIntegerProp;
    property MaxRealTime: Integer index 33 read GetIntegerProp;
    property hWnd: Integer index 70 read GetIntegerProp;
    property AudioDest: Integer index 75 read GetIntegerProp;
    property Attributes[Attrib: Integer]: Integer read Get_Attributes write Set_Attributes;
    property AttributeString[Attrib: Integer]: WideString read Get_AttributeString write Set_AttributeString;
    property AttributeMemory[Attrib: Integer; var size: Integer]: Integer read Get_AttributeMemory write Set_AttributeMemory;
  published
    property  TabStop;
    property  Align;
    property  DragCursor;
    property  DragMode;
    property  ParentShowHint;
    property  PopupMenu;
    property  ShowHint;
    property  TabOrder;
    property  Visible;
    property  OnDragDrop;
    property  OnDragOver;
    property  OnEndDrag;
    property  OnEnter;
    property  OnExit;
    property  OnStartDrag;
    property debug: Smallint index 1 read GetSmallintProp write SetSmallintProp stored False;
    property Initialized: Smallint index 2 read GetSmallintProp write SetSmallintProp stored False;
    property Pitch: Integer index 7 read GetIntegerProp write SetIntegerProp stored False;
    property MaxPitch: Integer index 8 read GetIntegerProp write SetIntegerProp stored False;
    property MinPitch: Integer index 9 read GetIntegerProp write SetIntegerProp stored False;
    property Speed: Integer index 10 read GetIntegerProp write SetIntegerProp stored False;
    property MaxSpeed: Integer index 11 read GetIntegerProp write SetIntegerProp stored False;
    property MinSpeed: Integer index 12 read GetIntegerProp write SetIntegerProp stored False;
    property VolumeRight: Integer index 13 read GetIntegerProp write SetIntegerProp stored False;
    property MinVolumeRight: Integer index 14 read GetIntegerProp write SetIntegerProp stored False;
    property MaxVolumeRight: Integer index 15 read GetIntegerProp write SetIntegerProp stored False;
    property RealTime: Integer index 32 read GetIntegerProp write SetIntegerProp stored False;
    property MinRealTime: Integer index 34 read GetIntegerProp write SetIntegerProp stored False;
    property Tagged: Integer index 39 read GetIntegerProp write SetIntegerProp stored False;
    property MouthHeight: Smallint index 49 read GetSmallintProp write SetSmallintProp stored False;
    property MouthWidth: Smallint index 50 read GetSmallintProp write SetSmallintProp stored False;
    property MouthUpturn: Smallint index 51 read GetSmallintProp write SetSmallintProp stored False;
    property JawOpen: Smallint index 52 read GetSmallintProp write SetSmallintProp stored False;
    property TeethUpperVisible: Smallint index 53 read GetSmallintProp write SetSmallintProp stored False;
    property TeethLowerVisible: Smallint index 54 read GetSmallintProp write SetSmallintProp stored False;
    property TonguePosn: Smallint index 55 read GetSmallintProp write SetSmallintProp stored False;
    property LipTension: Smallint index 56 read GetSmallintProp write SetSmallintProp stored False;
    property CallBacksEnabled: Smallint index 57 read GetSmallintProp write SetSmallintProp stored False;
    property MouthEnabled: Smallint index 58 read GetSmallintProp write SetSmallintProp stored False;
    property LastError: Integer index 59 read GetIntegerProp write SetIntegerProp stored False;
    property SuppressExceptions: Smallint index 60 read GetSmallintProp write SetSmallintProp stored False;
    property Speaking: Smallint index 61 read GetSmallintProp write SetSmallintProp stored False;
    property LastWordPosition: Integer index 62 read GetIntegerProp write SetIntegerProp stored False;
    property LipType: Smallint index 63 read GetSmallintProp write SetSmallintProp stored False;
    property Sayit: WideString index 66 read GetWideStringProp write SetWideStringProp stored False;
    property FileName: WideString index 68 read GetWideStringProp write SetWideStringProp stored False;
    property CurrentMode: Integer index 69 read GetIntegerProp write SetIntegerProp stored False;
    property VolumeLeft: Integer index 72 read GetIntegerProp write SetIntegerProp stored False;
    property MinVolumeLeft: Integer index 73 read GetIntegerProp write SetIntegerProp stored False;
    property MaxVolumeLeft: Integer index 74 read GetIntegerProp write SetIntegerProp stored False;
    property OnClickIn: TDirectSSClickIn read FOnClickIn write FOnClickIn;
    property OnClickOut: TDirectSSClickOut read FOnClickOut write FOnClickOut;
    property OnAudioStart: TDirectSSAudioStart read FOnAudioStart write FOnAudioStart;
    property OnAudioStop: TDirectSSAudioStop read FOnAudioStop write FOnAudioStop;
    property OnAttribChanged: TDirectSSAttribChanged read FOnAttribChanged write FOnAttribChanged;
    property OnVisual: TDirectSSVisual read FOnVisual write FOnVisual;
    property OnWordPosition: TDirectSSWordPosition read FOnWordPosition write FOnWordPosition;
    property OnBookMark: TDirectSSBookMark read FOnBookMark write FOnBookMark;
    property OnTextDataStarted: TDirectSSTextDataStarted read FOnTextDataStarted write FOnTextDataStarted;
    property OnTextDataDone: TDirectSSTextDataDone read FOnTextDataDone write FOnTextDataDone;
    property OnActiveVoiceStartup: TDirectSSActiveVoiceStartup read FOnActiveVoiceStartup write FOnActiveVoiceStartup;
    property OnDebugging: TNotifyEvent read FOnDebugging write FOnDebugging;
    property OnError: TDirectSSError read FOnError write FOnError;
    property Onwarning: TDirectSSwarning read FOnwarning write FOnwarning;
    property OnVisualFuture: TDirectSSVisualFuture read FOnVisualFuture write FOnVisualFuture;
  end;

// *********************************************************************//
// The Class CoVoiceProp provides a Create and CreateRemote method to          
// create instances of the default interface IUnknown exposed by              
// the CoClass VoiceProp. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoVoiceProp = class
    class function Create: IUnknown;
    class function CreateRemote(const MachineName: string): IUnknown;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TVoiceProp
// Help String      : VoiceProp Class
// Default Interface: IUnknown
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TVoicePropProperties= class;
{$ENDIF}
  TVoiceProp = class(TOleServer)
  private
    FIntf:        IUnknown;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TVoicePropProperties;
    function      GetServerProperties: TVoicePropProperties;
{$ENDIF}
    function      GetDefaultInterface: IUnknown;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IUnknown);
    procedure Disconnect; override;
    property  DefaultInterface: IUnknown read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TVoicePropProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TVoiceProp
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TVoicePropProperties = class(TPersistent)
  private
    FServer:    TVoiceProp;
    function    GetDefaultInterface: IUnknown;
    constructor Create(AServer: TVoiceProp);
  protected
  public
    property DefaultInterface: IUnknown read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

implementation

uses ComObj;

procedure TDirectSS.InitControlData;
const
  CEventDispIDs: array [0..14] of DWORD = (
    $00000001, $00000002, $00000003, $00000004, $00000005, $00000006,
    $00000007, $00000008, $00000009, $0000000A, $0000000B, $0000000C,
    $0000000D, $0000000E, $0000000F);
  CControlData: TControlData2 = (
    ClassID: '{EEE78591-FE22-11D0-8BEF-0060081841DE}';
    EventIID: '{EEE78597-FE22-11D0-8BEF-0060081841DE}';
    EventCount: 15;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80004002*);
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnClickIn) - Cardinal(Self);
end;

procedure TDirectSS.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IDirectSS;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TDirectSS.GetControlInterface: IDirectSS;
begin
  CreateControl;
  Result := FIntf;
end;

function  TDirectSS.Get_Attributes(Attrib: Integer): Integer;
begin
  Result := DefaultInterface.Attributes[Attrib];
end;

procedure TDirectSS.Set_Attributes(Attrib: Integer; pVal: Integer);
begin
  DefaultInterface.Attributes[Attrib] := pVal;
end;

function  TDirectSS.Get_AttributeString(Attrib: Integer): WideString;
begin
  Result := DefaultInterface.AttributeString[Attrib];
end;

procedure TDirectSS.Set_AttributeString(Attrib: Integer; const pVal: WideString);
  { Warning: The property AttributeString has a setter and a getter whose
  types do not match. Delphi was unable to generate a property of
  this sort and so is using a Variant to set the property instead. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AttributeString := pVal;
end;

function  TDirectSS.Get_AttributeMemory(Attrib: Integer; var size: Integer): Integer;
begin
  Result := DefaultInterface.AttributeMemory[Attrib, size];
end;

procedure TDirectSS.Set_AttributeMemory(Attrib: Integer; var size: Integer; pVal: Integer);
begin
  DefaultInterface.AttributeMemory[Attrib, size] := pVal;
end;

procedure TDirectSS.Speak(const text: WideString);
begin
  DefaultInterface.Speak(text);
end;

procedure TDirectSS.Select(index: SYSINT);
begin
  DefaultInterface.Select(index);
end;

function  TDirectSS.EngineID(index: SYSINT): WideString;
begin
  Result := DefaultInterface.EngineID(index);
end;

function  TDirectSS.ModeName(index: SYSINT): WideString;
begin
  Result := DefaultInterface.ModeName(index);
end;

function  TDirectSS.MfgName(index: SYSINT): WideString;
begin
  Result := DefaultInterface.MfgName(index);
end;

function  TDirectSS.ProductName(index: SYSINT): WideString;
begin
  Result := DefaultInterface.ProductName(index);
end;

function  TDirectSS.ModeID(index: SYSINT): WideString;
begin
  Result := DefaultInterface.ModeID(index);
end;

function  TDirectSS.Speaker(index: SYSINT): WideString;
begin
  Result := DefaultInterface.Speaker(index);
end;

function  TDirectSS.Style(index: SYSINT): WideString;
begin
  Result := DefaultInterface.Style(index);
end;

function  TDirectSS.Gender(index: SYSINT): Integer;
begin
  Result := DefaultInterface.Gender(index);
end;

function  TDirectSS.Age(index: SYSINT): Integer;
begin
  Result := DefaultInterface.Age(index);
end;

function  TDirectSS.Features(index: SYSINT): Integer;
begin
  Result := DefaultInterface.Features(index);
end;

function  TDirectSS.Interfaces(index: SYSINT): Integer;
begin
  Result := DefaultInterface.Interfaces(index);
end;

function  TDirectSS.EngineFeatures(index: SYSINT): Integer;
begin
  Result := DefaultInterface.EngineFeatures(index);
end;

function  TDirectSS.LanguageID(index: SYSINT): Integer;
begin
  Result := DefaultInterface.LanguageID(index);
end;

function  TDirectSS.Dialect(index: SYSINT): WideString;
begin
  Result := DefaultInterface.Dialect(index);
end;

procedure TDirectSS.AudioPause;
begin
  DefaultInterface.AudioPause;
end;

procedure TDirectSS.AudioReset;
begin
  DefaultInterface.AudioReset;
end;

procedure TDirectSS.AudioResume;
begin
  DefaultInterface.AudioResume;
end;

procedure TDirectSS.Inject(const value: WideString);
begin
  DefaultInterface.Inject(value);
end;

function  TDirectSS.Phonemes(charset: Integer; Flags: Integer; const input: WideString): WideString;
begin
  Result := DefaultInterface.Phonemes(charset, Flags, input);
end;

procedure TDirectSS.PosnGet(var hi: Integer; var lo: Integer);
begin
  DefaultInterface.PosnGet(hi, lo);
end;

procedure TDirectSS.TextData(characterset: Integer; Flags: Integer; const text: WideString);
begin
  DefaultInterface.TextData(characterset, Flags, text);
end;

procedure TDirectSS.InitAudioDestMM(deviceid: Integer);
begin
  DefaultInterface.InitAudioDestMM(deviceid);
end;

procedure TDirectSS.AboutDlg(hWnd: Integer; const title: WideString);
begin
  DefaultInterface.AboutDlg(hWnd, title);
end;

procedure TDirectSS.GeneralDlg(hWnd: Integer; const title: WideString);
begin
  DefaultInterface.GeneralDlg(hWnd, title);
end;

procedure TDirectSS.LexiconDlg(hWnd: Integer; const title: WideString);
begin
  DefaultInterface.LexiconDlg(hWnd, title);
end;

procedure TDirectSS.TranslateDlg(hWnd: Integer; const title: WideString);
begin
  DefaultInterface.TranslateDlg(hWnd, title);
end;

function  TDirectSS.FindEngine(const EngineID: WideString; const MfgName: WideString; 
                               const ProductName: WideString; const ModeID: WideString; 
                               const ModeName: WideString; LanguageID: Integer; 
                               const Dialect: WideString; const Speaker: WideString; 
                               const Style: WideString; Gender: Integer; Age: Integer; 
                               Features: Integer; Interfaces: Integer; EngineFeatures: Integer; 
                               RankEngineID: Integer; RankMfgName: Integer; 
                               RankProductName: Integer; RankModeID: Integer; 
                               RankModeName: Integer; RankLanguage: Integer; RankDialect: Integer; 
                               RankSpeaker: Integer; RankStyle: Integer; RankGender: Integer; 
                               RankAge: Integer; RankFeatures: Integer; RankInterfaces: Integer; 
                               RankEngineFeatures: Integer): Integer;
begin
  Result := DefaultInterface.FindEngine(EngineID, MfgName, ProductName, ModeID, ModeName, 
                                        LanguageID, Dialect, Speaker, Style, Gender, Age, Features, 
                                        Interfaces, EngineFeatures, RankEngineID, RankMfgName, 
                                        RankProductName, RankModeID, RankModeName, RankLanguage, 
                                        RankDialect, RankSpeaker, RankStyle, RankGender, RankAge, 
                                        RankFeatures, RankInterfaces, RankEngineFeatures);
end;

procedure TDirectSS.GetPronunciation(charset: Integer; const text: WideString; Sense: Integer; 
                                     var Pronounce: WideString; var PartOfSpeech: Integer; 
                                     var EngineInfo: WideString);
begin
  DefaultInterface.GetPronunciation(charset, text, Sense, Pronounce, PartOfSpeech, EngineInfo);
end;

procedure TDirectSS.InitAudioDestDirect(direct: Integer);
begin
  DefaultInterface.InitAudioDestDirect(direct);
end;

procedure TDirectSS.InitAudioDestObject(object_: Integer);
begin
  DefaultInterface.InitAudioDestObject(object_);
end;

function  TDirectSS.Find(const RankList: WideString): Integer;
begin
  Result := DefaultInterface.Find(RankList);
end;

procedure TDirectSS.LexAddTo(lex: LongWord; charset: Integer; const text: WideString; 
                             const Pronounce: WideString; PartOfSpeech: Integer; 
                             EngineInfo: Integer; engineinfosize: Integer);
begin
  DefaultInterface.LexAddTo(lex, charset, text, Pronounce, PartOfSpeech, EngineInfo, engineinfosize);
end;

procedure TDirectSS.LexGetFrom(lex: Integer; charset: Integer; const text: WideString; 
                               Sense: Integer; var Pronounce: WideString; 
                               var PartOfSpeech: Integer; var EngineInfo: Integer; 
                               var sizeofengineinfo: Integer);
begin
  DefaultInterface.LexGetFrom(lex, charset, text, Sense, Pronounce, PartOfSpeech, EngineInfo, 
                              sizeofengineinfo);
end;

procedure TDirectSS.LexRemoveFrom(lex: Integer; const text: WideString; Sense: Integer);
begin
  DefaultInterface.LexRemoveFrom(lex, text, Sense);
end;

procedure TDirectSS.QueryLexicons(f: Integer; var pdw: Integer);
begin
  DefaultInterface.QueryLexicons(f, pdw);
end;

procedure TDirectSS.ChangeSpelling(lex: Integer; const stringa: WideString; 
                                   const stringb: WideString);
begin
  DefaultInterface.ChangeSpelling(lex, stringa, stringb);
end;

class function CoVoiceProp.Create: IUnknown;
begin
  Result := CreateComObject(CLASS_VoiceProp) as IUnknown;
end;

class function CoVoiceProp.CreateRemote(const MachineName: string): IUnknown;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_VoiceProp) as IUnknown;
end;

procedure TVoiceProp.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{EEE78592-FE22-11D0-8BEF-0060081841DE}';
    IntfIID:   '{00000000-0000-0000-C000-000000000046}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TVoiceProp.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IUnknown;
  end;
end;

procedure TVoiceProp.ConnectTo(svrIntf: IUnknown);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TVoiceProp.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TVoiceProp.GetDefaultInterface: IUnknown;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TVoiceProp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TVoicePropProperties.Create(Self);
{$ENDIF}
end;

destructor TVoiceProp.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TVoiceProp.GetServerProperties: TVoicePropProperties;
begin
  Result := FProps;
end;
{$ENDIF}

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TVoicePropProperties.Create(AServer: TVoiceProp);
begin
  inherited Create;
  FServer := AServer;
end;

function TVoicePropProperties.GetDefaultInterface: IUnknown;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents('ActiveX',[TDirectSS]);
  RegisterComponents(dtlServerPage, [TVoiceProp]);
end;

end.
