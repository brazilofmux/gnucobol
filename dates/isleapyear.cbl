*>*****************************************************************
*> isleapyear                                                     *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*>                    and Stephen Dennis                          *
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>                                                                *
*> The following code determines whether a year is a leap year or *
*> not. It works for negative years.                              *
*>                                                                *
*> This is equivalent to gregorian-leap-year() from "Calendrical  *
*> Calculations".                                                 *
*>                                                                *
*>*****************************************************************
identification division.
function-id. isleapyear.

environment division.
configuration section.
repository.
    function floor-divmod
    function all intrinsic.

data division.
working-storage section.
*>*****************************************************************
*> floor-divmod, floor-div                                        *
*>*****************************************************************
01  fdm-x   pic s9(8) comp-5.
01  c4      pic s9(8) comp-5 value 4.
01  c400    pic s9(8) comp-5 value 400.
01  divmod.
    05  fdm-div pic s9(8) comp-5.
    05  fdm-mod pic s9(8) comp-5.

linkage section.
01  ily-year    pic s9(5) comp-5.
01  ily-leap    pic x.
    88  ily-is-leap-year    value 'Y'.
    88  ily-not-leap-year   value 'N'.

procedure division using ily-year returning ily-leap.
0100-main.
    move ily-year to fdm-x.
    move floor-divmod(fdm-x, c4) to divmod.
    if fdm-mod is not zero
        move 'N' to ily-leap
    else
        move floor-divmod(fdm-x, c400) to divmod
        if (fdm-mod = 100) or (fdm-mod = 200) or (fdm-mod = 300)
            move 'N' to ily-leap
        else
            move 'Y' to ily-leap
        end-if
    end-if.
    goback.
end function isleapyear.
