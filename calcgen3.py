#!/usr/bin/python
import sys

def doit(m, maxtry=100,verbose=False):
    m = long(m)
    t = long(3)
    class Try(object):
        t = 0
    if maxtry is None or maxtry < 0:
        def tryagain():
            Try.t += 1
            return True
    elif maxtry >= 0:
        def tryagain():
            if Try.t < maxtry:
                Try.t += 1
                return True
            else:
                return False
    while tryagain():
        A = (t**2 / m) # this is integer division
        if verbose:
            print >>sys.stderr, "Try n.%03u:%5s t=%-5u A=%-5u" % (Try.t, "", t, A)
        if A % 36 in (6,11,23,30):
            return (t,A)
        t += 6
    return (None, None)

def go(m, f=None, maxtry=100):
    (t, A) = doit(m, verbose=True, maxtry=maxtry)
    if t is None:
        print "---"
        print "problem not solved for m=%u, with maxtry=%u" % (m, maxtry)
        if not f is None:
            f.write("\\item[!!!] $m = %u$~~\\textbf{{\\large UNSOLVED!!}}\n\n" % m)
        return
    t2 = t**2
    L = (t, t / 6, t % 6, A, A / 36, A % 36, t, t2, m, A, m*A, t2, m*(A+1), m, A+1)
    print "---"
    print "m=%u" % m
    print "t=%s, A=%s" % (t, A)
    print """\
In fact:
  # %u = %u * 6 + %u
  # %u = 36 * %u + %u
  # %u^2 = %u
  # %u * %u = %u < %u < %u = %u * %u\
""" % L 
    if f is None:
        return
    f.write("\\item[$\\bullet$]\:$\\pmb{m} \\boldsymbol{=} ")
    f.write("\\pmb{%u}$\\,\\textbf{:}~~" % m)
    f.write("It suffices to apply theorem~(\\ref{SMALL}) ")
    f.write("with \\,$A = %u$\\, and \\,$t = %u$,\\, as:\n\n" % (A,t))
    f.write("""\
\\begin{itemize}

  \\item[$\\circ$] $%u = %u \\cdot 6 + %u$

  \\item[$\\circ$] $%u = 36 \\cdot %u + %u$

  \\item[$\\circ$] ${%u}^2 = %u$

  \\item[$\\circ$] $%u \\cdot %u = %u < %u < %u = %u \\cdot %u$

\\end{itemize}\n\n
""" % L)

###########################################################################

L = [
    53,
    77,
    101,
    149,
    173,
    197,
    221,
    269,
    293,
    317,
    341,
    365,
    389,
    413,
    437,
    461,
    485,
    509,
    533,
    557,
    581,
    629,
    653,
    677,
    701,
    749,
    773,
    797,
    821,
    869,
    893,
    917,
]
f = open("calcgen3.tex","w")
f.write("%%***\n")
f.write("%%*** this file has been automatically generated.")
f.write(" DO NOT EDIT BY HAND!\n")
f.write("%%***\n\n")
f.write("\\begin{itemize}\n\n")
for i in L:
    go(i, f=f, maxtry=3000)
f.write("\\end{itemize}\n\n")
f.close()

