# qap - Heuristics for the Quadratic Assignment Problem (QAP) - R package

[![CRAN version](http://www.r-pkg.org/badges/version/qap)](http://cran.r-project.org/web/packages/qap/index.html)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/qap)](http://cran.r-project.org/web/packages/qap/index.html)
[![Travis-CI Build Status](https://travis-ci.org/mhahsler/qap.svg?branch=master)](https://travis-ci.org/mhahsler/qap)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/mhahsler/qap?branch=master&svg=true)](https://ci.appveyor.com/project/mhahsler/qap)

Implements heuristics for the Quadratic Assignment Problem (QAP). Currently only the simulated annealing heuristic described in 

> R.E. Burkard and F. Rendl. A thermodynamically motivated
> simulation procedure for combinatorial optimization problems.
> _European Journal of Operations Research,_ 17(2):169-174, 1984.

is available. 



## Installation

* __Stable CRAN version:__ install from within R.
* __Current development version:__ Download package from [AppVeyor](https://ci.appveyor.com/project/mhahsler/qap/build/artifacts) or install via `intall_git()` (needs devtools) 

## Example
```
library(qap)

## load the had12 QAPLIB problem (shipped with the package)
p <- read_qaplib(system.file("qaplib", "had12.dat", package="qap"))

## run 100 repetitions
a <- qap(W, D, rep = 100)
a

## compare with known optimum (% above optimum)
(attr(a, "opt") - p$opt)/p$opt * 100
```
