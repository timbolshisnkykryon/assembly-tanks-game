IDEAL
MODEL small
STACK 0f500h
MAX_BMP_WIDTH = 320
MAX_BMP_HEIGHT = 200
DATASEG
    OneBmpLine 	db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
    ScreenLineMax 	db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer

    ;BMP File data
    FileHandle	dw ?
    Header 	    db 54 dup(0)
    Palette 	db 400h dup (0)

    ;Maps
    Map db 'map1.bmp',0
    Map2 db 'map2.bmp', 0
    Map3 db 'map3.bmp', 0

    ;Bmp Files
    TankDown db 'tank2.bmp',0
    TankUp db 'tank4.bmp',0
    TankLeft db 'tank3.bmp',0
    TankRight db 'tank1.bmp',0
    VertBg db 'bgv.bmp',0
    HorzBg db 'bgh.bmp',0
    number3 db 'num3.bmp',0
    number2 db 'num2.bmp',0
    number1 db 'num1.bmp',0
    go db 'num.bmp',0
    CDB db 'cdb.bmp', 0
    Missile db 'mis.bmp', 0
    Enemy1 db 'enmy1.bmp',0
    Enemy2 db 'enmy2.bmp', 0
    Enemy3 db 'enmy3.bmp', 0
    PauseMenu db 'ps.bmp', 0
    SinglePlayerTutorial db 'st.bmp', 0
    MultiplayerTutorial db 'mt.bmp', 0
    Explosion db 'expls.bmp', 0
    HorzExplosion db 'hexp.bmp', 0
    BmpFileErrorMsg    	db 'Error At Opening Bmp File .', 0dh, 0ah,'$'
    ErrorFile           db 0
    Transition db 'tns.bmp', 0
    BB db "BB..",'$'
    direction db 0 ;horizontal position
    VHrow db ? ;Defines what kind of row to check
    MapsScreen db 'maps.bmp', 0
    CongratsScreen db 'cgs.bmp', 0
    MissileClean db 'msc.bmp',0
    GameOver db 'gv.bmp', 0
    ReturnAddress dw ?
    ;Picture Properties
    BmpLeft dw 0
    BmpTop dw 0
    BmpColSize dw 320
    BmpRowSize dw 200

    ;Timer and Sound Variables
    Clock equ es:6Ch
    ticks dw 6
    Time db 50

    ;Painting Variables
    xCheck dw ? ;variable for pixel checking
    yCheck dw ? ;variable for pixel checking
    black db 0 ;represents an object on the map
    red db 1h ;Color for all maps background
    object db 0 ;Boolian variable to check if user's tank is touching something and cant move
    MyTank db 0 ;Color of my tank which I find in procedure 'FindColors'
    EnemyTank db 0
    lastshot db 0 ;To avoid missile 'spraying'

    ;Sound (music notes)
    note dw ?
    highnote1 dw 04742h ; 1193180 /-> (hex)  do
    note1 dw 011D0h ; 1193180 /-> (hex)  do
    note2 dw 0FDFh ; 1193180 /  -> (hex) re
    note3 dw 0E24h ; 1193180 /  -> (hex) mi
    note4 dw 0D58h ; 1193180 /  -> (hex) fa
    note5 dw 0BE3h ; 1193180 / -> (hex) sol
    note6 dw 0A97h ; 1193180 / -> (hex) la
    note7 dw 096Fh ; 1193180 / -> (hex) si

    ;Main Menu Variables
    Menu db 'menu.bmp', 0
    GameMode db 0
    ;Buttons
    Btn1 db 'btn1.bmp', 0
    SelectedBtn1 db 'sbtn1.bmp', 0
    Btn2 db 'btn2.bmp', 0
    SelectedBtn2 db 'sbtn2.bmp', 0
    Btn3 db 'btn3.bmp', 0
    SelectedBtn3 db 'sbtn3.bmp', 0

    Num1 db 'n1.bmp', 0 ;Numbers of countdown
    Num2 db 'n2.bmp', 0
    Num3 db 'n3.bmp', 0
    Num db 'go.bmp', 0
    cbg db 'cbg.bmp', 0

    Level db 1
    LevelMsg1 DB 'level 1 Completed!', '$'
    LevelMsg2 DB 'Level 2 Completed!', '$'
    LevelMsg3 DB 'All Complete', '$'

    ;Single PLayer
    ;Missiles information
    MissilesX dw 40 dup(0)
    MissilesY dw 40 dup(0)
    MissilesXJump dw 40 dup(0)
    MissilesYJump dw 40 dup(0)
    Collisions dw 40 dup(0)
    Collision dw 0
    rocket dw 0
    EnemiesAlive db 1,1,1
    StartX dw 0 ;The starting cordinates of each missile
    StartY dw 0
    XJump dw 0 ;The starting x and y difference of each missile
    YJump dw 0
    Hit db 0 ;Boolian variable to check if user got hit
    AllDead db 0;Boolian variable to check if all enemies are dead
    Look db 0 ;The last direction of the tank
    Enemies db 3 ;Number of active enemies on the map
    MainReturnAddress dw ? ;The return address of 'SingleGame'
    Trash dd 0
CODESEG

;====================================================================
;====================================================================
;===== Procedures  Area =============================================
;====================================================================
;====================================================================
proc MapTransition
    ;Set black screen and display a string
	mov [BmpLeft], 0
	mov [BmpTop], 0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	mov dx, offset Transition
  call OpenShowBmp
    mov dh,3; cursor col
    mov dl,10; cursor row
    mov ah,02h; move cursor to the right place
    xor cx,cx
    xor bh,bh ; video page 0
    int 10h

	cmp [Level], 1
	jne TransitionLevel2

	mov dx, offset LevelMsg1   ; DS:DX points to message
    mov ah,9             ; function 9 - display string
    int 21h
	jmp TextAppeared
TransitionLevel2:
	cmp [Level], 2
	jne TransitionLevel3

	mov dx, offset LevelMsg2   ; DS:DX points to message
    mov ah,9             ; function 9 - display string
    int 21h
	jmp TextAppeared
TransitionLevel3:
	mov dx, offset LevelMsg3   ; DS:DX points to message
	mov ah,9             ; function 9 - display string
	int 21h

TextAppeared:
	mov [ticks], 60
	call Timer
    ;Revive all enemies



	ret
endp MapTransition
proc EmptyArrays
    ;procedure is called at every map to clean the arrays of the missiles to avoid their overflow
  mov cx, 40
OneIndex:
  mov bx, cx ;Create copy

  xor ax, ax
  mov al, 2
  dec bx ;For index
  mul bx
  mov bx, ax

  mov [Collisions +bx], 0
  mov [MissilesX + bx], 0
  mov [MissilesY + bx], 0
  mov [MissilesXJump + bx], 0
  mov [MissilesYJump + bx], 0
  loop OneIndex

  ;Set acive rockets to 0
  mov [rocket], 0
  ;Revive enemies between maps
  mov [EnemiesAlive], 1
  mov [EnemiesAlive+1], 1
  mov [EnemiesAlive+2], 1
  ret
endp EmptyArrays
proc MapsChoice
    ;Procedure of the button 'Maps' which jumps
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov [BmpTop], 0
    mov [BmpLeft], 0
    mov dx, offset MapsScreen
    call OpenShowBmp

Selection:
    in al, 64h ;Read keyboard status port
    cmp al, 10b ;Data in buffer ?
    je Selection ;Wait until data available
    in al, 60h ;Get keyboard data

    cmp al, 2 ;number 1
    je GoToMap1
    cmp al, 3 ;number 2
    je GoToMap2
    cmp al, 4 ;number 3
    je GoToMap3
    cmp al, 1 ;Esc key
    je EndOfSelection
    jmp Selection

GoToMap1:
    pop ax ;Clean the return address of this procedure
    jmp FirstMap
GoToMap2:
    pop ax ;Clean the return address of this procedure
    jmp SecondMap
GoToMap3:
    pop ax ;Clean the return address of this procedure
    jmp ThirdMap

EndOfSelection:
	ret
endp MapsChoice
proc CompleteScreen
    ;Procedure that is called when user completed all levels
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov [BmpTop], 0
    mov [BmpLeft], 0
    mov dx, offset CongratsScreen
    call OpenShowBmp
    ret
endp CompleteScreen
proc GameOverScreen
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov [BmpTop], 0
    mov [BmpLeft], 0
    mov dx, offset GameOver
    call OpenShowBmp
    ret
endp GameOverScreen


proc TutorialScreen
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320
    mov [BmpRowSize], 200
    mov dx, offset SinglePlayerTutorial
    call OpenShowBmp

Reading:
    in al, 64h ;Read keyboard status port
    cmp al, 10b ;Data in buffer ?
    je Reading ;Wait until data available
    in al, 60h ;Get keyboard data

    cmp al, 1Ch ;Enter key
    je EndOfReading
    jmp Reading

EndOfReading:
    ret
endp TutorialScreen

proc StartSecondCountdown
    ;INPUT - X
    ;OUTPUT- X
    ;Info - This procedure displays 3 pictures of numbers (3,2,1)
    ; and simultaneously makes a sound at every picture
  push [BmpLeft]
  push [BmpTop]

  mov [ticks], 10
  mov [BmpTop], 70
  mov [BmpLeft], 115
  mov [BmpColSize], 40
  mov [BmpRowSize], 54

  mov ax, [highnote1] ;Low Do note
  mov [note],ax

  mov cx, 4 ; We need 4 sounds
abeep:
  cmp cx,1
  je alastnote ;we need that last note to be higher
  cmp cx, 4
  je aprint3
  cmp cx, 3
  je aprint2
aprint1:
  mov dx, offset Num1
  jmp aMakeASound
aprint2:
  mov dx, offset Num2
  jmp aMakeASound
aprint3:
  mov dx, offset Num3
aMakeASound:
  call OpenShowBmp
  call sound
  call Timer
  loop abeep

alastnote:
  mov [BmpColSize], 54
  mov [BmpRowSize], 40
  mov dx, offset Num
  call OpenShowBmp
  mov ax, [note1] ;DO Note
  mov [note],ax
  call Sound

  mov [BmpColSize], 54
  mov [BmpRowSize], 55
  mov dx, offset cbg
  call OpenShowBmp
  ;Clear Background

  pop [BmpTop]
  pop [BmpLeft]
  ret
endp StartSecondCountdown

proc SetThirdMap
    ;Map
    mov [BmpLeft],0
    mov [BmpTop],0
    mov [BmpColSize], 320
    mov [BmpRowSize] ,200
    mov dx,offset Map3
    call OpenShowBmp

    ;Tank 9
    mov [BmpLeft],252
    mov [BmpTop],28
    mov [BmpColSize], 24
    mov [BmpRowSize] , 17
    mov dx,offset Enemy3
    call OpenShowBmp

    ;Tank 8
    mov [BmpColSize], 16
    mov [BmpRowSize] , 24
    mov [BmpLeft], 278
    mov [BmpTop],48
    mov dx, offset Enemy2
    call OpenShowBmp

    ;Tank 7
    mov [BmpLeft],30
    mov [BmpTop],66
    mov dx,offset Enemy2
    call OpenShowBmp

    ;Player
    mov [BmpLeft],54
    mov [BmpTop],134
    mov dx,offset TankDown
    call OpenShowBmp
	ret
endp SetThirdMap

proc SetSecondMap
    ;OUTPUT- 3 Pictures of 2 tanks and the first map
    ;Info - displaying 3 bmp files with 'openshowbmp'
	;Map
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200

	mov dx,offset Map2
	call OpenShowBmp

	;Enemies
    ;Tank 4
	mov [BmpLeft],260
	mov [BmpTop],30
	mov [BmpColSize], 24
	mov [BmpRowSize] , 16
	mov dx,offset Enemy3
	call OpenShowBmp
    ;Tank 5
	mov [BmpLeft], 178
	mov [BmpTop],73
	mov dx, offset Enemy3
	call OpenShowBmp
    ;Tank 6
	mov [BmpLeft],260
	mov [BmpTop],152
	mov dx,offset Enemy3
	call OpenShowBmp


    ;Player
  	mov [BmpLeft],35
  	mov [BmpTop],140
  	mov [BmpColSize], 16
  	mov [BmpRowSize] , 24

  	mov dx,offset TankUp
  	call OpenShowBmp

	ret
endp SetSecondMap

proc SetFirstMap
    ;OUTPUT- 3 Pictures of 2 tanks and the first map
    ;Info - displaying 3 bmp files with 'openshowbmp'
	;Map
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize] ,200

	mov dx,offset Map
	call OpenShowBmp
	;Tank
	mov [BmpColSize], 16
	mov [BmpRowSize] , 24
	mov [BmpLeft],35
	mov [BmpTop],40
	mov dx,offset TankDown
	call OpenShowBmp

	; ;Enemy tanks
    mov dx,offset Enemy1

	mov [BmpLeft],260
	mov [BmpTop],140
	mov [BmpColSize], 16
	mov [BmpRowSize] , 24
	call OpenShowBmp

    mov dx,offset Enemy2
	mov [BmpLeft],100
	mov [BmpTop],30
	mov [BmpColSize], 16
	mov [BmpRowSize] , 24
	call OpenShowBmp

    mov dx,offset Enemy3
	mov [BmpLeft],180
	mov [BmpTop],150
	mov [BmpColSize], 24
	mov [BmpRowSize] , 17
	call OpenShowBmp
	ret
endp SetFirstMap

proc MainMenu
    mov [BmpTop], 0
    mov [BmpLeft], 0
    mov [BmpRowSize], 200
    mov [BmpColSize], 320
	mov dx, offset Menu
	call OpenShowBmp

	;Show Button 1
	mov [BmpTop], 100
	mov [BmpLeft], 120
	mov [BmpRowSize], 12
	mov [BmpColSize], 72

	mov dx, offset Btn1
	call OpenShowBmp

	;Show Button 2
	add [BmpTop], 20
	mov dx, offset Btn2
	call OpenShowBmp

	; ;Show Button 3
	add [BmpTop], 20
	mov dx, offset Btn3
	call OpenShowBmp

	mov bl,1 ;The button the arrows are indicating (start always from the first one)
  mov [GameMode], 1
	call ShowChoosingArrows
;region
WaitForChoice: ;Collects user's input

	in al, 64h ;Read keyboard status port
	cmp al, 10b ;Data in buffer ?
	je WaitForChoice ;Wait until data available

	in al, 60h ;Get keyboard data

	cmp al, 1Ch ;Is it the Enter key ?
	je Choice

	cmp al, 11h ;W key
	je UpChoice

	cmp al, 1Fh ; S key
	je DownChoice

	cmp al, 1h ;ESC
	jne WaitForChoice

  mov [GameMode], 4
	mov bl,4
	jmp Choice
;endregion
DownChoice:
  call ChangeChoiceDown
  inc [GameMode]
	jmp WaitForChoice


UpChoice:
  call ChangeChoiceUp
  dec [GameMode]
	jmp WaitForChoice

Choice:
	ret
endp MainMenu

proc ChangeChoiceDown
;Move indicators one button up. but,
;Check if already on the last button

  cmp bl, 3
  je WaitForChoice
  ;Clean last one


  cmp bl,1
  je ClearOne

  ;Change button 2
  mov [BmpTop], 120
  mov dx, offset Btn2
  call OpenShowBmp

  jmp ChangeDown
ClearOne:
  ;Change button 1
  mov [BmpTop], 100
  mov dx, offset Btn1
  call OpenShowBmp

ChangeDown:
  inc bl
  call Timer
  call ShowChoosingArrows
  ret
endp ChangeChoiceDown

proc ChangeChoiceUp
    ;Move indicators one button up. but,
    ;Check if already on the top option

  cmp bl, 1
  je WaitForChoice

  cmp bl,3
  je ClearThree

  ;Change button 2
  mov [BmpTop], 120
  mov dx, offset Btn2
  call OpenShowBmp
  jmp ChangeUp
  ClearThree:
  ;Change button 3
  mov [BmpTop], 140
  mov dx, offset Btn3
  call OpenShowBmp
  ChangeUp:
  dec bl
  call Timer
  call ShowChoosingArrows

  ret
endp ChangeChoiceUp

proc ShowChoosingArrows
    ;Display indicators to the buttons in the main menu
	mov [BmpLeft], 120

	cmp bl, 1
	je FirstButton

	cmp bl, 2
	je SecondButton

	cmp bl, 3
	je ThirdButton

	jmp Indicated
ThirdButton:
	mov [BmpTop],140
	mov dx ,offset SelectedBtn3
	call OpenShowBmp
	jmp Indicated
FirstButton:
	mov [BmpTop],100
	mov dx ,offset SelectedBtn1
	call OpenShowBmp
	jmp Indicated
SecondButton:
	mov [BmpTop],120
	mov dx ,offset SelectedBtn2
	call OpenShowBmp

Indicated:

	ret
endp ShowChoosingArrows


proc StartCountdown
    ;INPUT - X
    ;OUTPUT- X
    ;Info - This procedure displays 3 pictures of numbers (3,2,1)
    ; and simultaneously makes a sound at every picture
    call FindColors
	mov [ticks], 6
	mov [BmpTop], 50
	mov [BmpLeft], 120
	mov [BmpColSize], 60
	mov [BmpRowSize], 81

	mov ax, [highnote1] ;Low Do note
	mov [note],ax

	mov cx, 4 ; We need 4 sounds
beep:
	cmp cx,1
	je lastnote ;we need that last note to be higher
	cmp cx, 4
	je print3
	cmp cx, 3
	je print2
print1:
	mov dx, offset number1
	jmp MakeASound
print2:
	mov dx, offset number2
	jmp MakeASound
print3:
	mov dx, offset number3
MakeASound:
	call OpenShowBmp
	call sound
	call Timer
	loop beep

lastnote:
	mov [BmpColSize], 80
	mov [BmpRowSize], 61
	mov dx, offset go
	call OpenShowBmp
	mov ax, [note1] ;DO Note
	mov [note],ax
	call Sound

	mov [BmpColSize], 80
	mov [BmpRowSize], 81
	mov dx, offset CDB
	call OpenShowBmp
	;Clear Background

	ret
endp StartCountdown

proc sound
    ;INPUT - Procedure recieves [note] which contains a frequency of a note
    ;OUTPUT- Sound throught computer's speaker
    ;Info - Procedure sets up the speaker, sends frequency to
    ; port 42h and stops sound when timer ends by resetting bits 1 and
    ; 0 of port 61h to 0 (proc sound close)
	push ax bx cx dx
	mov bp, sp
	in al, 61h
	or al, 00000011b
	out 61h, al 	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	mov ax, [note]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al ; Sending upper byte
	call Timer
	call soundclose
	pop dx cx bx ax ;'BYPASS_POP_MATCH'
	ret
endp sound
proc soundclose ;soundclose
	in al, 61h
	and al, 11111100b
	out 61h, al
	ret
endp soundclose

proc Timer ;TIMER WITH [ticks] TICKS
;INPUT - Procedure recieves amount of ticks throught [ticks].
;Info - Procedure enables timer and check when the amount of ticks
; that was requestes has ended.
	push ax bx cx dx
	mov ax,40h ;enable Timer
	mov es,ax
	mov ax, [clock]
FirstTick:
	cmp ax, [clock]
	mov cx, [ticks] ;ticks
	je FirstTick
DelayLoop:
	mov ax, [clock]
Tick:
	cmp ax, [clock]
	je Tick
	loop DelayLoop
	pop dx cx bx ax ;'BYPASS_POP_MATCH'
	ret
endp Timer

proc EnemiesFire1

  cmp [Time], 0
  je Enemy3Shoot
  jmp Skip


Enemy3Shoot:

    cmp [EnemiesAlive+2], 1 ;Check if tank 3 is alive
    jne Enemy1Shoot

    mov [StartX],175
    mov [StartY],155
    mov [XJump], -3
    mov [YJump], 0
    mov [Collision], 2
    call SetArray

Enemy1Shoot:
    cmp [EnemiesAlive], 1 ;Check if tank 1 is alive
    jne Enemy2Shoot

    mov [StartX],269
    mov [StartY],120
    mov [XJump],3
    mov [YJump],-3
    mov [Collision], 0
    call SetArray

Enemy2Shoot:
    cmp [EnemiesAlive+1], 1
    jne ShotsFired
    mov [StartX],109
    mov [StartY],60
    mov [XJump],0
    mov [YJump],3
    mov [Collision], 2
    call SetArray

ShotsFired:
    mov [Time], 75
Skip:
  ret
endp EnemiesFire1

proc EnemiesFire2

  cmp [Time], 0
  je Enemy6Shoot
  jmp Skip2

Enemy6Shoot:

    cmp [EnemiesAlive+2], 1 ;Check if tank 6 is alive
    jne Enemy4Shoot
    mov [StartX],255
    mov [StartY],157
    mov [XJump], -3
    mov [YJump], 0
    mov [Collision], 2
    call SetArray

Enemy4Shoot:
    cmp [EnemiesAlive], 1 ;Check if tank 4 is alive
    jne Enemy5Shoot

    mov [StartX],255
    mov [StartY],35
    mov [XJump],-3
    mov [YJump],-3
    mov [Collision], -6
    call SetArray

Enemy5Shoot:
    cmp [EnemiesAlive+1], 1
    jne ShotsFired2
    mov [StartX],173
    mov [StartY],78
    mov [XJump],-3
    mov [YJump],3
    mov [Collision], -1
    call SetArray


ShotsFired2:
    mov [Time], 75
Skip2:
  ret
endp EnemiesFire2

proc EnemiesAttack
    ;Check in what map the enemies should fire
    cmp [Level], 1
    jne CheckLevel2
    call EnemiesFire1
    jmp EndOfAttack
CheckLevel2:
    cmp [Level], 2
    jne CheckLevel3
    call EnemiesFire2
    jmp EndOfAttack
CheckLevel3:
    call EnemiesFire3
EndOfAttack:
    ret
endp EnemiesAttack

proc EnemiesFire3
    ;Enemies rockets on third map
    cmp [Time], 0 ;Check if its time to shoot
    je Enemy9Shoot
    jmp Skip3

Enemy9Shoot:

  cmp [EnemiesAlive+2], 1 ;Check if tank 9 is alive
  jne Enemy7Shoot
  mov [StartX],247
  mov [StartY],33
  mov [XJump], -3
  mov [YJump], -3
  mov [Collision], -1
  call SetArray

Enemy7Shoot:
  cmp [EnemiesAlive], 1 ;Check if tank 7 is alive
  jne Enemy8Shoot

  mov [StartX],35
  mov [StartY],91
  mov [XJump],0
  mov [YJump],3
  mov [Collision], 2
  call SetArray

Enemy8Shoot:
  cmp [EnemiesAlive+1], 1
  jne ShotsFired3
  mov [StartX],283
  mov [StartY],73
  mov [XJump],3
  mov [YJump],3
  mov [Collision], -1
  call SetArray


ShotsFired3:
  mov [Time], 75
Skip3:
  ret
endp EnemiesFire3
proc SingleGame
;Info - Main procedure that ends with the press of the key ESC
    pop [MainReturnAddress] ;We need to save the return address of 'SingleGame'
    ;Variable reset and set
    mov [BmpColSize], 16 ;The picture properties of users tank (in all maps)
    mov [BmpRowSize] , 24
    mov [ticks], 1 ;The timer which slows down the game
    mov [rocket],0 ; Current active rockets
    mov [Hit], 0 ; User's tank is active
    mov [AllDead], 0 ; All enemies are active
    mov [Enemies], 3 ;3 enemies are active on the map
    mov [Time], 30 ; Time between every shot of the enemies

GameLoop:
WaitForData: ;Collects user's input
    mov [ticks], 1
    call Timer
    dec [Time]

    call EnemiesAttack


    call CheckOnMissiles ;Moves Missiles and returns 'Hit'(if my tank got hit) and 'AllDead'(if all enemies are dead)
    cmp [Hit], 1
    je TimeOut
    cmp [AllDead], 1
    jne ContinueReading
TimeOut:
    jmp GoOut
ContinueReading:
	in al, 64h ;Read keyboard status port
	cmp al, 10b ;Data in buffer ?

	je WaitForData ;Wait until data available
	in al, 60h ;Get keyboard data
    dec [Time]
    call EnemiesAttack
    call CheckOnMissiles
	cmp al, 11h ;W key
	je WKey

	cmp al, 1Fh ; S key
	je Skey


	cmp al, 1Eh ; A key
	je AKey

	cmp al, 39h ; Spacebar
	je Spacebar ;special for mouse

	cmp al, 20h ;D key
	jne NotD
	jmp Dkey

NotD:
	cmp al, 1h ;Is it the ESC key ?
	jne WaitForData
	jmp EscapePresssed

;HerzBg/VertBg- horizontal/vertical background to switch the previous tank picture
Spacebar:
	;call Aim ;Mouse Use
  cmp [lastshot],1
  je  WaitForData
  mov [lastshot],1
  call Shoot
	jmp WaitForData

Skey:
  mov [lastshot],0
	call Down
	jmp WaitForData

WKey:
  mov [lastshot],0
	call Up
	jmp WaitForData

AKey:
  mov [lastshot],0
	call Left
	jmp WaitForData

DKey:
    mov [lastshot],0
	call Right
	jmp WaitForData

EscapePresssed:
  mov [lastshot],0
    jmp StartOfAll
GoOut:
    push [MainReturnAddress]
	ret
endp SingleGame


proc Shoot
;Info:
;-Find from where the shot should start
;-Find movement properties
;-We should have an array that contains each rocket's cordinates
  cmp [Look], 1
  je ShootRight

  cmp [Look], 2
  je ShootLeft

  cmp [Look], 3
  je ShootUp

  cmp [Look], 4
  je ShootDown

ShootRight:
    mov ax, [BmpLeft]
    add ax, 28
    mov [StartX], ax

    mov ax, [BmpTop]
    add ax, 5
    mov [StartY], ax

    mov [XJump], 3
    mov [YJump], 0
    jmp StartSet
ShootLeft:
    mov ax, [BmpLeft]
    sub ax, 4
    mov [StartX], ax

    mov ax, [BmpTop]
    add ax, 6
    mov [StartY], ax

    mov [XJump], -3
    mov [YJump], 0
    jmp StartSet
ShootUp:
    mov ax, [BmpLeft]
    add ax, 6
    mov [StartX], ax

    mov ax, [BmpTop]
    sub ax, 4
    mov [StartY], ax

    mov [XJump], 0
    mov [YJump], 3
    jmp StartSet
ShootDown:
    mov ax, [BmpLeft]
    add ax, 6
    mov [StartX], ax

    mov ax, [BmpTop]
    add ax, 26
    mov [StartY], ax

    mov [XJump], 0
    mov [YJump], -3

StartSet:
  ; call Calculations
  mov [Collision], 0
  call SetArray


  ret
endp Shoot
proc SetArray
  ;First we need what number of rocket we need to define
  ;Then enter to the same index in all arrays the information
  xor ax, ax
  mov bx, [rocket]
  mov al ,2
  mul bx

  inc [rocket]
  mov bx, ax
  mov ax, [StartX]
  mov [MissilesX +bx], ax

  mov ax, [StartY]
  mov [MissilesY +bx], ax

  mov ax, [XJump]
  mov [MissilesXJump +bx], ax

  mov ax, [YJump]
  mov [MissilesYJump +bx], ax

  mov ax, [Collision]
  mov [Collisions +bx], ax


  ret
endp SetArray
proc FindColors
;My Color
    mov ax, 35
    inc ax
    mov [xCheck], ax
    mov ax, 40
    inc ax
    mov [yCheck], ax
    mov ah,0Dh
	mov cx,[xCheck]
	mov dx,[yCheck]
	int 10h ; AL = COLOR
	mov [MyTank], al
;Enemy Color
    mov ax, 260 ;BmpLeft
    add ax, 3
    mov [xCheck], ax
    mov ax, 140 ;BmpTopt
    add ax, 13
    mov [yCheck], ax
    mov ah,0Dh
	mov cx,[xCheck]
	mov dx,[yCheck]
	int 10h ; AL = COLOR
	mov [EnemyTank], al
    ret
endp FindColors

proc CheckOnMissiles
; If there are active missiles, move them by collecting
; their info from the arrays
  pop [ReturnAddress]
  push [BmpLeft] ;'IGNORE_LINE'
  push [BmpTop];'IGNORE_LINE'
  push [BmpColSize];'IGNORE_LINE'
  push [BmpRowSize];'IGNORE_LINE'
  push ax bx cx dx

  cmp [rocket], 0
  je NoRockets
  mov cx, [rocket]
OneMissile:
  mov bx, cx ;Create copy
  push cx

  ;This section sets bx to be an indexer
  xor ax, ax
  mov al, 2
  dec bx ;For index
  mul bx
  mov bx, ax

  cmp [Collisions +bx], 3 ;If current index rocket already hit 3 walls, dont display it
  je TooManyCollisions

  mov dx, [MissilesX + bx]
  mov [BmpLeft], dx ;BmpLeft
  mov dx, [MissilesY + bx]
  mov [BmpTop], dx ;BmpTops
  mov dx, [MissilesXJump + bx]
  mov [XJump], dx ;XJump
  mov dx, [MissilesYJump + bx]
  mov [YJump], dx;YJump
  call PrintMissile
  ;After 'PrintMissile' we might have been hit or won
  cmp [Hit], 1
  je NoRockets
  cmp [AllDead], 1
  je NoRockets
TooManyCollisions:
  pop cx
  loop OneMissile

NoRockets:
    pop dx cx bx ax
    pop [BmpRowSize]
    pop [BmpColSize]
    pop [BmpTop]
    pop [BmpLeft]
    push [ReturnAddress]
    ret
endp CheckOnMissiles

proc PrintMissile
  ;First we need to erase last location
  ;And check next one
  ;Then print a new missile after x/y jump which can be changed in the last check
  mov [BmpColSize], 4
  mov [BmpRowSize], 3
  mov dx, offset MissileClean
  call OpenShowBmp

  call CheckNextPrint
  cmp [Hit], 1
  je OnlyClean
  cmp [Collisions +bx], 3
  je OnlyClean

  mov cx, [XJump]
  add [BmpLeft], cx ;New BmpLeft
  mov cx, [YJump]
  add [BmpTop], cx ;New BmpTop



  mov dx, offset Missile
  call OpenShowBmp

  mov ax, [BmpLeft]
  mov [MissilesX +bx], ax
  mov ax, [BmpTop]
  mov [MissilesY +bx], ax
  mov ax, [XJump]
  mov [MissilesXJump+bx], ax
  mov ax, [yJump]
  mov [MissilesYJump+bx], ax

OnlyClean:

  ret
endp PrintMissile
proc CheckNextPrint
    ;We need to check all sides like ('CheckPixelRow')
    ;If not red put a negative on the correct jump variable (it hit an object which is not user or enemy)
    ;If color of my tank, set variable 'Hit'=1
    ;If color of an enemy tank, remove the enemy from the map

    mov [Hit], 0
    mov [AllDead], 0
    ;Check Above row
    mov ax, [BmpTop]
    sub ax, 3
    mov [yCheck], ax

    mov ax, [BmpLeft]
    inc ax
    mov [xCheck], ax

    mov ah,0Dh
	mov cx,[xCheck]
	mov dx,[yCheck]
	int 10h ; AL = COLOR
    cmp al, [EnemyTank]
    je YesHitEnemy
    cmp al, [MyTank]
    je YesHitMe
	cmp al, [red]
    je Below
    inc [Collisions+ bx]
    neg [YJump]
    jmp ChangedDirection

YesHitEnemy:
    jmp HitEnemyTank
YesHitMe:
    jmp HitMyTank

Below:
    add [yCheck], 9
    mov ah,0Dh
	mov cx,[xCheck]
	mov dx,[yCheck]
	int 10h ; AL = COLOR
    cmp al, [EnemyTank]
    je YesHitEnemy
    cmp al, [MyTank]
    je YesHitMe
	cmp al, [red]
    je Lefter
    inc [Collisions+ bx]
    neg [YJump]
    jmp ChangedDirection

Lefter:
    sub [yCheck], 5
    sub [xCheck], 4
    mov ah,0Dh
	mov cx,[xCheck]
	mov dx,[yCheck]
	int 10h ; AL = COLOR
    cmp al, [EnemyTank]
    je HitEnemyTank
    cmp al, [MyTank]
    je HitMyTank
	cmp al, [red]
    je Righter
    inc [Collisions+ bx]
    neg [XJump]
    jmp ChangedDirection

Righter:
    add [xCheck], 9
    mov ah,0Dh
	mov cx,[xCheck]
	mov dx,[yCheck]
	int 10h ; AL = COLOR
    cmp al, [EnemyTank]
    je HitEnemyTank
    cmp al, [MyTank]
    je HitMyTank
	cmp al, [red]
    je ChangedDirection
    inc [Collisions+ bx]
    neg [XJump]
    jmp ChangedDirection

HitEnemyTank:
    dec [Enemies]
    call KillEnemy
    mov [Collisions +bx], 3
    cmp [Enemies], 0
    jne ChangedDirection
    mov [AllDead], 1
    pop [Trash]
    jmp GoOut
    ;jmp ChangedDirection
HitMyTank:
    mov [Hit], 1
ChangedDirection:
    ret
endp CheckNextPrint

proc KillEnemy
    ;We need to see in what map the enemy tank was hit
    push [BmpLeft]
    push [BmpTop]
    push [BmpColSize]
    push [BmpRowSize]

    cmp [Level], 1
    jne CheckEnemeies2
    call KillEnemiesOnFirstMap
    jmp Killed
CheckEnemeies2:
    cmp [Level], 2
    jne CheckEnemeies3
    call KillEnemiesOnSecondMap
    jmp Killed
CheckEnemeies3:
    call KillEnemiesOnThirdMap

Killed:
    pop [BmpRowSize]
    pop [BmpColSize]
    pop [BmpTop]
    pop [BmpLeft]

    ret
endp KillEnemy

proc KillEnemiesOnThirdMap
    ;Displays an explosion on the tank that was hit, cleans its location and removes him from alive enemies.
    cmp [xCheck], 47
    ja CheckTank8
    ;If its here, it hit tank 7
    mov [EnemiesAlive],0
    mov [BmpLeft], 30
    mov [BmpTop], 66
    mov [BmpColSize], 16
    mov [BmpRowSize] , 24
    mov dx, offset Explosion
    call OpenShowBmp
    call Timer ;show explosion
    mov dx, offset VertBg
    call OpenShowBmp
    jmp KilledOnThird
CheckTank8:
    cmp [yCheck], 48
    jb ItsTank9
    ;It hit tank 8
    mov [EnemiesAlive+1],0
    mov [BmpLeft], 278
    mov [BmpTop], 48
    mov [BmpColSize], 16
    mov [BmpRowSize] , 24
    mov dx, offset Explosion
    call OpenShowBmp
    mov [ticks], 8
    call Timer ;show explosion
    mov [ticks], 1
    mov dx, offset VertBg
    call OpenShowBmp
    jmp KilledOnThird
ItsTank9:
    mov [EnemiesAlive+2],0
    mov [BmpLeft], 252
    mov [BmpTop], 28
    mov [BmpColSize], 24
    mov [BmpRowSize] , 17
    mov dx, offset HorzExplosion
    call OpenShowBmp
    call Timer ;show explosion
    mov dx, offset HorzBg
    call OpenShowBmp
KilledOnThird:
ret
endp KillEnemiesOnThirdMap

proc KillEnemiesOnSecondMap
    ;Displays an explosion on the tank that was hit, cleans its location and removes him from alive enemies.
    mov [BmpColSize], 24
    mov [BmpRowSize] , 17

    cmp [yCheck], 153
    jb CheckTank5
    ;If its here, it hit tank 6
    mov [EnemiesAlive+2],0
    mov [BmpLeft], 260
    mov [BmpTop], 152
    mov dx, offset HorzExplosion
    call OpenShowBmp
    call Timer ;show explosion
    mov dx, offset HorzBg
    call OpenShowBmp
    jmp KilledOnSecond
CheckTank5:
    cmp [yCheck], 74
    jb ItsTank4
    ;It hit tank 5
    mov [EnemiesAlive+1],0
    mov [BmpLeft], 178
    mov [BmpTop], 73
    mov dx, offset HorzExplosion
    call OpenShowBmp
    call Timer ;show explosion
    mov dx, offset HorzBg
    call OpenShowBmp
    jmp KilledOnSecond
ItsTank4:
    mov [EnemiesAlive],0
    mov [BmpLeft], 260
    mov [BmpTop], 30
    mov dx, offset HorzExplosion
    call OpenShowBmp
    mov [ticks], 8
    call Timer ;show explosion
    mov [ticks], 1
    mov dx, offset HorzBg
    call OpenShowBmp
KilledOnSecond:
    ret
endp KillEnemiesOnSecondMap

proc KillEnemiesOnFirstMap
    ;Displays an explosion on the tank that was hit, cleans its location and removes him from alive enemies.
    cmp [xCheck], 117
    ja CheckTank3
    ;If its here, it hit tank 2
    mov [EnemiesAlive+1],0
    mov [BmpLeft], 100
    mov [BmpTop], 30
    mov [BmpColSize], 16
    mov [BmpRowSize] , 24
    mov dx, offset Explosion
    call OpenShowBmp
    call Timer ;show explosion
    mov dx, offset VertBg
    call OpenShowBmp
    jmp KilledOnFirst
CheckTank3:
    cmp [xCheck], 205
    ja ItsTank1
    mov [EnemiesAlive+2],0
    mov [BmpLeft], 180
    mov [BmpTop], 150
    mov [BmpColSize], 24
    mov [BmpRowSize] , 17
    mov dx, offset HorzExplosion
    call OpenShowBmp
    call Timer ;show explosion
    mov dx, offset HorzBg
    call OpenShowBmp
    jmp KilledOnFirst
ItsTank1:
    mov [EnemiesAlive],0
    mov [BmpLeft], 260
    mov [BmpTop], 140
    mov [BmpColSize], 16
    mov [BmpRowSize] , 24
    mov dx, offset Explosion
    call OpenShowBmp
    mov [ticks], 8
    call Timer ;show explosion
    mov [ticks], 1
    mov dx, offset VertBg
    call OpenShowBmp
KilledOnFirst:
    ret
endp KillEnemiesOnFirstMap

proc Right
;OUTPUT- Picture desplay and removal of the previous picture
;Info - Procedure for when user presses 'D' Key

  mov dx, offset TankRight

GoRight:
	;In this sectoin i check the next right movement of the tank and if theres an object
	mov ax, [BmpLeft]
	add ax, 25
	mov [xCheck],  ax

	mov ax, [BmpTop]
	mov [yCheck], ax
	mov [VHrow], 0
	call CheckPixelRow

	cmp [object], 1
	je DontMoveRight

	call Clean

	;Print Next position
    add [BmpLeft], 3

	mov [BmpColSize], 24 ;Horizontal
	mov [BmpRowSize] , 16
	call OpenShowBmp
    mov [Look], 1
DontMoveRight:
	ret
endp Right



proc Left
;OUTPUT- Picture desplay and removal of the previous picture
;Info - Procedure for when user presses 'A' Key
	;Check left side of the picture
  ; call EnemiesFire

  mov dx, offset TankLeft


GoLeft:
    ;In this sectoin i check the next left movement of the tank and if theres an object
	mov ax, [BmpLeft]
	dec ax
	mov [xCheck],  ax

	mov ax, [BmpTop]
	mov [yCheck], ax
	mov [VHrow], 0
	call CheckPixelRow

	cmp [object], 1
	je DontMoveLeft


	call Clean
	;call delay
	sub [BmpLeft], 3 ;Move object one pixel to the right

	mov [BmpColSize], 24 ;Horizontal
	mov [BmpRowSize] , 16
	call OpenShowBmp
    mov [Look], 2

DontMoveLeft:
	;call OpenShowBmp
	ret
endp Left

proc Up
;OUTPUT- Picture desplay and removal of the previous picture
;Info - Procedure for when user presses 'W' Key
  ; call EnemiesFire

  mov dx, offset TankUp

GoUp:
	;In this sectoin i check the next upper movement of the tank and if theres an object
	mov ax, [BmpLeft]
	mov [xCheck],  ax

	mov ax, [BmpTop]
	dec ax
	mov [yCheck], ax
	mov [VHrow], 1
	call CheckPixelRow


	cmp [object], 1
	je DontMoveUp

	call Clean
	;call delay
	sub [BmpTop], 3
	mov [BmpColSize], 16 ;Vertical
	mov [BmpRowSize] , 24
	call OpenShowBmp ;print
    mov [Look], 3

DontMoveUp:

	ret
endp Up

proc Down
;OUTPUT- Picture desplay and removal of the previous picture
;Info - Procedure for when user presses 'S' Key
	;Check under the picture
  ; call EnemiesFire
  mov dx, offset TankDown
GoDown:
    ;In this sectoin i check the next down movement of the tank and if theres an object
	mov ax, [BmpLeft]
	mov [xCheck],  ax

	mov ax, [BmpTop]
	add ax, 25
	mov [yCheck], ax
	mov [VHrow], 1
	call CheckPixelRow

	cmp [object], 1
	je DontMoveDown

	call Clean
	;call delay

	add [BmpTop], 3 ;move object 1 pixel down

	mov [BmpColSize], 16 ;Vertical
	mov [BmpRowSize] , 24
	call OpenShowBmp
    mov [Look], 4

DontMoveDown:
	ret
endp Down

proc Clean
    push dx
    push ax
	cmp [BmpColSize], 16
	je VerticalTank
	cmp [BmpColSize], 24
	je HorizontalTank
HorizontalTank:
	mov dx, offset HorzBg
	call OpenShowBmp
	jmp EndOfClean
VerticalTank:
	mov dx, offset VertBg
	call OpenShowBmp
EndOfClean:
    pop ax
    pop dx
	ret
endp Clean

proc CheckPixelRow
;INPUT - collects 'xCheck' and 'yCheck' which represents
; the boundries of the picture. And [VHrow] which represents
; what kind of row we need to check.
;OUTPUT- Procedure returns [object] which contains 1 if the
; boundries of the picture are touching an obstacle on the map
;Info - Check vertical or horizontal row of pixels with loops.
    push dx
	mov [object], 0 ;Reset
	mov cx, 16
	cmp [VHrow], 1
	je VerticalRow
	;Horizontal Row
HorizontalRow:
	push cx
	mov ah,0Dh
	mov cx,[xCheck]
	mov dx,[yCheck]
	int 10h ; AL = COLOR
	cmp al, [red]
	je valid1 ; If there is an object in the way
	mov [object], 1
valid1:
	inc [yCheck]
	pop cx
	loop HorizontalRow

	jmp EndCheck
VerticalRow:
	push cx
	mov ah,0Dh
	mov cx,[xCheck]
	mov dx,[yCheck]
	int 10h ; AL = COLOR
	cmp al, [red]
	je valid2 ; If there is an object in the way
	mov [object], 1
valid2:
	inc [xCheck]
	pop cx
	loop VerticalRow

EndCheck:
  pop dx
	ret
endp CheckPixelRow
; input :
;	1.BmpLeft offset from left (where to start draw the picture)
;	2. BmpTop offset from top
;	3. BmpColSize picture width ,
;	4. BmpRowSize bmp height
;	5. dx offset to file name with zero at the end

;INPUT - 4 Picture properties:
;'[BmpTop]' and '[BmpLeft]' for picture's left upper corner
;'[BmpColSize]' and '[BmpRowSize]' for picture's size
;OUTPUT- Picture on the display
;Info - Procedure by the book
proc OpenShowBmp near

	push cx
	push bx


	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc

	call ReadBmpHeader
	; from  here assume bx is global param with file handle.
	call ReadBmpPalette
	call CopyBmpPalette
	call ShowBMP
	call CloseBmpFile

@@ExitProc:
	pop bx
	pop cx
	ret
endp OpenShowBmp

; input dx filename to open
proc OpenBmpFile	near
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc

@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:
	ret
endp OpenBmpFile

proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile

; Read 54 bytes the Header
proc ReadBmpHeader	near
	push cx
	push dx

	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h

	pop dx
	pop cx
	ret
endp ReadBmpHeader

proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)					 ; 4 bytes for each color BGR + null)
	push cx
	push dx

	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h

	pop dx
	pop cx

	ret
endp ReadBmpPalette

; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near
	push cx
	push dx

	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).
	out dx,al
	mov al,[si+1] 		; Green.
	shr al,2
	out dx,al
	mov al,[si] 		; Blue.
	shr al,2
	out dx,al
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)

	loop CopyNextColor

	pop dx
	pop cx

	ret
endp CopyBmpPalette

proc ShowBMP
;BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx

	mov ax, 0A000h
	mov es, ax

	mov cx,[BmpRowSize]

	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	mov bp,dx

	mov dx,[BmpLeft]

@@NextLine:
	push cx
	push dx

	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen


	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx

	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScreenLineMax
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]
	mov si,offset ScreenLineMax
	rep movsb ; Copy line to the screen

	pop dx
	pop cx

	loop @@NextLine

	pop cx
	ret
endp ShowBMP


proc  SetGraphic
	mov ax,13h   ; 320 X 200
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode
	int 10h
	ret
endp 	SetGraphic

start:
    mov ax, @data
    mov ds, ax

    call SetGraphic ;Set Grapihcs mode
StartOfAll:
    ;reset arrays
    mov [ticks], 6 ;Set the speed of the switch between menu buttons
    call MainMenu ;Returns [GameMode], with the mode the user chose
    cmp [GameMode], 1
    je FirstMap ;Button 'Start'
    cmp [GameMode], 2
    jne CheckMode3 ;Button 'Maps'
    jmp Maps
CheckMode3:
    cmp [GameMode], 3
    jne WantsOut ;User pressed 'ESC'
    jmp Tutorial ;Button 'Tutorial'
WantsOut:
    jmp escape

FirstMap:
    call EmptyArrays ;Procedure called every map to clean the arrays of the missiles
    mov [Level], 1
	call SetFirstMap ;Sets First map background, Enemies and user's tank first position
	call StartCountdown ;Starts a visual countdown with sound
	mov [BmpLeft],35 ;Location of the first tank
	mov [BmpTop],40
	call SingleGame ;Main Game loop which works dependently on keyboard input
    mov ah,08h
    int 21h
    cmp [Hit], 1 ;Check if 'SingleGame' enden because user got hit
    jne Transition1
	jmp Lost
Transition1:
    call MapTransition ;'Level Completed screen between maps'

SecondMap:
    call EmptyArrays ;clean the arrays of the missiles
    mov [Level], 2
	call SetSecondMap
	call StartSecondCountdown
	call SingleGame
    mov ah,08h
    int 21h
	cmp [Hit], 1
	jne Transition2
    jmp Lost
Transition2:
    call MapTransition
ThirdMap:
    call EmptyArrays
    mov [Level], 3
	call SetThirdMap
	call StartSecondCountdown
	call SingleGame
    mov ah,08h
    int 21h
	cmp [Hit], 1
	jne Complete
Lost: ;This label represents the death of the user
    call GameOverScreen ;Simple picture representation
    mov [ticks], 50 ;Amount of time to display the game over screen
    call Timer
    jmp StartOfAll ;Go back to main menu

Complete:
	call CompleteScreen ;Simple picture representation
	mov [ticks], 60 ;Amount of time to display the Congrats Screen
	call Timer
	jmp StartOfAll

Maps:

    call MapsChoice ;procedure which either jumps to a certain map or returns back to main menu
    jmp StartOfAll

Tutorial:
    call TutorialScreen ;Procedure which displays rules and goes back to main menu
    jmp StartOfAll


escape:
	; mov ah,0
	; int 16h

	mov ax,2 ;Set Cursor position
	int 10h

    mov ax, 4c00h
	int 21h
END start
