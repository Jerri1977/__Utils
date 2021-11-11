mem_ptr.l=0
fsize=0

spr_width=1
spr_high=8

*filemem=0

zoom_mode=1

  If InitSprite() And InitKeyboard() And OpenWindow(0, 0, 0, 1024,600, "Data view", #PB_Window_SystemMenu |  #PB_Window_TitleBar     | #PB_Window_ScreenCentered)
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
      TextGadget(3,0,520,100,20,"Width: "+Str(spr_width),#PB_Text_Border)
;      SpinGadget(5,40,522,40,20,1,256,#PB_Spin_ReadOnly)
;      SetGadgetText(5,Str(spr_width))      
;      GadgetToolTip(5,"Sprite width 1-256")
      
      TextGadget(6,0,545,100,20,"  High: "+Str(spr_high),#PB_Text_Border)
;      SpinGadget(7,40,542,40,20,1,256,#PB_Spin_ReadOnly)
;      SetGadgetText(7,Str(spr_high))      
;      GadgetToolTip(7,"Sprite high 1-256")
      
      
      
Repeat
        If redraw
          FlipBuffers()
          redraw=0
        EndIf
        
        If fsize<>0
          maxx=1024/zoom_mode/8
          maxy=512/zoom_mode
          ExamineKeyboard()
              If KeyboardPushed(#PB_Key_1)
                zoom_mode=1
                redraw=1
              EndIf
              If KeyboardPushed(#PB_Key_2)
                zoom_mode=2
                redraw=1
              EndIf
              If KeyboardPushed(#PB_Key_3)
                zoom_mode=4
                redraw=1
              EndIf
              If KeyboardPushed(#PB_Key_4)
                zoom_mode=8
                redraw=1
              EndIf
              
              If KeyboardPushed(#PB_Key_4)
                zoom_mode=8
                redraw=1
              EndIf
              
              
              If KeyboardPushed(#PB_Key_Pad8)
                spr_high+(1 And spr_high<maxy)   
                SetGadgetText(6, "  High: "+Str(spr_high))
                redraw=1
              EndIf
              If KeyboardPushed(#PB_Key_Pad2)
                spr_high-(1 And spr_high>1)
                SetGadgetText(6, "  High: "+Str(spr_high))
                redraw=1
              EndIf
              
              If KeyboardPushed(#PB_Key_Pad6)
                spr_width+(1 And spr_width<maxx)   
                SetGadgetText(3, "Width: "+Str(spr_width))
                redraw=1
              EndIf
              If KeyboardPushed(#PB_Key_Pad4)
                spr_width-(1 And spr_width>1)
                SetGadgetText(3, "Width: "+Str(spr_width))
                redraw=1
              EndIf
              
              If KeyboardPushed(#PB_Key_Up)
                If  pointer=>spr_width
                  pointer-spr_width
                  redraw=1
                EndIf
              EndIf
              If KeyboardPushed(#PB_Key_Down)
                If  pointer+spr_width<fsize
                  pointer+spr_width
                  redraw=1
                EndIf
              EndIf
              
              If KeyboardPushed(#PB_Key_Left)
                pointer-(1 And pointer=>1)
                redraw=1
              EndIf
              If KeyboardPushed(#PB_Key_Right)
                pointer+(1 And pointer+1<fsize)
                redraw=1
              EndIf
              
              If KeyboardReleased(#PB_Key_PageUp)
                If pointer=>maxpage
                  pointer-maxpage
                  redraw=1
                EndIf
              
              EndIf
              If KeyboardReleased(#PB_Key_PageDown)
                If pointer+maxpage<fsize
                  pointer+maxpage
                  redraw=1
                EndIf
              EndIf
              
              
              
              
              
              
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
            pointer=0
          Case #PB_Event_Menu
            value=EventMenu()
             Select value
               Case 1, 2, 4, 8
                zoom_mode=value
                redraw=1
             EndSelect                  
;           Case #PB_Event_Gadget
 ;            Select EventGadget()
 ;              Case 5
                 
                   
  ;                 temp=EventType()
                   
                 
   ;          EndSelect
             
             
             
             
             
             
             
             
         EndSelect
      ;рисуем то что на экране      

      If fsize<>0 And redraw
        
        shift.l=pointer
        scrsize=0
        
        name.s="Data view "+"mag*"+Str(zoom_mode)+" #"+RSet(Hex(pointer),8,"0")+"/"+RSet(Hex(fsize),8,"0")
        SetWindowTitle(0, name.s)
        
        StartDrawing(ScreenOutput())
        Box(0,0,1024,512,RGB(0, 0, 63))
        
            sizey=512/spr_high/zoom_mode
            sizex=1024/spr_width/8/zoom_mode
            
            For yy=0 To sizey-1 
                
              For xx=0 To sizex-1
               
                For y=0 To spr_high-1
                  
                For xxx=0 To spr_width-1
                  
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
                    
                    Box((xx*(spr_width*8)+xxx*8+x)*zoom_mode,(yy*spr_high+y)*zoom_mode,zoom_mode,zoom_mode,color)
                    
                    
                    
                  Next x
                  shift+1
                  scrsize+1
                Next xxx
                
                Next y
                
              Next xx
              
            Next yy
            
            StopDrawing()
            maxpage=scrsize
      EndIf
      
      
      
      
        
        
        
        
        
        
        
        
        
        
        
        
        
        

      
      
      
      
      
      
      
      
      
      
      
      ;    ForEver
    
    Until Event = #PB_Event_CloseWindow
  EndIf


; IDE Options = PureBasic 4.61 (Windows - x86)
; CursorPosition = 130
; FirstLine = 100
; Executable = viewer.exe
; Compiler = PureBasic 4.61 (Windows - x86)