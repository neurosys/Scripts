
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force ; Forces the execution of only one version of this script
                      ; running at the same time

; Send keys as fast as possible (really fast :-) )
;SetKeyDelay, 0, 0

DbgStop()
{
    ListVars
    Sleep 60000
}

Min(a,b)
{
    if a < b
    {
        return a
    }
    return b
}

Max(a,b)
{
    if a > b
    {
        return a
    }
    return b
}

; a - day_of_week
; b - reference day
Delta(a, b)
{
    return Max(a,b) - Min(a,b)
}

GetWeekLimit(year, month, day, current_wday, limit)
{
    time = %year%%month%%day%
    time += Delta(current_wday, limit)
    FormatTime, new_time, %time%, yyyy-MM-dd
    return new_time
}

GetWorkingIntervalOfWeek()
{
    ;FormatTime, timestamp_now, , yyyy-MM-dd_HH-mm-ss
    FormatTime, year, ,yyyy
    FormatTime, month, ,MM
    FormatTime, day, ,dd
    FormatTime, day_of_week, ,WDay
    start := GetWeekLimit(year, month, day, day_of_week, 2) ; Monday
    end   := GetWeekLimit(year, month, day, day_of_week, 6) ; Friday
    return start " - " end
}

mail_client = C:\Program Files (x86)\Mozilla Thunderbird
gvim_path = C:\Program Files (x86)\Vim\vim80\gvim
emacs_path = D:\Kits\emacs\bin\runemacs
xcode=

; Minimize current window
!Escape::WinMinimize, A

; shells
#k::Run cmd.exe
#+k::Run mintty.exe

; editors
#n::Run %gvim_path%
; the -mm is for start maximized
#+n::Run %emacs_path% -mm
#p::Run mspaint.exe ; well not quite an editor, but in can be very userful

#i::
{
    FormatTime, CurrentTimeStamp,, yyyy-MM-dd_HH-mm-ss
    Send %CurrentTimeStamp%
    return
}

; Mail stuff
#o::Run %mail_client%, , max
; Send email
#m::Run %office_path% -compose

; Send the week interval
#+i::
{
    working_week := GetWorkingIntervalOfWeek()
    Send %working_week%
    return
}



; ^#p::Send username{Tab}%xcode%{Enter}

; Misc
#F1::Run calc.exe
#F2::Run cmd.exe /C python

; Open a cmd from Total Commander
#IfWinActive, Total Commander
{
    #k::Send {Ctrl Down}{Down}{Ctrl Up}{Enter}
    return
}
; When I'm opening a configuration from Manager
#IfWinActive, Configuration Service User Login
{
    F1::Send Administrator{Tab}Administrator{Enter}
    F2::Send Administrator{Tab}password{Enter}
    return
}
return