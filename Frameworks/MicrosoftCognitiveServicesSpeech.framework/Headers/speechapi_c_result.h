//
// Copyright (c) Microsoft. All rights reserved.
// See https://aka.ms/csspeech/license201809 for the full license information.
//
// speechapi_c_result.h: Public API declarations for Result related C methods and enumerations
//

#pragma once
#include <speechapi_c_common.h>

enum Result_Reason
{
    ResultReason_NoMatch = 0,
    ResultReason_Canceled = 1,
    ResultReason_RecognizingSpeech = 2,
    ResultReason_RecognizedSpeech = 3,
    ResultReason_RecognizingIntent = 4,
    ResultReason_RecognizedIntent = 5,
    ResultReason_TranslatingSpeech = 6,
    ResultReason_TranslatedSpeech = 7,
    ResultReason_SynthesizingAudio = 8,
    ResultReason_SynthesizingAudioComplete = 9
};
typedef enum Result_Reason Result_Reason;

enum Result_CancellationReason
{
    CancellationReason_Error = 1,
    CancellationReason_EndOfStream = 2
};
typedef enum Result_CancellationReason Result_CancellationReason;

enum Result_NoMatchReason
{
    NoMatchReason_NotRecognized = 1,
    NoMatchReason_InitialSilenceTimeout = 2,
    NoMatchReason_InitialBabbleTimeout = 3
};
typedef enum Result_NoMatchReason Result_NoMatchReason;

SPXAPI result_get_reason(SPXRESULTHANDLE hresult, Result_Reason* reason);
SPXAPI result_get_reason_canceled(SPXRESULTHANDLE hresult, Result_CancellationReason* reason);
SPXAPI result_get_no_match_reason(SPXRESULTHANDLE hresult, Result_NoMatchReason* reason);

SPXAPI result_get_result_id(SPXRESULTHANDLE hresult, char* pszResultId, uint32_t cchResultId);

SPXAPI result_get_text(SPXRESULTHANDLE hresult, char* pszText, uint32_t cchText);
SPXAPI result_get_offset(SPXRESULTHANDLE hresult, uint64_t* offset);
SPXAPI result_get_duration(SPXRESULTHANDLE hresult, uint64_t* duration);

SPXAPI result_get_property_bag(SPXRESULTHANDLE hresult, SPXPROPERTYBAGHANDLE* hpropbag);
