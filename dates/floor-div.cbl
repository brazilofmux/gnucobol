*>*****************************************************************
*> floor-div                                                      *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*>                    and Stephen Dennis                          *
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>                                                                *
*> The following "Floor Division" routine calculates the proper   *
*> modulus of a negative number. For negative numbers, a modulus  *
*> is different than a remainder. The modulus is always positive. *
*>                                                                *
*> For example, -1 floordivmod 2 gives a FDM-DIV of -1 with a     *
*> FDM-MOD of +1. In other words, -1/2 ==> -1 + 1/2               *
*>                                                                *
*> In contrast, a remainder approach gives a different answer:    *
*> -1/2 ==> 0 + -1/2                                              *
*>*****************************************************************
identification division.
function-id. floor-div.
data division.
working-storage section.
01  fdm-tmp pic s9(8) comp-5.

linkage section.
01  fdm-x   pic s9(8) comp-5.
01  fdm-y   pic s9(8) comp-5.
01  fdm-div pic s9(8) comp-5.
procedure division using fdm-x fdm-y returning fdm-div.
0100-main.
    if fdm-x >= 0
        divide fdm-y into fdm-x giving fdm-div
    else
        add 1 to fdm-x giving fdm-tmp
        subtract fdm-y from fdm-tmp
        divide fdm-y into fdm-tmp giving fdm-div
    end-if.
    goback.
end function floor-div.
