*>*****************************************************************
*> newyear                                                        *
*> Copyright (C) 2000 Solid Vertical Domains, Ltd.                *
*>                    and Stephen Dennis                          *
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>                                                                *
*> Returns the linear date for the first day of the given year.   *
*>                                                                *
*>*****************************************************************
identification division.
function-id. newyear.

environment division.
configuration section.
repository.
    function fielded_to_linear
    function all intrinsic.

data division.
working-storage section.
01  month           pic 99      comp-5 value 1.
01  dom             pic 99      comp-5 value 1.

linkage section.
*>  Input
*>
*>  The valid range of year is -27256 to 30826, inclusively.
*>
01  ny-year              pic s9(5)   comp-5.

*>  Outputs
*>
01  results.
    *>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
    *>
    05  ny-lineardate        pic s9(8)   comp-5.

    *>  Success/Failure
    *>
    05  ny-success           pic x.

procedure division using ny-year returning results.
0100-main.
    move 'N' to ny-success.
    if (-27256 <= ny-year) and (ny-year <= 30826)
        move fielded_to_linear(ny-year, month, dom) to ny-lineardate
        move 'Y' to ny-success
    end-if.
    goback.
end function newyear.

*>*****************************************************************
*> yearend                                                        *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns the linear date for the first day of the given year.   *
*>                                                                *
*>*****************************************************************
identification division.
function-id. yearend.

environment division.
configuration section.
repository.
    function fielded_to_linear
    function all intrinsic.

data division.
working-storage section.
01  month           pic 99      comp-5 value 12.
01  dom             pic 99      comp-5 value 31.

linkage section.
*>  Input
*>
*>  The valid range of year is -27256 to 30826, inclusively.
*>
01  ye-year              pic s9(5)   comp-5.

*>  Outputs
*>
01  results.
    *>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
    *>
    05  ye-lineardate        pic s9(8)   comp-5.

    *>  Success/Failure
    *>
    05  ye-success           pic x.

procedure division using ye-year returning results.
0100-main.
    move 'N' to ye-success
    if (-27256 <= ye-year) and (ye-year <= 30826)
        move fielded_to_linear(ye-year, month, dom) to ye-lineardate
        move 'Y' to ye-success
    end-if.
    goback.
end function yearend.

*>*****************************************************************
*> dayofweek                                                      *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns the day of week for the given fixed date.              *
*>                                                                *
*>*****************************************************************
identification division.
function-id. dayofweek.

environment division.
configuration section.
repository.
    function floor-divmod
    function all intrinsic.

data division.
working-storage section.
01  ld2                    signed-int.
01  c7           pic s9(8) comp-5 value 7.
01  divmod.
    05  d            pic s9(8) comp-5.
    05  m            pic s9(8) comp-5.

linkage section.
*>  Input
*>
*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ld                 usage   signed-int.

*>  Outputs
*>
01  results.
    *>  The valid range is 0 (Sunday) to 6 (Saturday), inclusively.
    *>
    05  dow            unsigned-short.

    *>  Success/Failure
    *>
    05  dow-success    pic x.

procedure division using ld returning results.
0100-main.
    add 1 to ld giving ld2.
    move floor-divmod(ld2, c7) to divmod.
    move m to dow.
    move 'Y' to dow-success
    goback.
end function dayofweek.

*>*****************************************************************
*> kdayonorbefore                                                 *
*> Copyright (C) 2020 Stephen Vincent Dennis                      *
*> All rights reserved.                                           *
*>                                                                *
*> Returns a requested day of the week where the week ends on a   *
*> certain date.                                                  *
*>                                                                *
*>*****************************************************************
identification division.
function-id. kdayonorbefore.

environment division.
configuration section.
repository.
    function floor-divmod
    function all intrinsic.

data division.
working-storage section.
01  ld2-max                signed-int.
01  c7           pic s9(8) comp-5 value 7.
01  divmod.
    05  d            pic s9(8) comp-5.
    05  m            pic s9(8) comp-5.

linkage section.
*>  Input
*>
*>  The valid range is 0 (Sunday) to 6 (Saturday), inclusively.
*>
01  k                   usage   unsigned-short.

*>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
*>
01  ld-max              usage   signed-int.

*>  Outputs
*>
01  result.
    *>  The valid range is -10539804 (Jan 1, -27256) to 10674576 (Dec 31, 30826), inclusively.
    *>
    05  ld                  usage   signed-int.

    *>  Success/Failure
    *>
    05  bool              pic x.

procedure division using k ld-max returning result.
0100-main.
*>  ld = ld-max - mod(ld-max - k + 1, 7);
*>
    compute ld2-max = ld-max - k + 1.
    move floor-divmod(ld2-max, c7) to divmod.
    subtract m from ld-max giving ld.
    move 'Y' to bool.
    goback.
end function kdayonorbefore.
