# Solve a Quadratic Assignment Problem

Solve a quadratic assignment problem (QAP) with a simulated annealing or
robust tabu search heuristic. `qap.obj()` calculates the objective value
of an assignment.

## Usage

``` r
qap(A, B, method = NULL, ...)

qap.obj(A, B, o)
```

## Arguments

- A:

  A numeric matrix of flows between facilities. For `qap()`, it must be
  at least 2 by 2, symmetric, nonnegative, and finite.

- B:

  A numeric matrix of distances between locations. For `qap()`, it must
  have the same dimensions as `A` and be symmetric, nonnegative, and
  finite.

- method:

  Solver name: `"SA"` (simulated annealing, the default) or `"RoTS"`
  (robust tabu search).

- ...:

  Additional arguments passed to the selected solver. See Details.

- o:

  A permutation of `1:nrow(A)` assigning facilities to locations.

## Value

`qap()` returns an integer vector of facility to location assignments
with the objective value in its `"obj"` attribute. `qap.obj()` returns
the objective value for permutation `o`.

## Details

The problem is to assign \\n\\ facilities to \\n\\ locations to minimize
total transportation or interaction costs. Required flows between the
facilities are represented by the matrix \\A\\ and distances between
locations is given in matrix \\B\\. The QAP seeks an assignment that
minimizes the sum of flows times distance. For an assignment represented
by a \\n \times n\\ permutation matrix \\X\\ used to assign the
facilities to the locations in the order given by the permutation, the
objective can be written as

\$\$\min\_{X \in \Pi}\\ \mathrm{tr}(AXB^TX^T)\$\$

where \\\Pi\\ is the set of all valid \\n \times n\\ permutation
matrices. Note that for symmetric distances, the distance matrix \\B\\
does not need to be transposed.

The QAP originated as a facility location problem (Koopmans and
Beckmann, 1957) and also has applications in data analysis (Hubert and
Schultz, 1976). It is NP-hard. Two heuristics are available.

### Simulated Annealing

`method = "SA"` uses the simulated annealing heuristic of Burkard and
Rendl (1984), based on Rendl's Fortran implementation from QAPLIB. The
authors suggest it can produce heuristic solutions for problems with up
to 256 objects, although the implementation does not enforce this limit.

Additional arguments for `method = "SA"` are:

- `rep`:

  Positive integer number of restarts. More restarts can help with local
  optima. Default: `1L`.

- `miter`:

  Positive integer number of iterations at a fixed temperature.
  Increasing miter typically leads to modest reduction in the optimality
  gap while increasing runtime. Default: `2 * nrow(A)`.

- `fiter`:

  Factor of at least 1 by which `miter` grows after each cooling step.
  Larger values lead to very long runtimes. Default `1.1`.

- `ft`:

  Factor by which the temperature decreases after each cooling step.
  When increasing this value, `maxsteps` also needs to be increased.
  Default `0.5` (strictly between 0 and 1).

- `maxsteps`:

  Positive integer maximum number of cooling steps. The search also
  stops earlier once it has frozen, i.e., the objective value did not
  change during a whole step. With the default cooling rate this
  typically happens for problems with less than 150 objects before the
  default `maxsteps` of 50 is reached, however, larger problems can
  benefit from increasing `maxsteps`. Default `50L`.

- `verbose`:

  Print the parameter settings and, for each restart, the best and
  current objective values, the number of cooling steps used, the final
  temperature, and the run time; default `FALSE`.

A good starting point for experiments is to set `maxsteps` very large
(e.g., 100000) and then slow down cooling by increasing `ft` from 0.5 in
0.1 steps towards 1. Use `verbose = TRUE` to see the algorithm's
behavior given the parameters and if `maxsteps` stop simulated annealing
too early with a high final temperature.

### Robust Tabu Search

`method = "RoTS"` uses the robust tabu search of Taillard (1991). It
repeatedly moves to the best pairwise exchange of two facilities that is
not tabu, where a tabu tenure that varies randomly around `tenure`
iterations prevents facilities from returning to recently used
locations. Moves are accepted regardless of tabu status if they give a
new best solution or place a facility at a location it has not used for
more than `aspiration` iterations. Random numbers come from R's
generator, so results can be reproduced with
[`set.seed()`](https://rdrr.io/r/base/Random.html).

Additional arguments for `method = "RoTS"` are:

- `rep`:

  Positive integer number of restarts from random permutations. More
  restarts reduce the dependence on the starting permutation. Default
  `1L`.

- `iter`:

  Positive integer number of tabu search iterations per restart. The run
  time grows linearly with `iter`. Default `100 * nrow(A)`.

- `tenure`:

  Positive integer mean tabu tenure. The actual tenure is drawn
  uniformly from 0.9 to 1.1 times this value. A longer tenure forbids
  more moves and pushes the search further away from the current region,
  a shorter tenure makes it more greedy. Default `nrow(A)`.

- `aspiration`:

  Nonnegative number of iterations after which an unused placement may
  override the tabu status. Default `5 * nrow(A)^2`.

- `verbose`:

  Print the parameter settings and, for each restart, the best and
  current objective values, the iteration at which the best solution was
  found (`best_iter`), the number of tabu moves taken because of
  aspiration (`aspired`), and the run time; default `FALSE`.

Unlike simulated annealing, tabu search always runs for `iter`
iterations. The tabu tenure controls how strongly the search is pushed
to explore and stays fixed during the run. The defaults follow Taillard
(1991) and worked well for many small QAPLIB problems where small
changes of the parameters `tenure` and `aspiration` often make very
little difference.

Use `verbose = TRUE` to check `best_iter`: if the best solution is found
close to `iter`, the search was still improving and `iter` should be
increased. If it is found much earlier, the rest of the run added
little, and a smaller `iter` with more restarts may be more effective.

## References

Burkard, R. E. and Rendl, F. (1984). A thermodynamically motivated
simulation procedure for combinatorial optimization problems. *European
Journal of Operational Research*, 17(2), 169-174.
[doi:10.1016/0377-2217(84)90231-5](https://doi.org/10.1016/0377-2217%2884%2990231-5)

Koopmans, T. C. and Beckmann, M. (1957). Assignment problems and the
location of economic activities. *Econometrica*, 25(1), 53-76.
[doi:10.2307/1907742](https://doi.org/10.2307/1907742)

Taillard, E. (1991). Robust taboo search for the quadratic assignment
problem. *Parallel Computing*, 17(4-5), 443-455.
[doi:10.1016/S0167-8191(05)80147-4](https://doi.org/10.1016/S0167-8191%2805%2980147-4)

Hubert, L. and Schultz, J. (1976). Quadratic assignment as a general
data analysis strategy. *British Journal of Mathematical and Statistical
Psychology*, 29(2), 190-241.
[doi:10.1111/j.2044-8317.1976.tb00714.x](https://doi.org/10.1111/j.2044-8317.1976.tb00714.x)

## See also

[`read_qaplib()`](https://michael.hahsler.net/qap/reference/read_qaplib.md)

## Examples

``` r
set.seed(1234)
p <- read_qaplib(system.file("qaplib", "had12.dat", package = "qap"))
cat("Optimal solution:", p$opt)
#> Optimal solution: 1652

a <- qap(p$A, p$B, verbose = TRUE, rep = 5)
#> Simulated annealing heuristic by Burkard and Rendl.
#> Parameters: n = 12, rep = 5, miter = 24, fiter = 1.1, ft = 0.5, maxsteps = 50
#>   rep   best_obj  current_obj  steps   final_temp     time
#>     1       1684         1684     11        1.844   0.000s
#>     2       1678         1678     12        0.922   0.000s
#>     3       1660         1660     12        0.922   0.000s
#>     4       1654         1654     12        0.922   0.001s
#>     5       1654         1696     11        1.844   0.000s
a
#>  [1]  8 10  2 11 12  5  6  7  3  1  4  9
#> attr(,"obj")
#> [1] 1654
cat("optimality gap:", (attr(a, "obj") - p$opt) / p$opt * 100, "%")
#> optimality gap: 0.1210654 %

# robust tabu search often finds the optimal solution
a <- qap(p$A, p$B, method = "RoTS", rep = 5, verbose = TRUE)
#> Robust tabu search by Taillard.
#> Parameters: n = 12, rep = 5, iter = 1200, tenure = 12, aspiration = 720
#>   rep   best_obj  current_obj  best_iter   aspired     time
#>     1       1652         1652         26         1   0.001s
#>     2       1652         1660         89         2   0.001s
#>     3       1652         1652        837         3   0.001s
#>     4       1652         1652         12         0   0.001s
#>     5       1652         1652         45         3   0.001s
a
#>  [1]  3 10 11  2 12  5  6  7  8  1  4  9
#> attr(,"obj")
#> [1] 1652
cat("optimality gap:", (attr(a, "obj") - p$opt) / p$opt * 100, "%")
#> optimality gap: 0 %
```
