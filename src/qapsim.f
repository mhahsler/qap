c *** *****************************************************************
c     *  heuristic procedure for solving                              *
c     *  quadratic sum assignment problems                            *
c     *                                                               *
c     *  Based on code by F. Rendl modified by M. Hahsler             *
c     *                                                               *
c     *        n       dimension of the problem                       *
c     *        a(i,j)  distance matrix             i,j=1,...,n        *
c     *        b(i,j)  connection matrix           i,j=1,...,n        *
c     *        m
c     *        fiter   multiplication factor for miter after miter    *
c     *                random transposition trials (positiv)          *
c     *        ft      multiplication factor for t after miter random *
c     *                transposition trials       (0 < ft < 1)        *
c     *        perm    initial random permutation                     *
c     *                                                               *
c     *      output                                                   *
c     *        ope(i)  best permutation found by procedure (integer)  *
c     *                i=1,...n                                       *
c     *        ol      objective function value for ope(i) (double)   *
c *** *****************************************************************

      subroutine qaph4(n, a, b, miter, fiter, ft,
     1                  ope, ol, perm, maxsteps)

      integer n, maxsteps, step
      integer ope(n), perm(n), miter
      double precision fiter, ft
      integer i, j, ibild, jbild, kbild, i1, i2, j1
      double precision x, t, t1, p
      double precision ol, min, max, delta, ibest
      double precision a(n, n), b(n, n)
      double precision ia, ib

      step = 0

c       Initialize R RNG
      CALL getrngstate()

c  evaluate mean t of objective function value
      ia = 0
      ib = 0
      do 100 i=1,n
      do 100 j=1,n
         ia = ia + a(i,j)
  100    ib = ib + b(i,j)
      t = ia / DBLE(n*n-n)
      t = t * ib
      ibest = t

c  set local variables for t,miter and random number generator
      t1 = t
      m1 = miter
c  evaluate obj. function value corresponding to perm
      ol = 0
      do 200 i = 1,n
      do 200 j = 1,n
  200 ol = ol + a(i,j) * b(perm(i),perm(j))

  300 continue
c  set stopping criterion variables min,max
      min = ol
c      max = 0
c     set max to the smallest double
      max = -1.797693D+308
c--------------------------------------------
c  perform m1 random trials with t1 constant
c--------------------------------------------

      do 900 i = 1,m1

c  check for R user interrupt
         CALL rchkusr()

c  generate two random variables i1,i2 out of (1,2,...,n)
         CALL unifrand(x)
         i1 = x*n + .5
         if (i1 .lt. 1) i1 = 1
         ibild = perm(i1)

         CALL unifrand(x)
         i2 = x*n + .5
         if (i2 .lt. 1) i2 = 1
         if (i1 .eq. i2) goto 800
         jbild = perm(i2)

c  evaluate change in obj. function value corresponding to
c  transposition of perm(i1) and perm(i2)
c  NOTE: the following only works for symmetric A and B
         delta = 0
         do 400 j1 = 1,n
            if (j1.eq.i1 .or. j1.eq.i2) goto 400
            kbild = perm(j1)
            delta = delta - (a(i1,j1) - a(i2,j1))
     1                     *(b(ibild,kbild) - b(jbild,kbild))
  400       continue
         delta = 2 * delta - (a(i1,i1) - a(i2,i2))
     1                  *(b(ibild,ibild) - b(jbild,jbild))

c  if obj. function value decreases, perform transposition
         if (delta .le. 0) goto 700
c  generate random variable x and compare with probability p
c  for delta to be accepted
         if (delta/t1 .gt. 10) then
             p = 0
         else
             p = exp(-delta/t1)
         endif
         CALL unifrand(x)
         if (x .gt. p) goto 900
  700    continue

c  accept transposition and set new permutation perm
         perm(i1) = jbild
         perm(i2) = ibild
         ol = ol + delta
  800    continue

c  adjust bounds for stopping criterion and store
c  best found solution
         if (ol .lt. min) min = ol
         if (ol .gt. max) max = ol
         if(ibest .lt. ol) goto 900
         ibest = ol
         do 850 j1 = 1,n
  850    ope(j1) = perm(j1)
  900    continue

c  adjust iteration control variables m1 and t1
      t1 = t1 * ft
      m1 = m1 * fiter

c  DEBUG
c      write(6,12) step, min, max, ol
c   12 format(I10, E20.5, E20.5, E20.5)

c  stopping criterion
      step = step + 1
      if (max .gt. min .and. step .lt. maxsteps) goto 300

c  set output variable ol
      ol = ibest

c    Return R RNG
      CALL Putrngstate()

      return
      end
