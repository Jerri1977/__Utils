;стриппер\конвертер спрайтов из графических файлов ПЦ в пормат спрайтов
;ZX
;
;> cutter.exe picture.png [/font] [/masked] [/inverted] [/mixed]
;> [/zigzag] [/text] [/attr] 
;>
;> /screen - созранение картинки в виде экрана
;> /font -сохрание картинки в виде фонта
;> /font256 -сохрание картинки в виде быстрого фонта 
;> /masked -картинка режется пополам - справа считается маска (сохраняет­ся
;> второй) слева считается спрайт (соxраняется первым)
;> /inverted -доп параметр для /masked иначе игнорирова­ть - взять байт
;> маски - инвертиров­ать - взять байт спрайта - сделать XOr c полученой
;> маской
;> /mixed -доп параметр для /masked иначе игнорирова­ть -смешать спрайт и
;> маску в вид байт маски+байт­ спрайта
;> /zigzag - сохранять данные зигзагом - слева направо - справа налево
;>
;> /text - преобразов­ать полученные­ данные в defb #xx,#xx также в этом
;> случае добавить вначало текста комментари­й с данными по спрайтам
;> /attr - добавить в конец файла данные по раскраске текста
;> в случае отсутствия­ файла создавать пустой
;> в случае наличия перезаписы­вать поверх(есл­и нужно добавь параметр
;> /overwrite)
;> текст сохранять в виде .inc
;> иначе сохранять в виде .bin

OpenConsole()

#plain=1
#font=2
#masked=3
#screen=4
#font256=5

#text=0
#bin=1

lightcol=7
darkcol=0
inversion=0

Global mode=#plain
Global inverse=#False
Global mixed=#False
Global zigzag=#False
Global saveas=#bin
Global attr=#False
Global flipped=#False
Global truemask=#False
Global marklabel=#False
Global limithigh=#False

Global zz.a,zy.a

result=CountProgramParameters()

Procedure modbyte()
  
If truemask=#True
  zy=zy!zz  ;xorим спрайт инвертированной маской
EndIf

If  inverse=#True
  zz=zz!255 ;инвертируем маску
  zy=zy!zz  ;xorим спрайт инвертированной маской
EndIf

If flipped=#True ;разворачиваем маску по горизонтали
  zyy.w=0
  zzy.w=zz
  For j=0 To 7
    zyy*2
    If zzy&1
       zyy+1
    EndIf
    zzy/2
  Next j
  zz=zyy
EndIf

EndProcedure


If  result=0
 SetCurrentDirectory("C:\IDE\Hant2\gfx\GFX") 
  ;attr=#True
  ;mode=#font

  
  PrintN("Graphic Cutter by Jerri/RedTriangle")
  PrintN("Converting utility")
  PrintN("Usage: Cutter.exe filename.png [flags]")
  PrintN("flags: /screen or /font or /font256 or /plain or /masked")
  PrintN("flags: when you selected /masked here is /inverted or /mixed")
  PrintN("flags: /flipped makes your mask flipped")
  PrintN("flags: /truemask uses other mask")
  PrintN("flags: /zigzag")
  PrintN("flags: /text /attr /label labelname /high spritehigh")
  PrintN("flags: /light /dark setup colors for monocolor tile default 7,0")
  PrintN("flags: /sprinvert for inverted nonmasked sprites")
 
  Delay(1000)  
  ;file$="map.chars.png"
  End
  Else
  file$=ProgramParameter()
  result-1
  EndIf
    
  While result<>0
    result-1
    result$=ProgramParameter()
    
    Select  UCase(result$)
      Case  "/SCREEN"
        mode=#screen
      Case  "/PLAIN"
        mode=#plain
      Case  "/FONT256"
        mode=#font256
      Case  "/FONT"
        mode=#font
      Case  "/MASKED"
        mode=#masked
      Case  "/INVERTED"
        inverse=#True
      Case  "/MIXED"
        mixed=#True
      Case  "/ZIGZAG"
        zigzag=#True
      Case  "/TEXT"
        saveas=#text
      Case "/ATTR"  
        attr=#True
      Case "/FLIPPED"
        flipped=#True
      Case "/TRUEMASK"  
        truemask=#True
      Case "/LABEL"  
        label$=ProgramParameter()
        result-1
        marklabel=#True
      Case "/HIGH"  
        maxhigh=Val(ProgramParameter())
        result-1
        limithigh=#True
      Case "/DARK"  
        darkcol=Val(ProgramParameter())
        result-1
      Case "/LIGHT"  
        lightcol=Val(ProgramParameter())
        result-1
      Case "/SPRINVERT"  
        inversion=1
      Default
        PrintN("Wrong parameter: "+result$)
        Input()
      End
    EndSelect
  Wend

UseJPEGImageDecoder() 
UseJPEG2000ImageDecoder() 
UsePNGImageDecoder() 
UseTIFFImageDecoder() 
UseTGAImageDecoder() 


;грузим картинку
LoadImage(0,file$);путь к файлу

  If  CountString(file$,".")>0
    Repeat
      dot$=Right(file$,1)
      file$=Left(file$,Len(file$)-1)
    Until dot$="."
  EndIf  

;считаем размеры
height=ImageHeight(0) 
width=ImageWidth(0)

If  width&7<>0
  PrintN("Wrong sprite width: "+Str(width))
  Delay(1000)
  End
EndIf


sprlen=width/8
sprhig=height
size=sprlen*sprhig

If  limithigh=#False
  maxhigh=sprhigh
EndIf




c_heig=Round(height/8,#PB_Round_Up)
c_widt=width/8
;считаем цвета
StartDrawing(ImageOutput(0))

;переводим изображение в чистый рав

*MemoryID = AllocateMemory(size+1)
*AttrID  =  AllocateMemory((size/8)+1)
*outfile =  AllocateMemory(size+1)
  If *MemoryID
;    Debug "Starting address of the "+Str(size)+" Byte memory area:"
;    Debug *MemoryID
  Else
    Debug "Couldn't allocate the requested memory!"
    End  
  EndIf
  
  Dim col_body.l(7,1)
  Dim col_oldy.l(7)
colors=0
  
For y=0 To c_heig-1
  For x=0 To c_widt-1
        
;сканируем очередное знакоместо    

yyy=height-(y*8)
If yyy>8 
  yyy=8
EndIf


;зануляем количество цветов
For c=0 To 7
  col_body(c,1)=0
  col_oldy(c)=col_body(c,0)
Next c
;считаем цвета внутри знакоместа
    For yy=0 To yyy-1
      For xx=0 To 7
        index=255
        color=Point(x*8+xx,y*8+yy)
        
       If colors>0
         For z=0 To colors-1
           If col_body(z,0)=color
             col_body(z,1)+1
             index=z
           EndIf
         Next z
       EndIf
       
       If index=255
         col_body(colors,0)=color
         col_body(colors,1)=1
         colors+1
       EndIf
       
     Next xx
   Next yy
   
 ;проверяем пустые цвета
 
 colors=0
 
For c=0 To 7
  
  If col_body(c,1)>0
    index=c
    For t=0 To c
      If col_body(t,1)=0
        index=t
        Break
      EndIf
    Next t
    
    col_body(index,0)=col_body(c,0)
    col_body(index,1)=col_body(c,1)
    colors+1  
    
    If index<>c
      col_body(c,1)=0
    EndIf
    
  EndIf
  
Next c




   If colors=1
      If col_body(0,0)=0
        col_body(colors,0)=RGB(((lightcol&2)/2)*192,((lightcol&4)/4)*192,(lightcol&1)*192)
      Else
        
       If Green(col_body(0,0))=0
       nred=$00010101*Red(col_body(0,0))  
       nblu=$00010101*Blue(col_body(0,0))
       If nred>nblu
         col_body(colors,0)=nred
       Else
         col_body(colors,0)=nblu
       EndIf
       
      Else
         col_body(colors,0)=RGB((darkcol&2)*128,(darkcol&4)*128,(darkcol&1)*128)
      EndIf
      EndIf
      colors+1
   EndIf
    
   
   If colors>2 
     PrintN("Detected more then 2 colors per char at: "+Str(y)+","+Str(x))
     PrintN("colors "+Str(colors))
     For c=0 To colors
       PrintN(Str(c)+" "+Hex(col_body(c,0))+" "+Str(col_body(c,1)))
     Next c
     Input()
     End
   EndIf 
   
    
      item0=Red(col_body(  0,0))*$10000+Green(col_body(  0,0))*$100+Blue(col_body(  0,0))
      item1=Red(col_body(  1,0))*$10000+Green(col_body(  1,0))*$100+Blue(col_body(  1,0))
      
      
      
      
      
      If item0>item1;(Red(col_body(z,0))>=Red(col_body(z+1,0))) And (Green(col_body(z,0))>=Green(col_body(z+1,0))) And (Blue(col_body(z,0))>=Blue(col_body(z+1,0)))
        index=0
        temp_col.l=col_body(0,0)
        temp_num.l=col_body(0,1)
        col_body(0,0)=col_body(1,0)
        col_body(0,1)=col_body(1,1)
        col_body(1,0)=temp_col
        col_body(1,1)=temp_num
      EndIf
   ;вбиваем цвет аттрибута в таблицу аттрибутов
   
   temp_color=0
;вбиваем paper
   
   If Green(col_body(0,0))>127
     temp_color|32
   EndIf
   If Green(col_body(0,0))>191
     temp_color|64
   EndIf
   
   If Red(col_body(0,0))>127
     temp_color|16
   EndIf
   If Red(col_body(0,0))>191
     temp_color|64
   EndIf
   
   If Blue(col_body(0,0))>127
     temp_color|8
   EndIf
   If Blue(col_body(0,0))>191
     temp_color|64
   EndIf
   
;вбиваем ink
   
   If Green(col_body(1,0))>127
     temp_color|4
   EndIf
   If Green(col_body(1,0))>191
     temp_color|64
   EndIf
   
   If Red(col_body(1,0))>127
     temp_color|2
   EndIf
   If Red(col_body(1,0))>191
     temp_color|64
   EndIf
   
   If Blue(col_body(1,0))>127
     temp_color|1
   EndIf
   If Blue(col_body(1,0))>191
     temp_color|64
   EndIf
     PokeB(*AttrID+(y*sprlen)+x,temp_color)
     
     
;     PrintN(Str(y)+","+Str(x)+","+Hex(temp_color))
     
;аттрибуты вбиты

    For yy=0 To yyy-1
      mask=128
      byte=0
      For xx=0 To 7
        color=Point(x*8+xx,y*8+yy)
        
        If inversion=0
          If  color=col_body(0,0)
          ;цвет=чорный?  
          Else
          ;цвет не чорный? 
            byte=byte|mask
          EndIf
        Else
          If  color=col_body(0,0)
          ;цвет=чорный?  
            byte=byte|mask
          Else
          ;цвет не чорный? 
          EndIf
        EndIf
          
        mask>>1      
       Next xx
       PokeA(*memoryID+(((y*8)+yy)*sprlen)+x,byte)
    Next yy
   
  Next x
Next y


PrintN("processing picture")



;PrintN("mode: "+Str(mode))

;переведено смотрим что можно сделать с картинкой

highctr=0          

Select mode
;------------------------------------------    
  Case #screen
    If height<>192 Or width<>256
      PrintN("Wrong screen size: "+Str(height)+"x"+Str(width))
      Delay(1000)
      End
    EndIf
    
    counter=0
    
    For z=0 To 2
      For y=0 To 7 
        For yy=0 To 7
          For x=0 To 31
            zz=PeekA(*memoryID+(z*2048)+(y*32)+(yy*256)+x)                
            PokeA(*outfile+counter,zz)
            counter+1
          Next x
        Next yy
      Next y
    Next z
;-----------------------------------------    
  Case #plain
    ;чистый спрайт без маски
    Select  zigzag
        
      Case  #True
        counter=0
        dest=1
        For y=0 To sprhig-1
          For x=0 To sprlen-1  
            Select dest
              Case 1
                zz=PeekA(*memoryID+x+(y*sprlen))                
              Case -1
                zz=PeekA(*memoryID+(sprlen-1-x)+(y*sprlen))                
            EndSelect
            PokeA(*outfile+counter,zz)
            counter+1
          Next x
          dest=-dest    
          
          highctr+1
          If limithigh And highctr=maxhigh
            highctr=0
            dest=1
          EndIf
          
      Next y
      
      Case  #False
        For y=0 To sprhig-1
          For x=0 To sprlen-1  
                zz=PeekA(*memoryID+x+(y*sprlen))                
                PokeA(*outfile+counter,zz)
            counter+1
          Next x
        Next y
    EndSelect
;------------------------------------------    

  Case #font
    ;картинка это шрифт!
    If  sprhig&7<>0
      PrintN("Wrong font high: "+Str(sprhig))
      Delay(1000)
      End
    EndIf
    counter=0
    For y=0 To (sprhig/8)-1
      For x=0 To sprlen-1
        For z=0 To 7
          zz=PeekA(*memoryID+(z*sprlen)+(y*sprlen*8)+x)      
          PokeA(*outfile+counter,zz)
          counter+1
        Next z
        
        If mixed=#True
          ;PrintN("added attribute")
          zz=PeekA(*AttrID+(y*sprlen)+x)
          PokeA(*outfile+counter,zz)
          counter+1
          size=counter
        EndIf
      Next x
    Next y
;----------------------------------------------------    

  Case #font256
    ;картинка это шрифт!
    ;лимит элементов 256 штук
    ;расположены  линии элементов с шагом 256
    If  sprhig*sprlen<>2048
      PrintN("Wrong font size: "+Str(sprhig*sprlen)+" chars. Must be 256")
      PrintN("Resized to 256")
      FreeMemory(*outfile)
      sprhig=2048/sprlen
      *outfile =  AllocateMemory(2049)
      size=2048
    EndIf
    
    counter=0
    For y=0 To (sprhig/8)-1
      For x=0 To sprlen-1
        For z=0 To 7
          zz=PeekA(*memoryID+(z*sprlen)+(y*sprlen*8)+x)      
          PokeA(*outfile+z*256+counter,zz)
        Next z
          counter+1
      Next x
    Next y
;------------------------------------------    
    
  Case #masked
    ;спрайт с маской
    
    If  sprlen&1<>0 Or sprlen <2
        PrintN("Wrong sprite width: "+Str(sprlen))
        Input()
        End
    EndIf
    
    Select mixed     
      Case  #False
      ;сначала маска, потом спрайт
      Select  zigzag
        Case  #False
          ;queue
          maskplace=sprhig*sprlen/2  
        For y=0 To sprhig-1
          For x=0 To (sprlen/2)-1  ;берем маску            
            zy=PeekA(*memoryID+x+(y*sprlen)) ;берем спрайт
            zz=PeekA(*memoryID+(sprlen/2)+x+(y*sprlen))
            
            modbyte()            
            
            PokeA(*outfile+counter,zz) ;кладем маску            
            PokeA(*outfile+maskplace+counter,zy) ;кладем спрайт            
            counter+1
          Next x
        Next y
        
        
        Case  #True
          ;queue/zigzag
          dest=1
         
          
        For y=0 To sprhig-1
          
          For x=0 To (sprlen/2)-1  
            Select dest
              Case 1
                zy=PeekA(*memoryID+x+(y*sprlen))                
                zz=PeekA(*memoryID+(sprlen/2)+x+(y*sprlen))
              Case -1
                zy=PeekA(*memoryID+((sprlen/2)-1-x)+(y*sprlen))                
                zz=PeekA(*memoryID+(sprlen/2)+((sprlen/2)-1-x)+(y*sprlen))
            EndSelect
              modbyte()            

              PokeA(*outfile+counter,zz)
              PokeA(*outfile+maskplace+counter,zy)
              counter+1
          Next x
          dest=-dest    
          
          highctr+1
          If limithigh And highctr=maxhigh
            highctr=0
            dest=1
          EndIf
          
          
          
        Next y
      EndSelect
    Case  #True  
      ;байт маски/байт спрайта
      Select  zigzag
        Case  #False
          ;mixed
         For y=0 To sprhig-1
            For x=0 To (sprlen/2)-1  ;берем маску            
              zy=PeekA(*memoryID+x+(y*sprlen)) ;берем спрайт
              zz=PeekA(*memoryID+(sprlen/2)+x+(y*sprlen))
              
              modbyte()            
            
              PokeA(*outfile+counter,zz) ;кладем маску            
              PokeA(*outfile+1+counter,zy) ;кладем спрайт            
              counter+2
          Next x
        Next y
        Case  #True
          ;mixed/zigzag
          
        dest=1
        For y=0 To sprhig-1
          For x=0 To (sprlen/2)-1  
            Select dest
              Case 1
                zy=PeekA(*memoryID+x+(y*sprlen))                
                zz=PeekA(*memoryID+(sprlen/2)+x+(y*sprlen))
              Case -1
                zy=PeekA(*memoryID+((sprlen/2)-1-x)+(y*sprlen))                
                zz=PeekA(*memoryID+(sprlen/2)+((sprlen/2)-1-x)+(y*sprlen))
              EndSelect
              
              modbyte()            
            
              PokeA(*outfile+counter,zz) ;кладем маску            
              PokeA(*outfile+1+counter,zy) ;кладем спрайт            
              counter+2
          Next x
        dest=-dest    
          highctr+1
          If limithigh And highctr=maxhigh
            highctr=0
            dest=1
          EndIf
  
      Next y
      EndSelect
    EndSelect
EndSelect
;------------------------------------------    

If mode=#font
  lineitems=8
Else
  lineitems=sprlen
EndIf

;картинка обработана и теперь лежит по *outfile

Select  saveas
  Case  #bin
    file$+".bin"  
    If CreateFile(0,file$)    ; opens an existing file or creates one, if it does not exist yet
      PrintN("writting bitmap")
      WriteData(0, *outfile, size)         
      If attr
        PrintN("writting attrs")
        WriteData(0, *AttrID, c_heig*c_widt)         
      EndIf  
      CloseFile(0)                         ; close the previously opened file and so store the written data
    Else
      PrintN ("Disk Error! File: "+file$)
      End
    EndIf
  Case #text
    
    labelctr=0
    labelind=0
    highctr=0
    
    file$+".inc"  
    If CreateFile(0,file$)    ; opens an existing file or creates one, if it does not exist yet
      WriteStringN(0,";created with cutter 0.1")
      WriteStringN(0,";bitmap "+Str(c_widt)+"x"+Str(height))
      
      WriteStringN(0,"; ")
      
      
      If  marklabel
      WriteStringN(0,"; labellist optimized for fast c64 routine")
        
        WriteStringN(0,label$+"list")
        For x=1 To sprhig/maxhigh
          WriteStringN(0,Chr(9)+"defb"+Chr(9)+Str(maxhigh))
          WriteStringN(0,Chr(9)+"defw"+Chr(9)+label$+RSet(Str(x-1),3,"0"))
          WriteStringN(0,Chr(9)+"defb"+Chr(9)+Str(0))
        Next  x
      EndIf
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      text$=""
      counter=0  
      zz=0
      text$=Chr(9)+"defb"
      zz$=Chr(9)
      
      While counter<>size
        
        
        
        
        zz+1
        text$+zz$+RSet(Str(PeekA(*outfile+counter)),4)
        zz$=","
        counter+1
        
        If  zz=lineitems
          WriteStringN(0,Text$)
          zz=0
          text$=Chr(9)+"defb"
          zz$=Chr(9)
        EndIf
        
        If marklabel
        If  labelind=0
          WriteStringN(0,label$+RSet(Str(labelctr),3,"0"))
          labelctr+1
        EndIf
        
        labelind+1
        
        If labelind=maxhigh*sprlen
          labelind=0
        EndIf
        EndIf
        
        If  limithigh
        highctr+1  
        If highctr=maxhigh*sprlen
          highctr=0
          WriteStringN(0,";------------")
        EndIf
        EndIf
        
      Wend
      If  zz<>0
        WriteStringN(0,Text$)
        EndIf
       
        If attr
            
          WriteStringN(0,";attrs "+Str(c_widt)+"x"+Str(c_heig))
          text$=Chr(9)+"defb"
          zz$=Chr(9)  
          zz=0
          counter=0  
        While counter<>(c_widt*c_heig)
          If  zz=c_widt
          WriteStringN(0,Text$)
          zz=0
          text$=Chr(9)+"defb"
          zz$=Chr(9)
        EndIf
        zz+1
        text$+zz$+RSet(Str(PeekA(*AttrID+counter)),4)
        zz$=","
        counter+1
      Wend
        WriteStringN(0,Text$)
      EndIf
      
      CloseFile(0)                         ; close the previously opened file and so store the written data
    Else
      PrintN ("Disk Error! File: "+file$)
      End
    EndIf
EndSelect
End
; IDE Options = PureBasic 4.61 (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 155
; FirstLine = 101
; Folding = +
; EnableUser
; Executable = cutter.exe
; CurrentDirectory = D:\_work\PureBasic461\
; Compiler = PureBasic 4.61 (Windows - x86)