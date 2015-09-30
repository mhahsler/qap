
      subroutine qaph4( n, a, b, c, miter, fiter, ft, rep,
     1                  maxdim, ope, ol, bool, perm)
c *** *****************************************************************
c     *                                                               *
c     *  heuristic procedure for solving                              *
c     *  quadratic sum assignment problems                            *
c     *                                                               *
c     *****************************************************************
c     *                                                               *
c     *  1.  call:                                                    *
c     *      subroutine qaph4(n,a,b,miter,fiter,ft,rep,maxdim,ope,    *
c     *                       ol,bool,perm)                           *
c     *                                                               *
c     *  2.  computer code:                                           *
c     *      fortran iv                                               *
c     *                                                               *
c     *  3.  method:                                                  *
c     *      thermodynamically motivated heuristic procedure          *
c     *                                                               *
c     *  4.  parameters:                                              *
c     *                                                               *
c     *      input:                                                   *
c     *        n       dimension of the problem                       *
c     *        a(i,j)  distance matrix (integer)   i,j=1,...,n        *
c     *        b(i,j)  connection matrix (integer) i,j=1,...,n        *
c     *        miter   number of iterations at fixed t (integer)      *
c     *        fiter   multiplication factor for miter after miter    *
c     *                random transposition trials (real, positiv)    *
c     *        ft      multiplication factor for t after miter random *
c     *                transposition trials (real, 0 < ft < 1)        *
c     *        rep     number of restarts (integer)                   *
c     *        maxdim  dimension of arrays a and b in the calling     *
c     *                program (integer)                              *
c     *                                                               *
c     *      output                                                   *
c     *        ope(i)  best permutation found by procedure (integer)  *
c     *                i=1,...n                                       *
c     *        ol      objective function value for ope(i) (integer)  *
c     *                                                               *
c     *      logical array of dimension n                             *
c     *        bool(i)                                                *
c     *                                                               *
c     *  6.  author:                                                  *
c     *      f. rendl                                                 *
c     *                                                               *
c *** *****************************************************************
      integer rep, ol, a(maxdim, 1), b(maxdim, 1), ope(1), perm( 1)
      integer c( maxdim, 1), delta
      logical bool( 1)
      double precision fiter, ft, t, t1, p
      double precision x

c        real ia, ib, ic

c       Initialize R RNG
      CALL getrngstate()


c  evaluate mean t of objective function value
c          write(6,5)
c  5       format(' restart     best        current')
      ia = 0
      ib = 0
      ic = 0
      do 100 i=1,n
      do 100 j=1,n
         ia = ia + a(i,j)
         ic = ic + c(i,j)
  100    ib = ib + b(i,j)
      t = ia / float(n*n-n)
      t = t * ib  + ic / float(n)
      ibest = t
c--------------------------
c  loop over restarts (rep)
c--------------------------
      CALL unifrand(x)
      do 1000 loop=1,rep

c  start with a randoom permutation perm
         call zufall(n, perm, bool)
c  set local variables for t,miter and random number generator
         t1 = t
         m1 = miter
c  evaluate obj. function value corresponding to perm
         ol = 0
         do 200 i = 1,n
            ol = ol + c( i, perm( i))
         do 200 j = 1,n
  200    ol = ol + a(i,j) * b(perm(i),perm(j))

  300 continue
c  set stopping criterion variables min,max
         min = ol
         max = 0
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
            delta = 0
            do 400 j1 = 1,n
               if (j1.eq.i1 .or. j1.eq.i2) goto 400
               kbild = perm(j1)
               delta = delta - (a(i1,j1) - a(i2,j1))
     1                        *(b(ibild,kbild) - b(jbild,kbild))
  400          continue
            delta = 2 * delta - (a(i1,i1) - a(i2,i2))
     1                     *(b(ibild,ibild) - b(jbild,jbild))
            delta = delta - c( i1, ibild) + c( i1, jbild)
            delta = delta - c( i2, jbild) + c( i2, ibild)
c  if obj. function value decreases, perform transposition
            if (delta .le. 0) goto 700
c  generate random variable x and compare with probability p
c  for delta to be accepted
            CALL unifrand(x)
            if (delta/t1 .gt. 10) then
                p = 0
                        else
            p = exp(-delta/t1)
                        endif
            if (x .gt. p) goto 900

  700       continue
c  accept transposition and set new permutation perm
            perm(i1) = jbild
            perm(i2) = ibild
            ol = ol + delta
  800       continue

c  adjust bounds for stopping criterion and store
c  best found solution
            if (ol .lt. min) min = ol
            if (ol .gt. max) max = ol
            if(ibest .lt. ol) goto 900
            ibest = ol
            do 850 j1 = 1,n
  850       ope(j1) = perm(j1)

  900       continue
c--------------------------------
c  adjust iteration control variables m1 and t1
         t1 = t1 * ft
         m1 = m1 * fiter
c  stopping criterion
         if (max .gt. min) goto 300

c         write(6,10) loop, ibest, ol
c   10    format(1x, i5, 2i12)

 1000 continue
c----------------------------------------------------
c  set output variable ol
      ol = ibest

c    Return R RNG
      CALL Putrngstate()


      return
      end

      SUBROUTINE ZUFALL (N,PARTPE,MENGE)
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      INTEGER PARTPE(1)
      LOGICAL MENGE(1)
      double precision az
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      DO 3570 JZE=1,N
         MENGE(JZE) = .FALSE.
 3570 CONTINUE
      NMK = N
      DO 3520 IZE=1,N
         CALL unifrand(az)
         J = az * nmk + 1
         IF(IZE .EQ. 1) GOTO 3590
         IZAEHL = 0
         DO 3530 IZ=1,N
            IF(.NOT. MENGE(IZ)) IZAEHL = IZAEHL+1
            IF(IZAEHL .EQ. J) GOTO 3540
 3530    CONTINUE
 3590    IZ = J
 3540    PARTPE(IZE) = IZ
         MENGE(IZ) = .TRUE.
         NMK = N-IZE
 3520 CONTINUE
      RETURN
      END