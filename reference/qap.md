# Solve Quadratic Assignment Problems (QAP)

This function implements Quadratic Assignment Problems (QAP) heuristics.
Currently there is only a simulated annealing heuristic available, but
more will be added in the future.

## Usage

``` r
qap(A, B, method = NULL, ...)
qap.obj(A, B, o)
```

## Arguments

- A:

  a symmetric matrix with positive weights/flows between pairs
  facilities.

- B:

  a symmetric matrix with positive distances between pairs of locations.

- method:

  a character string indicating the used solver. Defaults to `"SA"`, the
  currently only available method.

- ...:

  further arguments are passed on to the solver (see details).

- o:

  a permutation vector for the assignment of facilities to locations.

## Details

The QAP is a facilities location problem. Given \\n\\ facilities and
\\n\\ locations with a matrix \\A\\ specifying the flows between
facilities and a matrix \\B\\ with location distances, find the best
facility to location assignment that minimizes the total transportation
cost given as flow times distance. The assignment is represented by a
permutation matrix \\X\\ and the objective is

\$\$\mathrm{min}\_{X \in \Pi}\\ tr(AXBX^T)\$\$

`iqap.obj` calculates the objective function for \\A\\ and \\B\\ with
the permutation `o`.

Although, the QAP was introduced as a combinatorial optimization problem
for the facility location problem in operations research (see Koopmans
and Beckmann;1957), it also has many applications in data analysis (see
Hubert and Schultz; 1976).

The QAP is known to be NP-hard. This function implements the simple
simulated annealing heuristic described by Burkard and Rendl (1984). The
code is based on Rendl's FORTRAN implementation of the algorithm
available at the QAPLIB website. The authors suggests that it can
produce heuristic solutions for QAPs with a dimension of 256 objects or
less. However, this is not a hard limit in the implementation.

The solver has the additional arguments
`rep = 1L, miter = 2 * nrow(A), fiter = 1.1, ft = 0.5` and
`maxsteps = 50L`

- rep:

  integer; number of restarts.

- miter:

  integer; number of iterations at fixed temperature.

- fiter:

  multiplication factor for miter after miter random transposition
  trials.

- ft:

  multiplication factor for t after miter random transposition trials
  (between 0 and 1).

- maxsteps:

  integer; maximal number of allowed cooling steps.

## Value

Returns an integer vector with facility to location assignments. The
objective function value is provided as attribute `"obj"`.

## References

R.E. Burkard and F. Rendl (1984). A thermodynamically motivated
simulation procedure for combinatorial optimization problems. *European
Journal of Operations Research,* 17(2):169-174.
[doi:10.1016/0377-2217(84)90231-5](https://doi.org/10.1016/0377-2217%2884%2990231-5)

Koopmans TC, Beckmann M (1957). Assignment problems and the location of
economic activities. *Econometrica* 25(1):53-76.
[doi:10.2307/1907742](https://doi.org/10.2307/1907742)

Hubert, L., and Schultz, J. (1976). Quadratic assignment as a general
data analysis strategy. *British Journal of Mathematical and Statistical
Psychology,* 29(2), 190-241.
[doi:10.1111/j.2044-8317.1976.tb00714.x](https://doi.org/10.1111/j.2044-8317.1976.tb00714.x)

## Author

Michael Hahsler

## See also

[read_qaplib](http://michael.hahsler.net/qap/reference/read_qaplib.md)

## Examples

``` r
## load the had12 QAPLIB problem
p <- read_qaplib(system.file("qaplib", "had12.dat", package="qap"))
p
#> $A
#>       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12]
#>  [1,]    0    1    2    2    3    4    4    5    3     5     6     7
#>  [2,]    1    0    1    1    2    3    3    4    2     4     5     6
#>  [3,]    2    1    0    2    1    2    2    3    1     3     4     5
#>  [4,]    2    1    2    0    1    2    2    3    3     3     4     5
#>  [5,]    3    2    1    1    0    1    1    2    2     2     3     4
#>  [6,]    4    3    2    2    1    0    2    3    3     1     2     3
#>  [7,]    4    3    2    2    1    2    0    1    3     1     2     3
#>  [8,]    5    4    3    3    2    3    1    0    4     2     1     2
#>  [9,]    3    2    1    3    2    3    3    4    0     4     5     6
#> [10,]    5    4    3    3    2    1    1    2    4     0     1     2
#> [11,]    6    5    4    4    3    2    2    1    5     1     0     1
#> [12,]    7    6    5    5    4    3    3    2    6     2     1     0
#> 
#> $B
#>       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10] [,11] [,12]
#>  [1,]    0    3    4    6    8    5    6    6    5     1     4     6
#>  [2,]    3    0    6    3    7    9    9    2    2     7     4     7
#>  [3,]    4    6    0    2    6    4    4    4    2     6     3     6
#>  [4,]    6    3    2    0    5    5    3    3    9     4     3     6
#>  [5,]    8    7    6    5    0    4    3    4    5     7     6     7
#>  [6,]    5    9    4    5    4    0    8    5    5     5     7     5
#>  [7,]    6    9    4    3    3    8    0    6    8     4     6     7
#>  [8,]    6    2    4    3    4    5    6    0    1     5     5     3
#>  [9,]    5    2    2    9    5    5    8    1    0     4     5     2
#> [10,]    1    7    6    4    7    5    4    5    4     0     7     7
#> [11,]    4    4    3    3    6    7    6    5    5     7     0     9
#> [12,]    6    7    6    6    7    5    7    3    2     7     9     0
#> 
#> $solution
#>  [1]  3 10 11  2 12  5  6  7  8  1  4  9
#> 
#> $opt
#> [1] 1652
#> 

## run 1 repetitions verbose
a <- qap(p$A, p$B, verbose = TRUE)
#> Simulated Annealing Heuristic by Burkart and Rendl.
#>   rep   best_obj current_obj
#>     1       1676       1676
a
#>  [1]  8 10  2 11 12  7  5  4  3  6  1  9
#> attr(,"obj")
#> [1] 1676

## compare with known optimum (gap, % above optimum)
(attr(a, "obj") - p$opt)/p$opt * 100
#> [1] 1.452785

## run more repetitions quietly
a <- qap(p$A, p$B, rep = 100)
a
#>  [1]  3 10 11  2 12  5  6  7  8  1  4  9
#> attr(,"obj")
#> [1] 1652

## compare with known optimum (gap, % above optimum)
(attr(a, "obj") - p$opt)/p$opt * 100
#> [1] 0
```
