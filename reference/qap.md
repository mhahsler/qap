# Solve a Quadratic Assignment Problem

Solve a quadratic assignment problem (QAP) with a simulated annealing
heuristic. `qap.obj()` calculates the objective value of an assignment.

## Usage

``` r
qap(A, B, method = NULL, ...)

qap.obj(A, B, o)
```

## Arguments

- A:

  A symmetric matrix of nonnegative flows between facilities.

- B:

  A symmetric matrix of nonnegative distances between locations.

- method:

  Solver name. Currently only `"SA"` is available.

- ...:

  Additional arguments passed to the simulated annealing solver. See
  Details.

- o:

  A permutation vector assigning facilities to locations.

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
facilities to the locations in the order given by the permuation, the
objective can be written as

\$\$\min\_{X \in \Pi}\\ \mathrm{tr}(AXB^TX^T)\$\$

where \\\Pi\\ is the set of all valid \\n \times n\\ permutation
matrices. Note that for symmetric distances, the distance matrix \\B\\
does not need to be transposed.

The QAP originated as a facility location problem (Koopmans and
Beckmann, 1957) and also has applications in data analysis (Hubert and
Schultz, 1976). It is NP-hard. The solver uses the simulated annealing
heuristic of Burkard and Rendl (1984), based on Rendl's Fortran
implementation from QAPLIB. The authors suggest it can produce heuristic
solutions for problems with up to 256 objects, although the
implementation does not enforce this limit.

Additional solver arguments are:

- `rep`:

  Number of restarts; default `1L`.

- `miter`:

  Number of iterations at a fixed temperature; default `2 * nrow(A)`.

- `fiter`:

  Factor by which `miter` grows after each cooling step; default `1.1`.

- `ft`:

  Factor by which the temperature decreases after each cooling step;
  default `0.5` (between 0 and 1).

- `maxsteps`:

  Maximum number of cooling steps; default `50L`.

- `verbose`:

  Print progress; default `FALSE`.

## References

Burkard, R. E. and Rendl, F. (1984). A thermodynamically motivated
simulation procedure for combinatorial optimization problems. *European
Journal of Operational Research*, 17(2), 169-174.
[doi:10.1016/0377-2217(84)90231-5](https://doi.org/10.1016/0377-2217%2884%2990231-5)

Koopmans, T. C. and Beckmann, M. (1957). Assignment problems and the
location of economic activities. *Econometrica*, 25(1), 53-76.
[doi:10.2307/1907742](https://doi.org/10.2307/1907742)

Hubert, L. and Schultz, J. (1976). Quadratic assignment as a general
data analysis strategy. *British Journal of Mathematical and Statistical
Psychology*, 29(2), 190-241.
[doi:10.1111/j.2044-8317.1976.tb00714.x](https://doi.org/10.1111/j.2044-8317.1976.tb00714.x)

## See also

[`read_qaplib()`](https://michael.hahsler.net/qap/reference/read_qaplib.md)

## Examples

``` r
p <- read_qaplib(system.file("qaplib", "had12.dat", package = "qap"))
a <- qap(p$A, p$B, verbose = TRUE)
#> Simulated annealing heuristic by Burkard and Rendl.
#>   rep   best_obj current_obj
#>     1       1676       1676
a
#>  [1]  8 10  2 11 12  7  5  4  3  6  1  9
#> attr(,"obj")
#> [1] 1676
qap.obj(p$A, p$B, a)
#> [1] 1676
(attr(a, "obj") - p$opt) / p$opt * 100
#> [1] 1.452785
```
