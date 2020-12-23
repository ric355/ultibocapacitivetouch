{
Ultibo USB HID USB2IIC Capacitive Touch Screen Driver.
For QinHeng capacitive touch screen device.

Copyright (C) 2020 Richard Metcalfe

Arch
====

 <All>

Boards
======

 <All>

Licence
=======

 LGPLv2.1 with static linking exception (See COPYING.modifiedLGPL.txt)

Credits
=======

 Information for this unit was obtained from:

References
==========

 USB HID Device Class Definition 1_11.pdf

   http://www.usb.org/developers/hidpage/HID1_11.pdf

 USB HID Usage Tables 1_12v2.pdf

   http://www.usb.org/developers/hidpage/Hut1_12v2.pdf

Touch Screen
============

 This is a touchscreen driver for a 7" capacitive touch panel that is shipped with various 7" LCD screens,
 originating in China. It contains a chip made by QinHeng Electronics which translates I2C to USB
 and this is what the device name shows up as in the USB descriptors (USB2IIC_CTP_CONTROL).

 I haven't been able to specifically identify the reference number or name for the chip itself or the device.
 However the device itself is a generic touchscreen in the sense that it is automatically supported in
 Windows 10 without requiring a specific driver since it conforms to the appropriate HID descriptors
 for multi-touch touchscreens.

 This capacitive touchscreen is a 5 point multi-touch device. At present this driver only supports single
 touch mode but the HID descriptor structure includes all of the multi-touch elements, ready for future expansion,
 and the data is being populated if multi touches are placed, at least on my hardware.

}

unit usb2iictouch;

{$mode delphi} {Default to Delphi compatible syntax}
{$H+}          {Default to AnsiString}
{$inline on}   {Allow use of Inline procedures}

{$define __USB2IICTOUCH_DEBUG}

interface

uses GlobalConfig,GlobalConst,GlobalTypes,Platform,Threads,Devices,USB,Mouse,SysUtils,Touch;


{==============================================================================}
const
 {USB2IIC Touch specific constants}
 USB2IICTOUCH_DRIVER_NAME = 'USB2IIC Touch Driver';

 USB2IICTOUCH_SCREEN_DESCRIPTION = 'QinHeng Capcitive Touch Device';

 USB2IICTOUCH_MAX_X = 4096;
 USB2IICTOUCH_MAX_Y = 4096;

 USB2IICTOUCH_DEVICE_ID_COUNT = 1; {Number of supported Device IDs}

 USB2IICTOUCH_DEVICE_ID:array[0..USB2IICTOUCH_DEVICE_ID_COUNT - 1] of TUSBDeviceId = (
  (idVendor:$1a86;idProduct:$e5e3));

 USB2IICTOUCH_REPORT_ID = $01;

{==============================================================================}
type

 PUSB2IICTouchInputReport = ^TUSB2IICTouchInputReport;
 TUSB2IICTouchInputReport = packed record
   reportId : byte;                                 // Report ID = 0x01 (1)
   DIG_TouchScreenFingerTipSwitch : byte;
   DIG_TouchScreenFingerContactIdentifier : byte;
   GD_TouchScreenFingerX : word;
   GD_TouchScreenFingerY : word;
   DIG_TouchScreenFingerWidth : word;
   DIG_TouchScreenFingerTipSwitch_1 : byte;
   DIG_TouchScreenFingerContactIdentifier_1 : byte;
   GD_TouchScreenFingerX_1 : word;
   GD_TouchScreenFingerY_1 : word;
   DIG_TouchScreenFingerWidth_1 : word;
   DIG_TouchScreenFingerTipSwitch_2 : byte;
   DIG_TouchScreenFingerContactIdentifier_2 : byte;
   GD_TouchScreenFingerX_2 : word;
   GD_TouchScreenFingerY_2 : word;
   DIG_TouchScreenFingerWidth_2 : word;
   DIG_TouchScreenFingerTipSwitch_3 : byte;
   DIG_TouchScreenFingerContactIdentifier_3 : byte;
   GD_TouchScreenFingerX_3 : word;
   GD_TouchScreenFingerY_3 : word;
   DIG_TouchScreenFingerWidth_3 : word;
   DIG_TouchScreenFingerTipSwitch_4 : byte;
   DIG_TouchScreenFingerContactIdentifier_4 : byte;
   GD_TouchScreenFingerX_4 : word;
   GD_TouchScreenFingerY_4 : word;
   DIG_TouchScreenFingerWidth_4 : word;
   DIG_TouchScreenFingerTipSwitch_5 : byte;
   DIG_TouchScreenFingerContactIdentifier_5 : byte;
   GD_TouchScreenFingerX_5 : word;
   GD_TouchScreenFingerY_5 : word;
   DIG_TouchScreenFingerWidth_5 : word;
   DIG_TouchScreenRelativeScanTime : word;
   DIG_TouchScreenContactCount : byte;
 end;


 PUSB2IICTouchDevice = ^TUSB2IICTouchDevice;
 TUSB2IICTouchDevice = record
  {Touch Properties}
  Touch : TTouchDevice;
  {Driver Properties}
  Rotation:LongWord;                     { rotation (eg TOUCH_ROTATION_90)}
  MaxX:LongWord;                         { maximum X value}
  MaxY:LongWord;                         { maximum Y value}
  {USB Properties}
  HIDInterface:PUSBInterface;            {USB Touch Interface}
  ReportRequest:PUSBRequest;             {USB request for report data}
  ReportEndpoint:PUSBEndpointDescriptor; {USB Interrupt IN Endpoint}
  HIDDescriptor:PUSBHIDDescriptor;       {USB HID Descriptor touch}
  ReportDescriptor:Pointer;              {USB HID Report Descriptor for touch}
  PendingCount:LongWord;                 {Number of USB requests pending for this touch}
  WaiterThread:TThreadId;                {Thread waiting for pending requests to complete (for touch detachment)}
  LastFingerTipSwitch:byte;
 end;

{==============================================================================}
var
 {USB2IIC Touch specific variables}
 USB2IICTOUCH_ROTATION:LongWord;

{==============================================================================}
{Initialization Functions}
procedure USB2IICTouchInit;

{==============================================================================}
{USB2IIC Touch Functions}

function USB2IICTouchDeviceRead(Touch:PTouchDevice;Buffer:Pointer;Size,Flags:LongWord;var Count:LongWord):LongWord;{$IFDEF i386} stdcall;{$ENDIF}
function USB2IICTouchDeviceControl(Touch:PTouchDevice;Request:Integer;Argument1:LongWord;var Argument2:LongWord):LongWord;{$IFDEF i386} stdcall;{$ENDIF}

function USB2IICTouchDriverBind(Device:PUSBDevice;Interrface:PUSBInterface):LongWord;
function USB2IICTouchDriverUnbind(Device:PUSBDevice;Interrface:PUSBInterface):LongWord;

procedure USB2IICTouchReportWorker(Request:PUSBRequest);
procedure USB2IICTouchReportComplete(Request:PUSBRequest);

{==============================================================================}
{USB2IIC Touch Helper Functions}
function USB2IICTouchCheckDevice(Device:PUSBDevice):LongWord;

function USB2IICTouchDeviceSetProtocol(Touch:PUSB2IICTouchDevice;Protocol:Byte):LongWord;

function USB2IICTouchDeviceGetReportDescriptor(Touch:PUSB2IICTouchDevice;Descriptor:Pointer;Size:LongWord):LongWord;


implementation

var
 {USB2IIC Touch specific variables}
 USB2IICTouchInitialized:Boolean;

 USB2IICTouchDriver:PUSBDriver;  {USB2IIC Touch Driver interface (Set by USB2IICTouchInit)}

{Forward Declarations}
function USB2IICTouchResolveRotation(ARotation:LongWord):LongWord; forward;

{==============================================================================}
{==============================================================================}

{Initialization Functions}
procedure USB2IICTouchInit;
{Initialize the USB2IIC Touch driver}

{Note: Called only during system startup}
var
 Status:LongWord;
 WorkInt:LongWord;
begin
 {}
 {Check Initialized}
 if USB2IICTouchInitialized then Exit;

 {Check Environment Variables}
 {USB2IICTOUCH_ROTATION}
 WorkInt:=USB2IICTouchResolveRotation(StrToIntDef(SysUtils.GetEnvironmentVariable('USB2IICTOUCH_ROTATION'),0));
 case WorkInt of
  TOUCH_ROTATION_0,TOUCH_ROTATION_90,TOUCH_ROTATION_180,TOUCH_ROTATION_270:begin
    USB2IICTOUCH_ROTATION:=WorkInt;
   end;
 end;

 {Create USB2IIC Touch Driver}
 USB2IICTouchDriver:=USBDriverCreate;
 if USB2IICTouchDriver <> nil then
  begin
   {Update USB2IIC Touch Driver}
   {Driver}
   USB2IICTouchDriver.Driver.DriverName:=USB2IICTOUCH_DRIVER_NAME;
   {USB}
   USB2IICTouchDriver.DriverBind:=USB2IICTouchDriverBind;
   USB2IICTouchDriver.DriverUnbind:=USB2IICTouchDriverUnbind;

   {Register USB2IIC Touch Driver}
   Status:=USBDriverRegister(USB2IICTouchDriver);
   if Status <> USB_STATUS_SUCCESS then
    begin
     if USB_LOG_ENABLED then USBLogError(nil,'USB2IIC Touch: Failed to register USB2IIC Touch driver: ' + USBStatusToString(Status));
    end;
  end
 else
  begin
   if TOUCH_LOG_ENABLED then TouchLogError(nil,'Failed to create USB2IIC Touch driver');
  end;

 USB2IICTouchInitialized:=True;
end;

{==============================================================================}
{==============================================================================}
{USB Touch Functions}
function USB2IICTouchDeviceRead(Touch:PTouchDevice;Buffer:Pointer;Size,Flags:LongWord;var Count:LongWord):LongWord;
{Implementation of TouchDeviceRead API}
{Note: Not intended to be called directly by applications, use TouchDeviceRead instead}
var
 Offset:PtrUInt;
begin
 {}
 Result:=ERROR_INVALID_PARAMETER;

 {Check Touch}
 if Touch = nil then Exit;
 if Touch.Device.Signature <> DEVICE_SIGNATURE then Exit;

 {Check Buffer}
 if Buffer = nil then Exit;

 {Check Size}
 if Size < SizeOf(TTouchData) then Exit;

 {Check Touch Attached}
 if Touch.TouchState <> TOUCH_STATE_ENABLED then Exit;

 {Read to Buffer}
 Count:=0;
 Offset:=0;
 while Size >= SizeOf(TTouchData) do
  begin
   {Check Non Blocking}
   if ((Touch.Device.DeviceFlags and TOUCH_FLAG_NON_BLOCK) <> 0) and (Touch.Buffer.Count = 0) then
    begin
     if Count = 0 then Result:=ERROR_NO_MORE_ITEMS;
     Break;
    end;

   {Wait for Touch Data}
   if SemaphoreWait(Touch.Buffer.Wait) = ERROR_SUCCESS then
    begin
     {Acquire the Lock}
     if MutexLock(Touch.Lock) = ERROR_SUCCESS then
      begin
       try
        {Copy Data}
        PTouchData(PtrUInt(Buffer) + Offset)^:=Touch.Buffer.Buffer[Touch.Buffer.Start];

        {Update Start}
        Touch.Buffer.Start:=(Touch.Buffer.Start + 1) mod TOUCH_BUFFER_SIZE;

        {Update Count}
        Dec(Touch.Buffer.Count);

        {Update Count}
        Inc(Count);

        {Update Size and Offset}
        Dec(Size,SizeOf(TTouchData));
        Inc(Offset,SizeOf(TTouchData));
       finally
        {Release the Lock}
        MutexUnlock(Touch.Lock);
       end;
      end
     else
      begin
       Result:=ERROR_CAN_NOT_COMPLETE;
       Exit;
      end;
    end
   else
    begin
     Result:=ERROR_CAN_NOT_COMPLETE;
     Exit;
    end;

   {Return Result}
   Result:=ERROR_SUCCESS;
  end;
end;

{==============================================================================}

function USB2IICTouchDeviceControl(Touch:PTouchDevice;Request:Integer;Argument1:LongWord;var Argument2:LongWord):LongWord;
{Implementation of TouchDeviceControl API}
{Note: Not intended to be called directly by applications, use TouchDeviceControl instead}
begin
 {}
 Result:=ERROR_INVALID_PARAMETER;

 {Check Touch}
 if Touch = nil then Exit;
 if Touch.Device.Signature <> DEVICE_SIGNATURE then Exit;

 {Check Touch Attached}
 if Touch.TouchState <> TOUCH_STATE_ENABLED then Exit;

 {Acquire the Lock}
 if MutexLock(Touch.Lock) = ERROR_SUCCESS then
  begin
   try
    case Request of
     TOUCH_CONTROL_GET_FLAG:begin
       {Get Flag}
       LongBool(Argument2):=False;
       if (Touch.Device.DeviceFlags and Argument1) <> 0 then
        begin
         LongBool(Argument2):=True;

         {Return Result}
         Result:=ERROR_SUCCESS;
        end;
      end;
     TOUCH_CONTROL_SET_FLAG:begin
       {Set Flag}
       if (Argument1 and not(TOUCH_FLAG_MASK)) = 0 then
        begin
         Touch.Device.DeviceFlags:=(Touch.Device.DeviceFlags or Argument1);

         {Return Result}
         Result:=ERROR_SUCCESS;
        end;
      end;
     TOUCH_CONTROL_CLEAR_FLAG:begin
       {Clear Flag}
       if (Argument1 and not(TOUCH_FLAG_MASK)) = 0 then
        begin
         Touch.Device.DeviceFlags:=(Touch.Device.DeviceFlags and not(Argument1));

         {Return Result}
         Result:=ERROR_SUCCESS;
        end;
      end;
     TOUCH_CONTROL_FLUSH_BUFFER:begin
       {Flush Buffer}
       while Touch.Buffer.Count > 0 do
        begin
         {Wait for Data (Should not Block)}
         if SemaphoreWait(Touch.Buffer.Wait) = ERROR_SUCCESS then
          begin
           {Update Start}
           Touch.Buffer.Start:=(Touch.Buffer.Start + 1) mod TOUCH_BUFFER_SIZE;

           {Update Count}
           Dec(Touch.Buffer.Count);
          end
         else
          begin
           Result:=ERROR_CAN_NOT_COMPLETE;
           Exit;
          end;
        end;

       {Return Result}
       Result:=ERROR_SUCCESS;
      end;
    end;
   finally
    {Release the Lock}
    MutexUnlock(Touch.Lock);
   end;
  end
 else
  begin
   Result:=ERROR_CAN_NOT_COMPLETE;
   Exit;
  end;
end;

function USB2IICDeviceStart(Touch:PTouchDevice):LongWord;{$IFDEF i386} stdcall;{$ENDIF}
begin
  Result := ERROR_SUCCESS;
end;

function USB2IICDeviceStop(Touch:PTouchDevice):LongWord;{$IFDEF i386} stdcall;{$ENDIF}
begin
  Result := ERROR_SUCCESS;
end;

{==============================================================================}

function USB2IICTouchDriverBind(Device:PUSBDevice;Interrface:PUSBInterface):LongWord;
{Bind the USB2IIC Touch driver to a USB device if it is suitable}
{Device: The USB device to attempt to bind to}
{Interrface: The USB interface to attempt to bind to (or nil for whole device)}
{Return: USB_STATUS_SUCCESS if completed, USB_STATUS_DEVICE_UNSUPPORTED if unsupported or another error code on failure}
var
 Status:LongWord;
 Interval:LongWord;
 Touch:PUSB2IICTouchDevice;
 ReportEndpoint:PUSBEndpointDescriptor;
begin
 {}
 Result:=USB_STATUS_INVALID_PARAMETER;

 {Check Device}
 if Device = nil then Exit;

 {$IFDEF USB2IICTOUCH_DEBUG}
 if USB_LOG_ENABLED then USBLogDebug(Device,'USB2IIC Touch: Attempting to bind USB device (Manufacturer=' + Device.Manufacturer + ' Product=' + Device.Product + ' Address=' + IntToStr(Device.Address) + ')');
 {$ENDIF}

 {Check Interface (Bind to interface only)}
 if Interrface = nil then
  begin
   {Return Result}
   Result:=USB_STATUS_DEVICE_UNSUPPORTED;
   Exit;
  end;

 {Check for touch (Must be interface specific)}
 if Device.Descriptor.bDeviceClass <> USB_CLASS_CODE_INTERFACE_SPECIFIC then
  begin
   {Return Result}
   Result:=USB_STATUS_DEVICE_UNSUPPORTED;
   Exit;
  end;

 {Check Interface (Must be HID class)}
 if Interrface.Descriptor.bInterfaceClass <> USB_CLASS_CODE_HID then
  begin
   {Return Result}
   Result:=USB_STATUS_DEVICE_UNSUPPORTED;
   Exit;
  end;

 {Check Endpoint (Must be IN interrupt)}
 ReportEndpoint:=USBDeviceFindEndpointByType(Device,Interrface,USB_DIRECTION_IN,USB_TRANSFER_TYPE_INTERRUPT);
 if ReportEndpoint = nil then
  begin
   {Return Result}
   Result:=USB_STATUS_DEVICE_UNSUPPORTED;
   Exit;
  end;

 {Check USB2IIC Touch Device}
 if USB2IICTouchCheckDevice(Device) <> USB_STATUS_SUCCESS then
  begin
   {$IFDEF USB2IICTOUCH_DEBUG}
   if USB_LOG_ENABLED then USBLogDebug(Device,'USB2IIC Touch: Device not found in supported device list');
   {$ENDIF}
   {Return Result}
   Result:=USB_STATUS_DEVICE_UNSUPPORTED;
   Exit;
  end;

 {Create touch}
 Touch:=PUSB2IICTouchDevice(TouchDeviceCreateEx(SizeOf(TUSB2IICTouchDevice)));
 if Touch = nil then
  begin
   if USB_LOG_ENABLED then USBLogError(Device,'Capacitive Touch: Failed to create new touch device');

   {Return Result}
   Result:=USB_STATUS_DEVICE_UNSUPPORTED;
   Exit;
  end;

 {Update touch}
 {Device}
 Touch.Touch.Device.DeviceBus:=DEVICE_BUS_USB;
 Touch.Touch.Device.DeviceType:=TOUCH_TYPE_CAPACITIVE;
 Touch.Touch.Device.DeviceFlags:=Touch.Touch.Device.DeviceFlags or TOUCH_FLAG_MULTI_POINT;
 Touch.Touch.Device.DeviceData:=Device;
 Touch.Touch.Device.DeviceDescription:=USB2IICTOUCH_SCREEN_DESCRIPTION;
 {touch}
 Touch.Touch.TouchState := TOUCH_STATE_DISABLED;
 Touch.Touch.DeviceRead:=USB2IICTouchDeviceRead;
 Touch.Touch.DeviceControl:=USB2IICTouchDeviceControl;
 Touch.Touch.DeviceStart:=USB2IICDeviceStart;    // these are essential otherwise register touch device fails
 Touch.Touch.DeviceStop:=USB2IICDeviceStop;      // we've stubbed them here though; not sure if they are needed
                                                 // for anything.
 {Driver}
 Touch.LastFingerTipSwitch := 0;
 Touch.Rotation:=USB2IICTOUCH_ROTATION;
 Touch.MaxX:=USB2IICTOUCH_MAX_X;
 Touch.MaxY:=USB2IICTOUCH_MAX_Y;
 {USB}
 Touch.HIDInterface:=Interrface;
 Touch.ReportEndpoint:=ReportEndpoint;
 Touch.WaiterThread:=INVALID_HANDLE_VALUE;

 {Allocate Report Request}
 Touch.ReportRequest:=USBRequestAllocate(Device,ReportEndpoint,USB2IICTouchReportComplete,ReportEndpoint.wMaxPacketSize,Touch);
 if Touch.ReportRequest = nil then
  begin
   if USB_LOG_ENABLED then USBLogError(Device,'Capacitive touch: Failed to allocate USB report request for touch');

   {Destroy Touch}
   TouchDeviceDestroy(@Touch.Touch);

   {Return Result}
   Result:=USB_STATUS_DEVICE_UNSUPPORTED;
   Exit;
  end;

 {Register touch}
 if TouchDeviceRegister(@Touch.Touch) <> ERROR_SUCCESS then
  begin
   if USB_LOG_ENABLED then USBLogError(Device,'USB2IIC Touch: Failed to register new touch device');

   {Release Report Request}
   USBRequestRelease(Touch.ReportRequest);

   {Destroy touch}
   TouchDeviceDestroy(@Touch.Touch);

   {Return Result}
   Result:=USB_STATUS_DEVICE_UNSUPPORTED;
   Exit;
  end;

 {$IFDEF USB_DEBUG}
 if USB_LOG_ENABLED then USBLogDebug(Device,'USB2IIC Touch: Reading HID report descriptors');
 {$ENDIF}

 {Get HID Descriptor}
 Touch.HIDDescriptor := PUSBHIDDescriptor(Interrface^.ClassData);
 if Touch.HIDDescriptor <> nil then
  begin
   if (Touch.HIDDescriptor.bDescriptorType = USB_HID_DESCRIPTOR_TYPE_HID) and (Touch.HIDDescriptor.bHIDDescriptorType = USB_HID_DESCRIPTOR_TYPE_REPORT) then
    begin
     {Get Report Descriptor}
     if (USB_LOG_ENABLED) then USBLogDebug(Device, 'Length of HID report descriptor is ' + inttostr(Touch.HIDDescriptor.wHIDDescriptorLength));

     Touch.ReportDescriptor:=USBBufferAllocate(Device,Touch.HIDDescriptor.wHIDDescriptorLength);
     if Touch.ReportDescriptor <> nil then
      begin
       Status:=USB2IICTouchDeviceGetReportDescriptor(Touch,Touch.ReportDescriptor,Touch.HIDDescriptor.wHIDDescriptorLength);
       if Status <> USB_STATUS_SUCCESS then
        begin
         if USB_LOG_ENABLED then USBLogError(Device,'USB2IIC Touch: Failed to read HID report descriptor: ' + USBStatusToString(Status));

         {Don't fail the bind}
       {$IFDEF USB_DEBUG}
        end
       else
        begin
         if USB_LOG_ENABLED then USBLogDebug(Device,'USB2IIC Touch: Read ' + IntToStr(Touch.HIDDescriptor.wHIDDescriptorLength) + ' byte HID report descriptor');
       {$ENDIF}
        end;
      end;
    end;
  end;

 {$IFDEF USB2IICTOUCH_DEBUG}
 if USB_LOG_ENABLED then USBLogDebug(Device,'USB2IIC Touch: Enabling HID report protocol');
 {$ENDIF}

 {Set Report Protocol}
 Status:=USB2IICTouchDeviceSetProtocol(Touch,USB_HID_PROTOCOL_REPORT);
 if Status <> USB_STATUS_SUCCESS then
  begin
   if USB_LOG_ENABLED then USBLogError(Device,'USB2IIC Touch: Failed to enable HID report protocol: ' + USBStatusToString(Status));

   {Release Report Request}
   USBRequestRelease(Touch.ReportRequest);

   {Release Report Descriptor}
   USBBufferRelease(Touch.ReportDescriptor);

   {Deregister touch}
   TouchDeviceDeregister(@Touch.Touch);

   {Destroy touch}
   TouchDeviceDestroy(@Touch.Touch);

   {Return Result}
   Result:=USB_STATUS_DEVICE_UNSUPPORTED;
   Exit;
  end;

 {Check Endpoint Interval}
 if USB_MOUSE_POLLING_INTERVAL > 0 then
  begin
   {Check Device Speed}
   if Device.Speed = USB_SPEED_HIGH then
    begin
     {Get Interval}
     Interval:=FirstBitSet(USB_MOUSE_POLLING_INTERVAL * USB_UFRAMES_PER_MS) + 1;

     {Ensure no less than Interval} {Milliseconds = (1 shl (bInterval - 1)) div USB_UFRAMES_PER_MS}
     if ReportEndpoint.bInterval < Interval then ReportEndpoint.bInterval:=Interval;
    end
   else
    begin
     {Ensure no less than USB_MOUSE_POLLING_INTERVAL} {Milliseconds = bInterval div USB_FRAMES_PER_MS}
     if ReportEndpoint.bInterval < USB_MOUSE_POLLING_INTERVAL then ReportEndpoint.bInterval:=USB_MOUSE_POLLING_INTERVAL;
    end;
  end;

 {Update Interface}
 Interrface.DriverData:=Touch;

 {Update Pending}
 Inc(Touch.PendingCount);

 {$IFDEF USB2IICTOUCH_DEBUG}
 if USB_LOG_ENABLED then USBLogDebug(Device,'USB2IIC Touch: Submitting report request');
 {$ENDIF}

 {Submit Request}
 Status:=USBRequestSubmit(Touch.ReportRequest);
 if Status <> USB_STATUS_SUCCESS then
  begin
   if USB_LOG_ENABLED then USBLogError(Device,'USB2IIC Touch: Failed to submit report request: ' + USBStatusToString(Status));

   {Update Pending}
   Dec(Touch.PendingCount);

   {Release Report Request}
   USBRequestRelease(Touch.ReportRequest);

   {Release Report Descriptor}
   USBBufferRelease(Touch.ReportDescriptor);

   {Deregister touch}
   TouchDeviceDeregister(@Touch.Touch);

   {Destroy touch}
   TouchDeviceDestroy(@Touch.Touch);

   {Return Result}
   Result:=Status;
   Exit;
  end;

 {Set State to Attached}
 Touch.Touch.TouchState := TOUCH_STATE_ENABLED;

 {Return Result}
 Result:=USB_STATUS_SUCCESS;
end;

{==============================================================================}

function USB2IICTouchDriverUnbind(Device:PUSBDevice;Interrface:PUSBInterface):LongWord;
{Unbind the USB2IIC Touch driver from a USB device}
{Device: The USB device to unbind from}
{Interrface: The USB interface to unbind from (or nil for whole device)}
{Return: USB_STATUS_SUCCESS if completed or another error code on failure}
var
 Message:TMessage;
 Touch:PUSB2IICTouchDevice;
begin
 {}
 Result:=USB_STATUS_INVALID_PARAMETER;

 {Check Device}
 if Device = nil then Exit;

 {Check Interface}
 if Interrface = nil then Exit;

 {Check Driver}
 if Interrface.Driver <> USB2IICTouchDriver then Exit;

 {$IFDEF USB2IICTOUCH_DEBUG}
 if USB_LOG_ENABLED then USBLogDebug(Device,'USB2IIC Touch: Unbinding USB device (Manufacturer=' + Device.Manufacturer + ' Product=' + Device.Product + ' Address=' + IntToStr(Device.Address) + ')');
 {$ENDIF}

 {Get touch}
 Touch:=PUSB2IICTouchDevice(Interrface.DriverData);
 if Touch = nil then Exit;
 if Touch.Touch.Device.Signature <> DEVICE_SIGNATURE then Exit;

 {Set State to Detaching}
 Result:=USB_STATUS_OPERATION_FAILED;
 Touch.Touch.TouchState := TOUCH_STATE_DISABLED;

 {Acquire the Lock}
 if MutexLock(Touch.Touch.Lock) <> ERROR_SUCCESS then Exit;

 {Cancel Report Request}
 USBRequestCancel(Touch.ReportRequest);

 {Check Pending}
 if Touch.PendingCount <> 0 then
  begin
   {$IFDEF USB2IICTOUCH_DEBUG}
   if USB_LOG_ENABLED then USBLogDebug(Device,'USB2IIC Touch: Waiting for ' + IntToStr(touch.PendingCount) + ' pending requests to complete');
   {$ENDIF}

   {Wait for Pending}

   {Setup Waiter}
   Touch.WaiterThread:=GetCurrentThreadId;

   {Release the Lock}
   MutexUnlock(Touch.Touch.Lock);

   {Wait for Message}
   ThreadReceiveMessage(Message);
  end
 else
  begin
   {Release the Lock}
   MutexUnlock(Touch.Touch.Lock);
  end;

 {Set State to Detached}
 Touch.Touch.TouchState := TOUCH_STATE_DISABLED;

 {Update Interface}
 Interrface.DriverData:=nil;

 {Release Report Request}
 USBRequestRelease(Touch.ReportRequest);

 {Release Report Descriptor}
 USBBufferRelease(Touch.ReportDescriptor);

 {Deregister touch}
 if TouchDeviceDeregister(@Touch.Touch) <> ERROR_SUCCESS then Exit;

 {Destroy touch}
 TouchDeviceDestroy(@Touch.Touch);

 {Return Result}
 Result:=USB_STATUS_SUCCESS;
end;

{==============================================================================}

procedure USB2IICTouchReportWorker(Request:PUSBRequest);
{Called (by a Worker thread) to process a completed USB request from the USB2IIC Touch IN interrupt endpoint}
{Request: The USB request which has completed}
var
 Data:TTouchData;
 Status:LongWord;
 Message:TMessage;
 Touch:PUSB2IICTouchDevice;
 Report:PUSB2IICTouchInputReport;
 s : string;
 i : integer;
begin
 {}
 {Check Request}
 if Request = nil then Exit;

 Report := PUSB2IICTouchInputReport(Request.Data);

(* // just debug really
 if (Report^.DIG_TouchScreenFingerTipSwitch = 1) then
 begin
   USBLogDebug(Request.Device,'fingerwidth=' + inttostr(Report^.DIG_TouchScreenFingerWidth) +
      ' x = ' + inttostr((Report^.GD_TouchScreenFingerX)) +
      ' y = ' + inttostr((Report^.GD_TouchScreenFingerY)) +
      ' contactcount = ' + inttostr(Report^.DIG_TouchScreenContactCount) +
   'x1=' + inttostr(Report^.GD_TouchScreenFingerX_1) +
   'x2=' + inttostr(Report^.GD_TouchScreenFingerX_2) +
   'x3=' + inttostr(Report^.GD_TouchScreenFingerX_3) +
   'x4=' + inttostr(Report^.GD_TouchScreenFingerX_4) +
   'x5=' + inttostr(Report^.GD_TouchScreenFingerX_5));

 end;*)

 {Get touch}
 Touch:=PUSB2IICTouchDevice(Request.DriverData);
 if Touch <> nil then
  begin
   {Acquire the Lock}
   if MutexLock(Touch.Touch.Lock) = ERROR_SUCCESS then
    begin
     try
      {Update Statistics}
      Inc(Touch.Touch.ReceiveCount);

      {Check Result}
      if Request.Status = USB_STATUS_SUCCESS then
       begin
        {A report was received from the touch screen}
        Report:=Request.Data;

        {$IFDEF USB2IICTOUCH_DEBUG}
        if USB_LOG_ENABLED then USBLogDebug(Request.Device,'USB2IIC Touch: Report received (ReportId=' + IntToStr(Report.ReportId) + ')');
        {$ENDIF}

        {Check Report}
        if Report.ReportId = USB2IICTOUCH_REPORT_ID then
         begin
          {Check Size}
          if Request.ActualSize >= SizeOf(TUSB2IICTouchInputReport) then
           begin
            // has the touch status changed since last time? (finger lifted or gone down?)
            if (Report.DIG_TouchScreenFingerTipSwitch <> Touch.LastFingerTipSwitch) then
            begin
              if (Report.DIG_TouchScreenFingerTipSwitch  = 1) then
                Data.Info := TOUCH_FINGER
              else
                Data.Info := 0;

              // remember status for next compare.
              Touch.LastFingerTipSwitch := Report.DIG_TouchScreenFingerTipSwitch;

              Data.PositionX:=Report.GD_TouchScreenFingerX;
              Data.PositionY:=Report.GD_TouchScreenFingerY;

              {Check Rotation}
              case Touch.Rotation of
               TOUCH_ROTATION_0:begin
                 {Get X and Y offset}
                 Data.PositionX:=Report.GD_TouchScreenFingerX;
                 Data.PositionY:=Report.GD_TouchScreenFingerY;
                end;
               TOUCH_ROTATION_90:begin
                 {Swap X and Y offset}
                 Data.PositionX:=Report.GD_TouchScreenFingerY;
                 Data.PositionY:=Report.GD_TouchScreenFingerX;
                end;
               TOUCH_ROTATION_180:begin
                 {Invert X and Y}
                 Data.PositionX:=Touch.MaxX - Report.GD_TouchScreenFingerX;
                 Data.PositionY:=Touch.MaxY - Report.GD_TouchScreenFingerY;
                end;
               TOUCH_ROTATION_270:begin
                 {Swap and Invert X and Y}
                 Data.PositionX:=Touch.MaxY - Report.GD_TouchScreenFingerY;
                 Data.PositionY:=Touch.MaxX - Report.GD_TouchScreenFingerX;
                end;
              end;

              {Insert Data}
              TouchInsertData(@Touch.Touch,@Data,True);

            end;
           end
          else
           begin
            if USB_LOG_ENABLED then USBLogError(Request.Device,'USB2IIC Touch: Report invalid (ActualSize=' + IntToStr(Request.ActualSize) + ')');

            {Update Statistics}
            Inc(Touch.Touch.ReceiveErrors);
           end;
         end;
       end
      else
       begin
        if USB_LOG_ENABLED then USBLogError(Request.Device,'USB2IIC Touch: Failed report request (Status=' + USBStatusToString(Request.Status) + ')');

        {Update Statistics}
        Inc(Touch.Touch.ReceiveErrors);
       end;

      {Update Pending}
      Dec(Touch.PendingCount);

      {Check State}
      if Touch.Touch.TouchState = TOUCH_STATE_DISABLED then
       begin
        {Check Pending}
        if Touch.PendingCount = 0 then
         begin
          {Check Waiter}
          if Touch.WaiterThread <> INVALID_HANDLE_VALUE then
           begin
            {$IFDEF USB2IICTOUCH_DEBUG}
            if USB_LOG_ENABLED then USBLogDebug(Request.Device,'USB2IIC Touch: Detachment pending, sending message to waiter thread (Thread=' + IntToHex(Touch.WaiterThread,8) + ')');
            {$ENDIF}

            {Send Message}
            FillChar(Message,SizeOf(TMessage),0);
            ThreadSendMessage(Touch.WaiterThread,Message);
            Touch.WaiterThread:=INVALID_HANDLE_VALUE;
           end;
         end;
       end
      else
       begin
        {Update Pending}
        Inc(Touch.PendingCount);

        {$IFDEF USB2IICTOUCH_DEBUG}
        if USB_LOG_ENABLED then USBLogDebug(Request.Device,'USB2IIC Touch: Resubmitting report request');
        {$ENDIF}

        {Resubmit Request}
        Status:=USBRequestSubmit(Request);
        if Status <> USB_STATUS_SUCCESS then
         begin
          if USB_LOG_ENABLED then USBLogError(Request.Device,'USB2IIC Touch: Failed to resubmit report request: ' + USBStatusToString(Status));

          {Update Pending}
          Dec(Touch.PendingCount);
         end;
       end;
     finally
      {Release the Lock}
      MutexUnlock(Touch.Touch.Lock);
     end;
    end
   else
    begin
     if USB_LOG_ENABLED then USBLogError(Request.Device,'USB2IIC Touch: Failed to acquire lock');
    end;
  end
 else
  begin
   if USB_LOG_ENABLED then USBLogError(Request.Device,'USB2IIC Touch: Report request invalid');
  end;
end;

{==============================================================================}

procedure USB2IICTouchReportComplete(Request:PUSBRequest);
{Called when a USB request from the USB2IIC Touch IN interrupt endpoint completes}
{Request: The USB request which has completed}
{Note: Request is passed to worker thread for processing to prevent blocking the USB completion}
begin
 {}
 {Check Request}
 if Request = nil then Exit;

 WorkerSchedule(0,TWorkerTask(USB2IICTouchReportWorker),Request,nil)
end;

{==============================================================================}
{==============================================================================}
{USB2IIC Touch Helper Functions}
function USB2IICTouchCheckDevice(Device:PUSBDevice):LongWord;
{Check the Vendor and Device ID against the supported devices}
{Device: USB device to check}
{Return: USB_STATUS_SUCCESS if completed or another error code on failure}
var
 Count:Integer;
begin
 {}
 Result:=USB_STATUS_INVALID_PARAMETER;

 {Check Device}
 if Device = nil then Exit;

 {Check Device ID and Interface}
 for Count:=0 to USB2IICTOUCH_DEVICE_ID_COUNT - 1 do
  begin
   if (USB2IICTOUCH_DEVICE_ID[Count].idVendor = Device.Descriptor.idVendor) and (USB2IICTOUCH_DEVICE_ID[Count].idProduct = Device.Descriptor.idProduct) then
    begin
     Result:=USB_STATUS_SUCCESS;
     Exit;
    end;
  end;

 Result:=USB_STATUS_DEVICE_UNSUPPORTED;
end;

{==============================================================================}

function USB2IICTouchDeviceSetProtocol(Touch:PUSB2IICTouchDevice;Protocol:Byte):LongWord;
{Set the report protocol for the USB2IIC Touch device}
{Touch: The USB2IIC Touch device to set the report protocol for}
{Protocol: The report protocol to set (eg USB_HID_PROTOCOL_BOOT)}
{Return: USB_STATUS_SUCCESS if completed or another USB error code on failure}
var
 Device:PUSBDevice;
begin
 {}
 Result:=USB_STATUS_INVALID_PARAMETER;

 {Check Touch}
 if Touch = nil then Exit;

 {Check Interface}
 if Touch.HIDInterface = nil then Exit;

 {Get Device}
 Device:=PUSBDevice(Touch.Touch.Device.DeviceData);
 if Device = nil then Exit;

 {Set Protocol}
 Result:=USBControlRequest(Device,nil,
     USB_HID_REQUEST_SET_PROTOCOL,USB_BMREQUESTTYPE_TYPE_CLASS
        or USB_BMREQUESTTYPE_DIR_OUT
        or USB_BMREQUESTTYPE_RECIPIENT_INTERFACE,
     Protocol,
     Touch.HIDInterface.Descriptor.bInterfaceNumber,
     nil,0);
end;


{==============================================================================}

function USB2IICTouchDeviceGetReportDescriptor(Touch:PUSB2IICTouchDevice;Descriptor:Pointer;Size:LongWord):LongWord;
{Get the Report Descriptor for a USB2IIC Touch device}
{Touch: The USB2IIC Touch device to get the descriptor for}
{Descriptor: Pointer to a buffer to return the USB Report Descriptor}
{Size: The size in bytes of the buffer pointed to by Descriptor}
{Return: USB_STATUS_SUCCESS if completed or another USB error code on failure}
var
 Device:PUSBDevice;
begin
 {}
 Result:=USB_STATUS_INVALID_PARAMETER;

 {Check Touch}
 if Touch = nil then Exit;

 {Check Descriptor}
 if Descriptor = nil then Exit;

 {Check Interface}
 if Touch.HIDInterface = nil then Exit;

 {Get Device}
 Device:=PUSBDevice(Touch.Touch.Device.DeviceData);
 if Device = nil then Exit;

 {Get Descriptor}
 Result:=USBControlRequest(Device,nil,
    USB_DEVICE_REQUEST_GET_DESCRIPTOR,USB_BMREQUESTTYPE_TYPE_STANDARD
      or USB_BMREQUESTTYPE_DIR_IN
      or USB_BMREQUESTTYPE_RECIPIENT_INTERFACE,(USB_HID_DESCRIPTOR_TYPE_REPORT shl 8),
    Touch.HIDInterface.Descriptor.bInterfaceNumber,
    Descriptor,Size);
end;

{==============================================================================}

function USB2IICTouchResolveRotation(ARotation:LongWord):LongWord;
begin
 {}
 case ARotation of
  90:Result:=TOUCH_ROTATION_90;
  180:Result:=TOUCH_ROTATION_180;
  270:Result:=TOUCH_ROTATION_270;
  else
   Result:=ARotation;
 end;
end;

{==============================================================================}
{==============================================================================}

initialization
 USB2IICTouchInit;

{==============================================================================}

finalization
 {Nothing}

{==============================================================================}
{==============================================================================}

end.
