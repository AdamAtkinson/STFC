
; _____________________________________________________________________________________________
; =============================================================================================
; Runs On Load
; . .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .

    #NoEnv
    #Warn
    CoordMode, Mouse, Client
    SetDefaultMouseSpeed, 1
    ; SetMouseDelay, 5
    Global gDockCount := 5
    Global gCurrentDock := 1
    Global gDockSpacer := 75
    Return

; _____________________________________________________________________________________________
; =============================================================================================
; Match User Action to Desired UI Action
; . .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .

    TranslateUserAction(userAction) {
        ;Right Mouse Actions
        If (userAction="1x-R-click")
            SelectCurrentDock()
        If (userAction="1x-R-click-hold")
            ClickReturnToBase()
        If (userAction="2x-R-click")
            ClickMoveShip()
        If (userAction="2x-R-click-hold")
            ClickAttackTarget()
        If (userAction="3x-R-click")
            SelectNextDock() 
        If (userAction="3x-R-click-hold")
            SelectPreviousDock()
        If (userAction="4x-R-click")
            ClickRepairShip()
        If (userAction="4x-R-click-hold")
            ClickManageShip()

        ;Middle Mouse Actions
        If (userAction="1x-M-click")
            ClickToggleGalaxyMap()  
        If (userAction="1x-M-click-hold")
            ClickReturnToPreviousScreen()    
        If (userAction="2x-M-click")
            ClickClosePlayerProfile()
    }
    
; _____________________________________________________________________________________________
; =============================================================================================
; manually mapped screen coords - sends MAGIC NUMBERS to automation handler
; . .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .

    ClickMoveShip() {
        MouseGetPos, x, y
        SendClicks(x, y)
        sleep 200
        SendClicks(x+60, y-60)
    }

    ClickDock(px) {
        SendClicks(800+px,1000)
    }

    ClickScanTarget() {
        SendClicks(1100, 660)
    }
    ClickRepairShip() {
        SendClicks(30, 1000)
    }
    ClickManageShip() {
        SendClicks(30, 940)
    }
    ClickReturnToBase() {
        SendClicks(30, 1030)
    }
    ClickAttackTarget() {
        SendClicks(1200, 660)
    }

    ClickToggleGalaxyMap() {
        SendClicks(1850, 1000)
    }
    ClickToggleViewBase() {
        SendClicks(1810, 1010)
    }

    ClickClosePlayerProfile() {
        SendClicks(901, 236)
    }
    ClickReturnToPreviousScreen() {
        SendClicks(40, 65)
    }

; _____________________________________________________________________________________________
; =============================================================================================
; automation handler
; . .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .

    SendClicks(x := 0, y := 0) {
        MouseGetPos xPrev,yPrev
        If (x = 0) and (y = 0)
        {
            x := xPrev
            y := yPrev
        }
        Sleep, 120
        BlockInput SendAndMouse
        Click  %x%, %y% down Left 
        Sleep, 350
        BlockInput SendAndMouse
        Click  %x%, %y% up Left 
        ; Sleep, 20
        MouseMove, xPrev,yPrev
    }

; _____________________________________________________________________________________________
; =============================================================================================
; maths & logic - automation preparcing
; . .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .

    SelectNextDock() {
        gCurrentDock := gCurrentDock = gDockCount ? 1 : gCurrentDock+1
        SelectCurrentDock()
    }

    SelectPreviousDock() {
        gCurrentDock := gCurrentDock = 1 ? gDockCount : gCurrentDock-1
        SelectCurrentDock()
    }
    
    SelectCurrentDock() {
        ClickDock(gDockSpacer*(gCurrentDock-1))
    }

    CenterCursorOnScreen() {
        WinGetActiveStats, Title, Width, Height, X, Y
    MouseMove, %Width%/2, %Height%/2
    }

; _____________________________________________________________________________________________
; =============================================================================================
; hotkeys - evaluates & redirects user input to mapped screen coordinates / maths & logic
;           HOTKEYS HAVE GLOBAL SCOPE - any variable they touch will be GLOBAL
; . .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .. .

RButton:: ; RButton is clicked, begin STFC RButton evaluation
    WinGetClass, class, A  ; get the active window class
    If (class="UnityWndClass") ; STFC window is active, continue evaluating 
    {
        KeyWait, RButton, t0.3 ;  wait for (R-click) release
        If ErrorLevel = 1 ; RButton was not released, is a (long-R-click)
            TranslateUserAction("1x-R-click-hold")
        Else ; RButton was released, continue evaluating 
        {
            KeyWait, RButton, d, t0.3 ; wait f0r 2x R-click
            If ErrorLevel = 0 ; RButton was pushed down 2x, continue evaluating 
            {
                KeyWait, RButton, t0.3 ; wait for (double-R-click) release
                If ErrorLevel = 1 ; RButton was not released, is a (double-R-click-hold)
                    TranslateUserAction("2x-R-click-hold")
                else ; RButton was released, continue evaluating 
                {
                    KeyWait, RButton, d, t0.3 ; wait for 3x R-click
                    If ErrorLevel = 0 ; RButton was pushed down 3x, continue evaluating 
                    {
                        KeyWait, RButton, t0.5 ;  wait for (triple-R-click) release
                        If ErrorLevel = 1 ; RButton was not released, is a (triple-R-click-hold)
                            TranslateUserAction("3x-R-click-hold")
                        else ; RButton was released, continue evaluating 
                        {
                            KeyWait, RButton, d, t0.3 ; wait for 4x R-click
                            If ErrorLevel = 0 ; RButton was pushed down 4x, continue evaluating 
                            {
                                KeyWait, RButton, t0.5 ;  wait for (quadruple-R-click) release
                                If ErrorLevel = 1 ; RButton was not released, is a (quadruple-R-click-hold)
                                    TranslateUserAction("4x-R-click-hold")
                                else ; RButton was released, is a (quadruple-R-click)
                                    TranslateUserAction("4x-R-click")
                            }
                            else ; RButton was not pushed down 4x, is a (triple-R-click)
                                TranslateUserAction("3x-R-click")
                        }
                    }
                    else ; RButton was not pushed down 3x, is a (double-R-click)
                        TranslateUserAction("2x-R-click")
                }
            }
            Else ; RButton was not pushed down 2x, is a (single-click)
                TranslateUserAction("1x-R-click")
        } ; STFC RButton evaluation is complete
    }
    Else  ; STFC window is not active, do not overide
        MouseClick, Right
    Return

MButton:: ; MButton is clicked, begin STFC MButton evaluation
    WinGetClass, class, A ; get the active window class
    If (class="UnityWndClass") ; STFC window is active, continue evaluating 
    {
        KeyWait, MButton, t0.5 ; wait for (R-click) release
        If (ErrorLevel = 1) ; MButton was not released, is a (long-M-click)
            TranslateUserAction("1x-M-click-hold")
        Else ; MButton was released, continue evaluating 
        {
            KeyWait, MButton, d, t0.5 ; wait f0r 2x R-click       
            If (ErrorLevel = 0) ; MButton was pushed down 2x, (double-M-click)
                TranslateUserAction("2x-M-click")
            Else ; MButton was not pushed down 2x, is a  (single--M-click)
                TranslateUserAction("1x-M-click")
        }
    } ; STFC MButton evaluation is complete
    Else ; STFC window is not active, do not overide
        MouseClick, Middle ; the STFC window is not active
    Return
