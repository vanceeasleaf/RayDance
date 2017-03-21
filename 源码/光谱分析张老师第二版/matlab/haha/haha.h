/*
 * MATLAB Compiler: 4.13 (R2010a)
 * Date: Wed Feb 08 17:25:21 2012
 * Arguments: "-B" "macro_default" "-B" "csharedlib:haha" "-W" "lib:haha" "-T"
 * "link:lib" "final.m" "-v" 
 */

#ifndef __haha_h
#define __haha_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__SUNPRO_CC)
/* Solaris shared libraries use __global, rather than mapfiles
 * to define the API exported from a shared library. __global is
 * only necessary when building the library -- files including
 * this header file to use the library do not need the __global
 * declaration; hence the EXPORTING_<library> logic.
 */

#ifdef EXPORTING_haha
#define PUBLIC_haha_C_API __global
#else
#define PUBLIC_haha_C_API /* No import statement needed. */
#endif

#define LIB_haha_C_API PUBLIC_haha_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_haha
#define PUBLIC_haha_C_API __declspec(dllexport)
#else
#define PUBLIC_haha_C_API __declspec(dllimport)
#endif

#define LIB_haha_C_API PUBLIC_haha_C_API


#else

#define LIB_haha_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_haha_C_API 
#define LIB_haha_C_API /* No special import/export declaration */
#endif

extern LIB_haha_C_API 
bool MW_CALL_CONV hahaInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_haha_C_API 
bool MW_CALL_CONV hahaInitialize(void);

extern LIB_haha_C_API 
void MW_CALL_CONV hahaTerminate(void);



extern LIB_haha_C_API 
void MW_CALL_CONV hahaPrintStackTrace(void);

extern LIB_haha_C_API 
bool MW_CALL_CONV mlxFinal(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_haha_C_API 
long MW_CALL_CONV hahaGetMcrID();



extern LIB_haha_C_API bool MW_CALL_CONV mlfFinal();

#ifdef __cplusplus
}
#endif
#endif
