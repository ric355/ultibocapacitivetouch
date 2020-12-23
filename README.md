# ultibocapacitivetouch

To use this touch device driver, you will need to create a thread and assign a callback function. There is an example thread in the touchthread.pas file.  To use it, create the thread as follows;

```
var
  MyTouchThread : TTouchThread;
  
procedure TouchCallback(TouchDataP : PTouchData);
begin
  if (TouchDataP^.Info = TOUCH_FINGER) then
  begin
    // screen was touched
    // TouchDataP^.PositionX and PositionY contain the coordinates (the scale used is the touch screeen, 4096,
    // so you must scale it to your screen resolution to find a pixel point.
  end
  else
  if (TouchDataP^.Info = 0) then
  begin
    // finger was lifted from the screen
  end;  
end;

begin
  MyTouchThread := TTouchThread.Create(@TouchCallback);
  
  while (true) do
  begin
    // do some other stuff
  end;
end.
```

When using this callback you must make sure you use appropriate threadsafe objects to protect any data being accesed from both the main prgoram and the touch thread. This is because the TouchCallback() procedure is called by the TouchThread and hence is a different thread to the one running the while loop in the example above.

Note that this device driver does provide multi-touch data in the internal structures but this is not processed at the moment so the driver is really only single touch. It also disables drag features (notifications if you move your finger around the screen while keeping it touched) as I found these to be a bit laggy. More work is required to enable this in an efficient way.
