*>*****************************************************************
*> Copyright (C) 2020 Stephen Dennis                              *
*> Available under MIT License.                                   *
*>*****************************************************************
identification division.
program-id. testparser.

environment division.
data division.
file section.

working-storage section.
01  csvhandle       usage pointer.
01  bufptr          usage pointer.
01  filename        pic x(40).
01  buffer          pic x(8000) based.
01  bool            usage signed-int.
    88  success             value 0.
    88  failure             value -1.

01  csv_event       usage signed-int value 0.
    88  cpe_none           value 0.
    88  cpe_call_getfield  value 1.
    88  cpe_end_of_record  value 2.
    88  cpe_end_of_file    value 3.
    88  cpe_invalid        value 4.

01  fieldnum        usage signed-int.

01  ws-field        pic x(80).

procedure division.
001-open.
    string 'example.csv' x'00' delimited by size
        into filename.
    call 'csvparser_openfile' using
        by reference csvhandle
        by reference filename
        returning bool.

    if success
*>      skip csv header line.
*>
        perform 002-getline

        if not cpe_invalid and not cpe_end_of_file
            perform 003-parsefile
        end-if

        call 'csvparser_closefile' using
            by value csvhandle
            returning bool

        if cpe_invalid
            display 'CSV file is not valid.'
        else
            if not cpe_end_of_file or failure
                display 'Unexpected error.'
            else
                display 'Success.'
            end-if
        end-if
    else
        display 'Cannot open CSV file.'
    end-if.

    goback.

002-getline.

    move 0 to fieldnum.
    perform until failure or cpe_end_of_record or cpe_end_of_file or cpe_invalid

        call 'csvparser_getevent' using
            by value     csvhandle
            by reference csv_event
            returning bool
        end-call

        if success and cpe_call_getfield
            call 'csvparser_getfield' using
                by value      csvhandle
                by reference  bufptr
                returning bool
            end-call

            set address of buffer to bufptr

            add 1 to fieldnum
            unstring buffer delimited by x'00' into ws-field
            display ws-field
        end-if

    end-perform.

    if success and cpe_end_of_record
        call 'csvparser_getevent' using
            by value     csvhandle
            by reference csv_event
            returning bool
        end-call
    end-if.

003-parsefile.

    perform 002-getline.

    perform until failure or fieldnum <> 5 or cpe_invalid
        perform 002-getline
    end-perform.

end program testparser.
