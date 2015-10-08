# qap - Heuristics for the Quadratic Assignment Problem (QAP) - R package

[![CRAN version](http://www.r-pkg.org/badges/version/qap)](http://cran.r-project.org/web/packages/qap/index.html)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/qap)](http://cran.r-project.org/web/packages/qap/index.html)
[![Travis-CI Build Status](https://travis-ci.org/mhahsler/qap.svg?branch=master)](https://travis-ci.org/mhahsler/qap)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/mhahsler/qap?branch=master&svg=true)](https://ci.appveyor.com/project/mhahsler/qap)

Implements heuristics for the Quadratic Assignment Problem (QAP). Currently only a simulated annealing heuristic described in 

> R.E. Burkard and F. Rendl. A thermodynamically motivated
> simulation procedure for combinatorial optimization problems.
> _European Journal of Operations Research,_ 17(2):169-174, 1984.

is available. 


## Installation
The stable version of this package can be installed from CRAN.
You can install the development version of the package directly from github. 
Open R and execute the following

```
## install and load devtools
install.packages("devtools")
library(devtools)

## install qap
install_github("mhahsler/qap")
```
_Note:_ You will need a working development environment. For Linux you need a compiler and various libraries, for Windows install [Rtools](http://cran.r-project.org/bin/windows/Rtools/), and for OS X you need to install [Xcode](http://developer.apple.com/xcode/).

## Simple Example
Now you can sove a QAP from QAPLIB
```
## load the had12 QAPLIB problem
p <- read_qaplib(system.file("qaplib", "had12.dat", package="qap"))

## run 100 repetitions
a <- qap(W, D, rep = 100)
a

## compare with known optimum (% above optimum)
(attr(a, "opt") - p$opt)/p$opt * 100
```
