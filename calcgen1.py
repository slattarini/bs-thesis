#!/usr/bin/python
import sys

def doit(m, maxtry=100,verbose=False):
    m = long(m)
    t = long(1)
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
        if A % 4 == 2:
            k = (A - 2) / 4
            return (t, k)
        t += 2
    return (None, None)

def go(m, f=None, maxtry=100):
    (t, k) = doit(m, verbose=True, maxtry=maxtry)
    if t is None:
        print "---"
        print "problem not solved for m=%u, with maxtry=%u" % (m, maxtry)
        if m != 14:
            if not f is None:
                f.write("\\item[!!!] $m = %u$~~\\textbf{{\\large UNSOLVED!!}}\n\n" % m)
        else:
            f.write("\\item[$\\bullet$]\:$\\pmb{m} \\boldsymbol{=} \\pmb{14}$\\," + 
                    "\\textbf{:}~~$\hh{14}$ isn't norm-euclidean by " +
                    "theorem~(\\ref{h(sqrt(14)) not norm-euclidean}).\n\n")
        return
    t2 = t**2
    A = 4 * k + 2
    L = (m, A, m*A, t2, m*(A+1), m, A+1)
    print "---"
    print "m=%u" % m
    print "t=%s, k=%s" % (t, k)
    print """\
In fact:
  # %u = 4 * %u + 2
  # %u^2 = %u
  # %u * %u = %u < %u < %u = %u * %u\
""" % ((A, k, t, t2) + L)
    if f is None:
        return
    f.write("\\item[$\\bullet$]\:$\\pmb{m} \\boldsymbol{=} ")
    f.write("\\pmb{%u}$\\,\\textbf{:}~~" % m)
    f.write("It suffices to apply by theorem~(\\ref{BIG}) ")
    f.write("with \\,$k = %u$\\, and \\,$t = %u$,\\, as " % (k,t))
    if k > 0:
        f.write("\\,$%u = 4 \\cdot %u + 2$\\, and " % (A, k))
    f.write("\\,${%u}^2 = %u$\\, and:\n" % (t,t2))
    f.write("$$ %u \\cdot %u = %u < %u < %u = %u \\cdot %u $$\n\n" % L)
 
###########################################################################

L = [ 10, 14, 22, 26, 30, 34, 38 ]

f = open("calcgen1.tex","w")
f.write("%%***\n")
f.write("%%*** this file has been automatically generated.")
f.write(" DO NOT EDIT BY HAND!\n")
f.write("%%***\n\n")
f.write("\\begin{itemize}\n\n")
for i in L:
    go(i, f=f, maxtry=3000)
f.write("\\end{itemize}\n\n")
f.close()

