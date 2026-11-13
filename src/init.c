#include <R.h>
#include <Rinternals.h>
#include <R_ext/RS.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* FIXME: 
   Check these declarations against the C/Fortran source code.
*/

/* .Fortran calls */
extern void F77_NAME(qaph4)(void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *, void *);

/* .Call routines */
extern SEXP qap_rots(SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"qap_rots", (DL_FUNC) &qap_rots, 6},
    {NULL, NULL, 0}
};

static const R_FortranMethodDef FortranEntries[] = {
    {"qaph4", (DL_FUNC) &F77_NAME(qaph4), 12},
    {NULL, NULL, 0}
};

void R_init_qap(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, FortranEntries, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
