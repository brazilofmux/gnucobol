/*
 * Copyright (C) 2000 Solid Vertical Domains, Ltd. and Stephen Dennis
 * Copyright (C) 2020 Stephen Dennis
 * Available under MIT License.
 */

#include <stdlib.h>
#include <stdio.h>

#define USE_STRICT

// Input Translation Table
//
static int itt[256] =
{
//  0   1   2   3   4   5   6   7    8   9   A   B   C   D   E   F
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  1,  0,  0,  2,  0,  0,  // 0
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // 1
    0,  0,  4,  0,  0,  0,  0,  0,   0,  0,  0,  0,  3,  0,  0,  0,  // 2
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // 3
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // 4
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // 5
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // 6
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // 7

    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // 8
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // 9
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // A
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // B
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // C
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // D
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // E
    0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,  // F
};

// Strict State Transition Table (except flexible on line endings).
//
static int stt[13][5] =
{
//   Any  LF  CR   ,   "
#ifdef USE_STRICT
    {  6, 10,  3,  8,  1 },  // State  0 - F0
    {  7,  7,  7,  7,  2 },  // State  1 - F2
    { 12, 11,  4,  8,  5 },  // State  2 - Q2
    { 12, 10, 12, 12, 12 },  // State  3 - CR0
    { 12, 11, 12, 12, 12 },  // State  4 - CR1
    {  7,  7,  7,  7,  2 },  // State  5 - Save Quote
    {  6, 11,  4,  8, 12 },  // State  6 - Save Byte
    {  7,  7,  7,  7,  2 },  // State  7 - Save Byte
    {  6, 11,  9,  8,  1 },  // State  8 - Save Field
    { 12, 10, 12, 12, 12 },  // State  9 - Save Field
    {  6, 10,  3,  8,  1 },  // State 10 - Save Record
    {  6, 10,  3,  8,  1 },  // State 11 - Save Field And Record
    { 12, 12, 12, 12, 12 },  // State 12 - Error
#else
    {  6, 10,  3,  8,  1 },  // State  0 - F0
    {  7,  7,  7,  7,  2 },  // State  1 - F2
    {  6, 11,  4,  8,  5 },  // State  2 - Q2
    { 12, 10, 12, 12, 12 },  // State  3 - CR0
    { 12, 11, 12, 12, 12 },  // State  4 - CR1
    {  7,  7,  7,  7,  2 },  // State  5 - Save Quote
    {  6, 11,  4,  8,  6 },  // State  6 - Save Byte
    {  7,  7,  7,  7,  2 },  // State  7 - Save Byte
    {  6, 11,  9,  8,  1 },  // State  8 - Save Field
    { 12, 10, 12, 12, 12 },  // State  9 - Save Field
    {  6, 10,  3,  8,  1 },  // State 10 - Save Record
    {  6, 10,  3,  8,  1 },  // State 11 - Save Field And Record
    { 12, 12, 12, 12, 12 },  // State 12 - Error
#endif
};

#define FALSE 0
#define TRUE (!FALSE)

#define LBUF_SIZE 8000

typedef struct
{
    FILE *m_fp;
    int m_iParseState;
    int m_fHaveExpectedFields;
    int m_nFieldsExpected;
    int m_nFields;
    int m_nLineNumber;

#define PE_ERROR_FIELDCOUNT            1
#define PE_ERROR_UNEXPECTED_CHARACTER  2
#define PE_ERROR_SHORTFILE             3
#define PE_FIELD                       4
#define PE_RECORD                      5
#define PE_FIELDTHENRECORD             6
#define PE_ENDOFFILE                   7
    int m_pe;

#define AS_READY           1  // Ready to parse.
#define AS_PARSEEVENT      2  // Holding previous parse event.
    int m_iAPIState;

    char m_buffer[LBUF_SIZE];
    size_t m_n;
} CSV_STATE;

typedef struct NODE
{
    CSV_STATE *m_pHandle;
    struct NODE *m_next;
} NODE;

static NODE *g_list = NULL;

static int addnode(CSV_STATE *p)
{
    NODE *pNode = (NODE *)malloc(sizeof(NODE));
    if (NULL != pNode)
    {
        pNode->m_pHandle = p;
        pNode->m_next = g_list;
        g_list = pNode;
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

static int isournode(CSV_STATE *p)
{
    NODE *pNode = g_list;
    while (NULL != pNode)
    {
        if (pNode->m_pHandle == p)
        {
            return TRUE;
        }
        pNode = pNode->m_next;
    }
    return FALSE;
}

static int removenode(CSV_STATE *p)
{
    NODE *pNode = g_list;
    NODE *pPrev = NULL;
    while (NULL != pNode)
    {
        if (pNode->m_pHandle == p)
        {
            if (NULL == pPrev)
            {
                g_list = pNode->m_next;
            }
            else
            {
                pPrev->m_next  = pNode->m_next;
            }
            free(pNode);
            return TRUE;
        }
        pPrev = pNode;
        pNode = pNode->m_next;
    }
    return FALSE;
}

static void method_CloseFile(CSV_STATE *p)
{
    if (NULL != p->m_fp)
    {
        fclose(p->m_fp);
        p->m_fp = NULL;
    }
}

static void method_Clear(CSV_STATE *p)
{
    p->m_fp = NULL;
    p->m_fHaveExpectedFields = FALSE;
    p->m_nFieldsExpected = 0;
    p->m_nFields = 0;
    p->m_nLineNumber = 1;
    p->m_iParseState = 0;
    p->m_iAPIState = AS_READY;
    p->m_n = 0;
}

static void method_AddChar(CSV_STATE *p, char ch)
{
    if (p->m_n < LBUF_SIZE-1)
    {
        p->m_buffer[p->m_n] = ch;
        p->m_n++;
    }
}

static int method_Parse(CSV_STATE *p)
{
    int ch;
    while ((ch = fgetc(p->m_fp)) != EOF)
    {
        int iColumn = itt[(unsigned char)ch];
        p->m_iParseState = stt[p->m_iParseState][iColumn];
        if (p->m_iParseState <= 4) continue;

        if (6 <= p->m_iParseState && p->m_iParseState <= 7)
        {
            // Save Byte.
            //
            if ('\0' != ch)
            {
                method_AddChar(p, ch);
            }
        }
        else if (5 == p->m_iParseState)
        {
            // Save Quote.
            //
            method_AddChar(p, '"');
        }
        else if (8 <= p->m_iParseState && p->m_iParseState <= 9)
        {
            // Save Field.
            //
            p->m_nFields++;
            return PE_FIELD;
        }
        else if (10 == p->m_iParseState)
        {
            // Save Record
            //
            if (p->m_fHaveExpectedFields)
            {
                if (p->m_nFields != p->m_nFieldsExpected)
                {
                    return PE_ERROR_FIELDCOUNT;
                }
            }
            else
            {
                p->m_nFieldsExpected = p->m_nFields;
                p->m_fHaveExpectedFields = TRUE;
            }
            p->m_nFields = 0;
            p->m_nLineNumber++;
            return PE_RECORD;
        }
        else if (11 == p->m_iParseState)
        {
            // Save Field.
            //
            p->m_nFields++;

            // Save Record
            //
            if (p->m_fHaveExpectedFields)
            {
                if (p->m_nFields != p->m_nFieldsExpected)
                {
                    return PE_ERROR_FIELDCOUNT;
                }
            }
            else
            {
                p->m_nFieldsExpected = p->m_nFields;
                p->m_fHaveExpectedFields = TRUE;
            }
            p->m_nFields = 0;
            p->m_nLineNumber++;
            return PE_FIELDTHENRECORD;
        }
        else if (12 == p->m_iParseState)
        {
            return PE_ERROR_UNEXPECTED_CHARACTER;
        }
    }

    if (  10 == p->m_iParseState
       || 11 == p->m_iParseState)
    {
        return PE_ENDOFFILE;
    }
    else
    {
        return PE_ERROR_SHORTFILE;
    }
}

int csvparser_openfile(CSV_STATE **pHandle, const char *filename)
{
    CSV_STATE *p = (CSV_STATE *)malloc(sizeof(CSV_STATE));
    if (NULL != p)
    {
        method_Clear(p);
        p->m_fp = fopen(filename, "rb");
        if (  NULL != p->m_fp
           && addnode(p))
        {
            setvbuf(p->m_fp, NULL, _IOFBF, 16384);
            p->m_iAPIState = AS_READY;
            *pHandle = p;
            return 0;
        }
        method_CloseFile(p);
        free(p);
    }
    return -1;
}

int csvparser_closefile(CSV_STATE *p)
{
    if (isournode(p))
    {
        method_CloseFile(p);
        removenode(p);
        return 0;
    }
    return -1;
}

#define CPE_NONE           0
#define CPE_CALL_GETFIELD  1
#define CPE_END_OF_RECORD  2
#define CPE_END_OF_FILE    3
#define CPE_INVALID        4

int csvparser_getevent(CSV_STATE *p, int *piEvent)
{
    if (isournode(p))
    {
        if (AS_READY == p->m_iAPIState)
        {
            p->m_n = 0;
            p->m_pe = method_Parse(p);
            p->m_iAPIState = AS_PARSEEVENT;
        }

        if (  PE_FIELD == p->m_pe
           || PE_FIELDTHENRECORD == p->m_pe)
        {
            *piEvent = CPE_CALL_GETFIELD;
        }
        else if (PE_RECORD == p->m_pe)
        {
            p->m_iAPIState = AS_READY;
            *piEvent = CPE_END_OF_RECORD;
        }
        else if (PE_ENDOFFILE == p->m_pe)
        {
            *piEvent = CPE_END_OF_FILE;
        }
        else
        {
            printf("Line number: %d\n", p->m_nLineNumber);
            printf("Error: %d\n", p->m_pe);
            *piEvent = CPE_INVALID;
        }
        return 0;
    }
    return -1;
}

int csvparser_getfield(CSV_STATE *p, char **pField)
{
    if (  isournode(p)
       && AS_PARSEEVENT == p->m_iAPIState
       && (  PE_FIELD == p->m_pe
          || PE_FIELDTHENRECORD == p->m_pe))
    {
        p->m_buffer[p->m_n] = '\0';
        *pField = p->m_buffer;

        if (PE_FIELD == p->m_pe)
        {
            p->m_iAPIState = AS_READY;
        }
        else // if (PE_FIELDTHENRECORD == p->m_pe)
        {
            p->m_pe = PE_RECORD;
        }
        return 0;
    }
    return -1;
}
