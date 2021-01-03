mem_ptr.l=0
fsize=0

spr_width=1
spr_high=8

*filemem=0

zoom_mode=4

  If InitSprite() And InitKeyboard() And OpenWindow(0, 0, 0, 1024,600, "A screen in a window...", #PB_Window_SystemMenu |  #PB_Window_TitleBar     | #PB_Window_ScreenCentered)
    OpenWindowedScreen(WindowID(0), 0, 0, 1024, 512, 0, 0, 0)
    EnableWindowDrop(0,#PB_Drop_Files,#PB_Drag_Copy)
      ClearScreen(RGB(0, 0, 63))
      If StartDrawing(ScreenOutput())
        DrawingMode(1)
        FrontColor(RGB(128, 255, 0))
        DrawText(20, 20, "Drop file here")
        StopDrawing()
        redraw=1
      EndIf
      
      If CreateMenu(0, WindowID(0))
        MenuItem(1, "x1")
        MenuItem(2, "x2")
        MenuItem(4, "x4")
        MenuItem(8, "x8")
      EndIf
      
      ;ширина спрайта
      TextGadget(3,0,525,40,20,"Width:",#PB_Text_Right)
      SpinGadget(5,40,522,40,20,1,256,#PB_Spin_Numeric)
      SetGadgetText(5,Str(spr_width))      
      GadgetToolTip(5,"Sprite width 1-256")
      
      TextGadget(6,0,545,40,20,"High:",#PB_Text_Right)
      SpinGadget(7,40,542,40,20,1,256,#PB_Spin_Numeric)
      SetGadgetText(7,Str(spr_high))      
      GadgetToolTip(7,"Sprite high 1-256")
      
      
      
      Repeat
        If redraw
          FlipBuffers()
          redraw=0
        EndIf
          Event = WindowEvent() 
        Select event
          Case #PB_Event_WindowDrop
            Files$ = EventDropFiles()
            ;поймали файл                      
            Files$ = StringField(Files$, 1, Chr(10))
            If*filemem<>0
              FreeMemory(*filemem)
            EndIf
            fsize=FileSize(files$)
            ReadFile(0,Files$)
            *filemem=AllocateMemory(fsize)
            Result = ReadData(0, *filemem, fsize)
            CloseFile(0)
            redraw=1
            
          Case #PB_Event_Menu
            value=EventMenu()
             Select value
               Case 1, 2, 4, 8
                zoom_mode=value
                redraw=1
             EndSelect                  
      EndSelect
      ;рисуем то что на экране      

      If fsize<>0 And redraw
        StartDrawing(ScreenOutput())
        Box(0,0,1024,512,RGB(0, 0, 63))
        
            sizey=512/spr_high/zoom_mode
            sizex=1024/8/zoom_mode
            shift.l=0
            
            For yy=0 To sizey-1 
              For xx=0 To sizex-1
                For y=0 To spr_high-1
                  If  mem_ptr+shift<fsize
                    byte.w=PeekA(*filemem+mem_ptr+shift)
                  Else
                    Break 3
                  EndIf  
                  mask.w=128
                  For x=0 To 7
                      If byte&mask
                        color=RGB(255,255,255)
                      Else
                        color=RGB(0,0,0)
                      EndIf
                    mask/2
                    
                    Box((xx*8+x)*zoom_mode,(yy*spr_high+y)*zoom_mode,zoom_mode,zoom_mode,color)
                    
                  Next x
                  shift+1
                Next y
              Next xx
            Next yy
        StopDrawing()
        
      EndIf
;    ForEver
    
    Until Event = #PB_Event_CloseWindow
  EndIf


; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 39
; FirstLine = 1
; EnableXP