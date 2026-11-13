/* Robust tabu search for the quadratic assignment problem.
 *
 * Implements the method described in
 * E. Taillard (1991). Robust taboo search for the quadratic assignment
 * problem. Parallel Computing, 17(4-5), 443-455.
 *
 * The neighborhood is the set of all pairwise exchanges. The move values
 * (deltas) are updated incrementally in O(1) per unaffected pair after each
 * move. Tabu tenures are drawn at random from R's random number generator.
 *
 * The cost of a permutation p is sum_{i,j} a[i,j] * b[p[i], p[j]] (p is
 * zero-based internally), which equals qap.obj() for symmetric matrices.
 */

#include <R.h>
#include <Rinternals.h>
#include <math.h>

#define M(x, i, j) ((x)[(i) + (R_xlen_t)n * (j)])

static double cost_of(int n, const double *a, const double *b, const int *p) {
  double c = 0.0;
  for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j++)
      c += M(a, i, j) * M(b, p[i], p[j]);
  return c;
}

/* change in cost if the facilities at positions i and j are exchanged */
static double delta_of(int n, const double *a, const double *b, const int *p,
                       int i, int j) {
  double d = (M(a, i, i) - M(a, j, j)) * (M(b, p[j], p[j]) - M(b, p[i], p[i])) +
             (M(a, i, j) - M(a, j, i)) * (M(b, p[j], p[i]) - M(b, p[i], p[j]));
  for (int k = 0; k < n; k++) {
    if (k == i || k == j) continue;
    d += (M(a, k, i) - M(a, k, j)) * (M(b, p[k], p[j]) - M(b, p[k], p[i])) +
         (M(a, i, k) - M(a, j, k)) * (M(b, p[j], p[k]) - M(b, p[i], p[k]));
  }
  return d;
}

/* delta of pair (u, v) after the exchange (r, s), disjoint pairs only.
   p is the permutation after the exchange. */
static double delta_update(int n, const double *a, const double *b,
                           const int *p, double old, int r, int s,
                           int u, int v) {
  return old +
    (M(a, r, u) - M(a, r, v) + M(a, s, v) - M(a, s, u)) *
    (M(b, p[s], p[u]) - M(b, p[s], p[v]) + M(b, p[r], p[v]) - M(b, p[r], p[u])) +
    (M(a, u, r) - M(a, v, r) + M(a, v, s) - M(a, u, s)) *
    (M(b, p[u], p[s]) - M(b, p[v], p[s]) + M(b, p[v], p[r]) - M(b, p[u], p[r]));
}

SEXP qap_rots(SEXP sA, SEXP sB, SEXP sperm, SEXP siter, SEXP stenure,
              SEXP saspiration) {
  int n = Rf_nrows(sA);
  const double *a = REAL(sA), *b = REAL(sB);
  int iter_max = Rf_asInteger(siter);
  int tenure = Rf_asInteger(stenure);
  long long aspiration = (long long) Rf_asReal(saspiration);

  int tmin = (int) ceil(0.9 * tenure), tmax = (int) floor(1.1 * tenure);
  if (tmin < 1) tmin = 1;
  if (tmax < tmin) tmax = tmin;

  int *p = (int *) R_alloc(n, sizeof(int));
  int *best = (int *) R_alloc(n, sizeof(int));
  for (int i = 0; i < n; i++) p[i] = best[i] = INTEGER(sperm)[i] - 1;

  double *delta = (double *) R_alloc((size_t) n * n, sizeof(double));
  long long *tabu = (long long *) R_alloc((size_t) n * n, sizeof(long long));
  for (R_xlen_t i = 0; i < (R_xlen_t) n * n; i++) tabu[i] = 0;
#define T(i, j) tabu[(i) + (R_xlen_t)n * (j)]
#define D(i, j) delta[(i) + (R_xlen_t)n * (j)]

  double cur = cost_of(n, a, b, p), best_cost = cur;
  int best_iter = 0;           /* iteration at which the best solution was found */
  int n_aspired = 0;           /* tabu moves taken because of aspiration */
  for (int i = 0; i < n - 1; i++)
    for (int j = i + 1; j < n; j++) D(i, j) = delta_of(n, a, b, p, i, j);

  GetRNGstate();
  for (int it = 1; it <= iter_max; it++) {
    if (it % 256 == 0) R_CheckUserInterrupt();

    int ri = -1, rj = -1;
    double rd = R_PosInf;
    int already_aspired = 0;
    int chosen_allowed = 1;

    for (int i = 0; i < n - 1; i++) {
      for (int j = i + 1; j < n; j++) {
        double d = D(i, j);
        long long ti = T(i, p[j]), tj = T(j, p[i]);
        /* tabu only if both placements are forbidden */
        int allowed = (ti < it) || (tj < it);
        /* aspiration: new best, or a placement unused for a long time */
        int aspired = (ti < it - aspiration) || (tj < it - aspiration) ||
                      (cur + d < best_cost);
        if ((aspired && !already_aspired) ||
            (aspired && already_aspired && d < rd) ||
            (!aspired && !already_aspired && allowed && d < rd)) {
          ri = i; rj = j; rd = d;
          chosen_allowed = allowed;
          if (aspired) already_aspired = 1;
        }
      }
    }

    if (ri < 0) { /* every move is tabu: take a random one */
      ri = (int) (unif_rand() * n); if (ri >= n) ri = n - 1;
      do { rj = (int) (unif_rand() * n); if (rj >= n) rj = n - 1; }
      while (rj == ri);
      if (ri > rj) { int t = ri; ri = rj; rj = t; }
      rd = D(ri, rj);
    } else if (already_aspired && !chosen_allowed) {
      n_aspired++;
    }

    /* forbid returning the exchanged facilities to their old locations */
    T(ri, p[ri]) = it + tmin + (int) (unif_rand() * (tmax - tmin + 1));
    T(rj, p[rj]) = it + tmin + (int) (unif_rand() * (tmax - tmin + 1));

    int t = p[ri]; p[ri] = p[rj]; p[rj] = t;
    cur += rd;

    if (cur < best_cost) {
      best_cost = cur;
      best_iter = it;
      for (int i = 0; i < n; i++) best[i] = p[i];
    }

    /* update the move values */
    for (int i = 0; i < n - 1; i++) {
      for (int j = i + 1; j < n; j++) {
        if (i != ri && i != rj && j != ri && j != rj)
          D(i, j) = delta_update(n, a, b, p, D(i, j), ri, rj, i, j);
        else
          D(i, j) = delta_of(n, a, b, p, i, j);
      }
    }
  }
  PutRNGstate();

  SEXP perm = PROTECT(Rf_allocVector(INTSXP, n));
  for (int i = 0; i < n; i++) INTEGER(perm)[i] = best[i] + 1;
  SEXP obj = PROTECT(Rf_ScalarReal(cost_of(n, a, b, best)));
  SEXP res = PROTECT(Rf_allocVector(VECSXP, 4));
  SET_VECTOR_ELT(res, 0, perm);
  SET_VECTOR_ELT(res, 1, obj);
  SET_VECTOR_ELT(res, 2, Rf_ScalarInteger(best_iter));
  SET_VECTOR_ELT(res, 3, Rf_ScalarInteger(n_aspired));
  UNPROTECT(3);
  return res;
}
