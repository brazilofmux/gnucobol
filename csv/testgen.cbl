*>*****************************************************************
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>*****************************************************************
identification division.
program-id. testgen.

environment division.
data division.
working-storage section.
01  csvhandle       usage pointer.
01  filename        pic x(40).
01  buffer          pic x(8000).

01  bool            usage signed-int.
    88  success             value 0.
    88  failure             value -1.

procedure division.
001-open.
    string 'generated.csv' x'00' delimited by size into filename.
    call 'csvgen_createfile' using
        by reference csvhandle
        by reference filename
        by value 2
        returning bool.

    if success
        perform 004-genfile

        call 'csvgen_closefile' using
            by value csvhandle
            returning bool
        end-call

        if failure
            display 'Cannot close test.csv.'
        end-if
    else
        display 'Cannot create test.csv.'
    end-if.
    goback.

002-genfield1.
    string 'Foo' x'00' delimited by size into buffer.
    call 'csvgen_putfield' using
        by value     csvhandle
        by reference buffer
        returning bool
    end-call

    if failure
        display 'Cannot begin row.'
    end-if.

002-genfield2.
    string 'Bar,Baz' x'00' delimited by size into buffer.
    call 'csvgen_putfield' using
        by value     csvhandle
        by reference buffer
        returning bool
    end-call

    if failure
        display 'Cannot begin row.'
    end-if.

003-genline.
    call 'csvgen_beginrow' using
        by value     csvhandle
        returning bool
    end-call

    if failure
        display 'Cannot begin row.'
    end-if

    perform 002-genfield1
    perform 002-genfield2

    call 'csvgen_endrow' using
        by value     csvhandle
        returning bool
    end-call

    if failure
        display 'Cannot end row.'
    end-if.

004-genfile.

    perform 003-genline.

end program testgen.
