unit touchthread;

{$mode delphi}

interface

uses
  Ultibo, GlobalConst, Classes, SysUtils, USB2IICTouch, Touch, Threads;

type
  TTouchCallback = procedure(TouchDataP : PTouchData);

  TTouchThread = class(TThread)
  private
    FUSB2IICTouchP : PUSB2IICTouchDevice;
    FTouchCallback : TTouchCallback;
  public
    constructor Create(aTouchCallback : TTouchCallback);
    procedure Execute; override;
  end;

implementation

uses
  logoutput;

constructor TTouchThread.Create(aTouchCallback : TTouchCallback);
begin
  inherited Create(true);

  FTouchCallback := aTouchCallback;

  FUSB2IICTouchP := PUSB2IICTouchDevice(TouchDeviceFindByName('Touch0'));
  if (FUSB2IICTouchP = nil) then
     log('Failed to find touch device');
end;

procedure TTouchThread.Execute;
var
  TouchData : TTouchData;
  count : Longword;
begin
  log('TouchThread Execute Started');
  ThreadSetName(GetCurrentThreadId, 'SPEEDY CAP_TOUCH');
  while True do
  begin
    if USB2IICTouchDeviceRead(@FUSB2IICTouchP^.Touch, @TouchData, Sizeof(TTouchData), TOUCH_FLAG_NON_BLOCK, count) = ERROR_SUCCESS then
     begin
//      if (TouchData.Info and TOUCH_FINGER = TOUCH_FINGER) then
       begin
        if (assigned(FTouchCallback)) then
           FTouchCallback(@TouchData);
       end;
     end
  end;
end;

end.

