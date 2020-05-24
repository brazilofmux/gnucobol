*>*****************************************************************
*> isleapyear                                                     *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*> All rights reserved.                                           *
*>                                                                *
*> The following code determines whether a year is a leap year or *
*> not. It works for negative years.                              *
*>                                                                *
*> This is equivalent to gregorian-leap-year() from "Calendrical  *
*> Calculations".                                                 *
*>                                                                *
*>*****************************************************************
identification division.
program-id. isleapyear.
data division.
working-storage section.
*>*****************************************************************
*> floor-divmod, floor-div                                        *
*>*****************************************************************
01  fdm-x   pic s9(8) comp-5.
01  fdm-y   pic s9(8) comp-5.
01  fdm-div pic s9(8) comp-5.
01  fdm-mod pic s9(8) comp-5.

linkage section.
01  ily-year    pic s9(5) comp-5.
01  ily-leap    pic x.
    88  ily-is-leap-year    value 'Y'.
    88  ily-not-leap-year   value 'N'.

procedure division using ily-year ily-leap.
0100-main.
    move ily-year to fdm-x.
    move 4 to fdm-y.
    call 'floor-divmod' using fdm-x fdm-y fdm-div fdm-mod.
    if fdm-mod is not zero
        move 'N' to ily-leap
    else
        move 400 to fdm-y
        call 'floor-divmod' using fdm-x fdm-y fdm-div fdm-mod
        if (fdm-mod = 100) or (fdm-mod = 200) or (fdm-mod = 300)
            move 'N' to ily-leap else
            move 'Y' to ily-leap
        end-if
    end-if.
    goback.
end program isleapyear.
