//
//  Logger.h
//  library-generator
//
//  Created by Kyle King on 2021-02-17.

#if ( defined(MLE_LOG_LEVEL_NONE) && MLE_LOG_LEVEL_NONE )
#  undef MLE_LOG_LEVEL_DEBUG
#  undef MLE_LOG_LEVEL_INFO
#  undef MLE_LOG_LEVEL_WARNING
#  undef MLE_LOG_LEVEL_ERROR
#endif

#if ( !defined(MLE_LOG_LEVEL_NONE) && !defined(MLE_LOG_LEVEL_DEBUG) && !defined(MLE_LOG_LEVEL_INFO) && !defined(MLE_LOG_LEVEL_WARNING) && !defined(MLE_LOG_LEVEL_ERROR) )
#  define MLE_LOG_LEVEL_WARNING 1
#endif

#define _MLE_LogWithLevel(level,fmt,...) NSLog(fmt, ## __VA_ARGS__)

#if ( MLE_LOG_LEVEL_DEBUG )
#  define MLE_Log_Debug(fmt,...) _MLE_LogWithLevel(Debug, fmt, ## __VA_ARGS__)
#else
#  define MLE_Log_Debug(...)
#endif

#if ( MLE_LOG_LEVEL_DEBUG || MLE_LOG_LEVEL_INFO )
#  define MLE_Log_Info(fmt,...) _MLE_LogWithLevel(Info, fmt, ## __VA_ARGS__)
#else
#  define MLE_Log_Info(...)
#endif

#if ( MLE_LOG_LEVEL_DEBUG || MLE_LOG_LEVEL_INFO || MLE_LOG_LEVEL_WARNING )
#  define MLE_Log_Warning(fmt,...) _MLE_LogWithLevel(Warning, fmt, ## __VA_ARGS__)
#else
#  define MLE_Log_Warning(...)
#endif

#if ( MLE_LOG_LEVEL_DEBUG || MLE_LOG_LEVEL_INFO || MLE_LOG_LEVEL_WARNING || MLE_LOG_LEVEL_ERROR )
#  define MLE_Log_Error(fmt,...) _MLE_LogWithLevel(Error, fmt, ## __VA_ARGS__)
#else
#  define MLE_Log_Error(...)
#endif
