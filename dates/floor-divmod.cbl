*>*****************************************************************
*> floor-divmod                                                   *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*>                    and Stephen Dennis                          *
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>                                                                *
*> The following "Floor Division Modulus" routine calculates the  *
*> proper modulus of a negative number. For negative numbers, a   *
*> modulus is different than a remainder. The modulus is always   *
*> positive.                                                      *
*>                                                                *
*> For example, -1 floordivmod 2 gives a FDM-DIV of -1 with a     *
*> FDM-MOD of +1. In other words, -1/2 ==> -1 + 1/2               *
*>                                                                *
*> In contrast, a remainder approach gives a different answer:    *
*> -1/2 ==> 0 + -1/2                                              *
*>*****************************************************************
identification division.
function-id. floor-divmod.
data division.
working-storage section.
01  fdm-tmp pic s9(8) comp-5.

linkage section.
01  fdm-x   pic s9(8) comp-5.
01  fdm-y   pic s9(8) comp-5.
01  result.
    05  fdm-div pic s9(8) comp-5.
    05  fdm-mod pic s9(8) comp-5.
procedure division using fdm-x fdm-y returning result.
0100-main.
    if fdm-x >= 0
        divide fdm-y into fdm-x giving fdm-div remainder fdm-mod
    else
        add 1 to fdm-x giving fdm-tmp
        subtract fdm-y from fdm-tmp
        divide fdm-y into fdm-tmp giving fdm-div
            remainder fdm-mod
        add fdm-y to fdm-mod
        subtract 1 from fdm-mod
    end-if.
    goback.
end function floor-divmod.
