# Read QAPLIB Files

Reads example file in the format used by QAPLIB.

## Usage

``` r
read_qaplib(file)
```

## Arguments

- file:

  file name.

## Details

Problems end with the extension `.dat` and solutions with `.sln`. The
code tries to read the problem and, if available in the same directory,
it also reads the solution and the known optimal value from the solution
file.

The package contains a copy of the problem instances and solutions from
QAPLIB. The data is stored in the package in directory `qaplib`.

## Value

Returns a list with the components

- D:

  distance matrix.

- W:

  weight matrix.

- solution:

  a known optimal solution (if available).

- opt:

  known optimal value (if available).

## References

R.E. Burkard, E. Cela, S.E. Karisch and F. Rendl, QAPLIB - A Quadratic
Assignment Problem Library,
<https://coral.ise.lehigh.edu/data-sets/qaplib/>

## Author

Michael Hahsler

## Examples

``` r
## load a QAPLIB problem instance
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

## list all QAPLIB instances
dir(system.file("qaplib", package="qap"), pattern = "*.dat")
#>   [1] "bur26a.dat"  "bur26b.dat"  "bur26c.dat"  "bur26d.dat"  "bur26e.dat" 
#>   [6] "bur26f.dat"  "bur26g.dat"  "bur26h.dat"  "chr12a.dat"  "chr12b.dat" 
#>  [11] "chr12c.dat"  "chr15a.dat"  "chr15b.dat"  "chr15c.dat"  "chr18a.dat" 
#>  [16] "chr18b.dat"  "chr20a.dat"  "chr20b.dat"  "chr20c.dat"  "chr22a.dat" 
#>  [21] "chr22b.dat"  "chr25a.dat"  "els19.dat"   "esc128.dat"  "esc16a.dat" 
#>  [26] "esc16b.dat"  "esc16c.dat"  "esc16d.dat"  "esc16e.dat"  "esc16f.dat" 
#>  [31] "esc16g.dat"  "esc16h.dat"  "esc16i.dat"  "esc16j.dat"  "esc32a.dat" 
#>  [36] "esc32b.dat"  "esc32c.dat"  "esc32d.dat"  "esc32e.dat"  "esc32g.dat" 
#>  [41] "esc32h.dat"  "esc64a.dat"  "had12.dat"   "had14.dat"   "had16.dat"  
#>  [46] "had18.dat"   "had20.dat"   "kra30a.dat"  "kra30b.dat"  "kra32.dat"  
#>  [51] "lipa20a.dat" "lipa20b.dat" "lipa30a.dat" "lipa30b.dat" "lipa40a.dat"
#>  [56] "lipa40b.dat" "lipa50a.dat" "lipa50b.dat" "lipa60a.dat" "lipa60b.dat"
#>  [61] "lipa70a.dat" "lipa70b.dat" "lipa80a.dat" "lipa80b.dat" "lipa90a.dat"
#>  [66] "lipa90b.dat" "nug12.dat"   "nug14.dat"   "nug15.dat"   "nug16a.dat" 
#>  [71] "nug16b.dat"  "nug17.dat"   "nug18.dat"   "nug20.dat"   "nug21.dat"  
#>  [76] "nug22.dat"   "nug24.dat"   "nug25.dat"   "nug27.dat"   "nug28.dat"  
#>  [81] "nug30.dat"   "rou12.dat"   "rou15.dat"   "rou20.dat"   "scr12.dat"  
#>  [86] "scr15.dat"   "scr20.dat"   "sko100a.dat" "sko100b.dat" "sko100c.dat"
#>  [91] "sko100d.dat" "sko100e.dat" "sko100f.dat" "sko42.dat"   "sko49.dat"  
#>  [96] "sko56.dat"   "sko64.dat"   "sko72.dat"   "sko81.dat"   "sko90.dat"  
#> [101] "ste36a.dat"  "ste36b.dat"  "ste36c.dat"  "tai100a.dat" "tai100b.dat"
#> [106] "tai10a.dat"  "tai10b.dat"  "tai12a.dat"  "tai12b.dat"  "tai150b.dat"
#> [111] "tai15a.dat"  "tai15b.dat"  "tai17a.dat"  "tai20a.dat"  "tai20b.dat" 
#> [116] "tai256c.dat" "tai25a.dat"  "tai25b.dat"  "tai30a.dat"  "tai30b.dat" 
#> [121] "tai35a.dat"  "tai35b.dat"  "tai40a.dat"  "tai40b.dat"  "tai50a.dat" 
#> [126] "tai50b.dat"  "tai60a.dat"  "tai60b.dat"  "tai64c.dat"  "tai80a.dat" 
#> [131] "tai80b.dat"  "tho150.dat"  "tho30.dat"   "tho40.dat"   "wil100.dat" 
#> [136] "wil50.dat"  
```
