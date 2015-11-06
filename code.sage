# coding=utf-8
r"""
Code for MCF Algorithms Cheat Sheets
"""
import slabbe.mult_cont_frac as mcf
import numpy as np
from sage.functions.other import floor

QUICK = True
REFSEGMENT_NUMBER = 1

def algo_to_tex(algo, cylinders_depth=[1,2,3]):
    lines = []
    lines.append(r"\section{%s algorithm}" % algo.name())
    lines.append(r"\begin{refsegment}")
    lines.append(r"\subsection{Definition}")
    lines.append(r"\input{def_%s.tex}" % algo.name())
    lines.append(r"\subsection{Invariant measure}")
    lines.append(include_graphics_inv_measure(algo, n_iterations=10^6, ndivs=40))
    lines.append(r"\subsection{Density function}")
    lines.append(input_density(algo))
    lines.append(r"\subsection{Cylinders}")
    if QUICK:
        cylinders_depth.pop()
    for d in cylinders_depth:
        lines.append(include_graphics_cylinders(algo,d,width=.3))
    lines.append(r"\subsection{Natural extension}")
    lines.append(include_graphics_nat_ext(algo))
    #lines.append(include_graphics_nat_ext_PIL(algo))
    lines.append(r"\subsection{Lyapunov exponents}")
    lines.append(lyapunov_array(algo, ntimes=10, n_iterations=10^6))
    lines.append(r"\subsection{Substitutions}")
    lines.append(substitutions(algo, ncols=3))
    lines.append(r"\subsection{$S$-adic word example}")
    lines.append(s_adic_word(algo, nsubs=10))
    lines.append(r"\subsection{Discrepancy}")
    lines.append(r"TODO")
    lines.append(r"\subsection{Dual substitutions}")
    lines.append(dual_substitutions(algo, ncols=3))
    lines.append(r"\subsection{E one star}")
    lines.append(dual_patch(algo, (1,e,pi), minsize=70, nsubs=5, width=.6))
    lines.append(r"\subsection{Matrices}")
    lines.append(matrices(algo, ncols=2))
    lines.append(r"\end{refsegment}")
    global REFSEGMENT_NUMBER
    lines.append(r"\printbibliography[segment={},".format(REFSEGMENT_NUMBER))
    REFSEGMENT_NUMBER += 1
    lines.append(r"heading=subbibliography,")
    lines.append(r"title={References}]")
    lines.append(r"\newpage")
    file_tex = 'section_{}.tex'.format(algo.name())
    write_to_file(file_tex, "\n".join(lines))
    with open('sections.tex', 'a') as f:
        f.write(r"\input{{{}}}".format(file_tex)+'\n')

def input_density(algo):
    import os
    filename = "density_{}.tex".format(algo.name())
    if os.path.exists(filename):
        return r"\input{{{}}}".format(filename)
    else:
        return "Unknown"

def include_graphics_inv_measure(algo, n_iterations=10^6, ndivs=40, width=1):
    try:
        algo.invariant_measure_plot(n_iterations, ndivs, norm='1')
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err.message)
    file = 'mesure_%s_iter%s_div%s.png' % (algo.name(), n_iterations, ndivs)
    return r"\includegraphics[width={}\linewidth]{{{}}}".format(width, file)

def include_graphics_nat_ext(algo, width=1):
    if QUICK:
        n_iterations = 1200
        marksize = .8
    else:
        n_iterations = 3000
        marksize = .4
    try:
        s = algo.natural_extension_tikz(n_iterations, marksize=marksize,
                group_size="2 by 2")
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err.message)
    file = 'nat_ext_{}'.format(algo.name())
    write_to_file('{}.tikz'.format(file), s)
    return r"\includegraphics[width={}\linewidth]{{{}.pdf}}".format(width, file)

def include_graphics_cylinders(algo, n, width=.3):
    try:
        cocycle = algo.matrix_cocycle()
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err.message)
    s = cocycle.tikz_n_cylinders(n, scale=3)
    file = 'cylinders_{}_n{}'.format(algo.name(), n)
    write_to_file('{}.tikz'.format(file), s)
    return r"\includegraphics[width={}\linewidth]{{{}.pdf}}".format(width, file)

def include_graphics_nat_ext_PIL(algo, width=1):
    c = {}
    c[1] = c[2] = c[3] = [0,0,0]
    c[12] = c[13] = c[23] = c[21] = c[31] = c[32] = [255,0,0]
    b = [1,2,3,12,13,21,23,31,32]
    draw = 'image_right'
    n_iterations = 10^3
    P = algo.natural_extension_part_png(n_iterations, draw=draw,
      branch_order=b, color_dict=c, urange=(-.6,.6), vrange=(-.6,.6))
    file = 'nat_ext_{}_{}.png'.format(algo.name(), draw)
    P.save(file)
    print "Creation of the file {}".format(file)
    return r"\includegraphics[width={}\linewidth]{{{}}}".format(width, file)

def lyapunov_array(algo, ntimes, n_iterations):
    try:
        rep = algo.lyapounov_exponents_sample(ntimes, n_iterations)
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err.message)
    T1, T2, U = map(np.array, rep)
    A = chiffres_significatifs(T1.mean(), T1.std())
    B = chiffres_significatifs(T2.mean(), T2.std())
    C = chiffres_significatifs(U.mean(), U.std())
    lines = []
    lines.append(r"({} experiments of ".format(ntimes))
    lines.append(r"{} iterations each)\\".format(n_iterations))
    lines.append(r"\[")
    lines.append(r"\begin{array}{lrr}")
    lines.append(r" & \text{Mean} & \text{SD}\\")
    lines.append(r"\hline")
    lines.append(r"\theta_1 & {} & {}\\".format(*A))
    lines.append(r"\theta_2 & {} & {}\\".format(*B))
    lines.append(r"1-\theta_2/\theta_1 & {} & {}".format(*C))
    lines.append(r"\end{array}")
    lines.append(r"\]")
    return "\n".join(lines)

def substitutions(algo, ncols=3):
    try:
        D = algo.substitutions()
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err.message)
    return dict_to_array(D, ncols, entry_code=r"\sigma_{{{}}}=\left\{{{}\right.")

def dual_substitutions(algo, ncols=3):
    try:
        D = algo.dual_substitutions()
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err.message)
    return dict_to_array(D, ncols, entry_code=r"\sigma^*_{{{}}}=\left\{{{}\right.")

def matrices(algo, ncols=3):
    try:
        cocycle = algo.matrix_cocycle()
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err.message)
    D = cocycle.gens()
    return dict_to_array(D, ncols, entry_code=r"M_{{{}}}={}")

def dict_to_array(D, ncols=3, entry_code=r"M({})={}"):
    lines = []
    lines.append(r"\[")
    lines.append(r"\begin{array}{%s}" % ('l'*ncols))
    for i,key in enumerate(sorted(D.keys())):
        v = D[key]
        lines.append(entry_code.format(key,latex(v)))
        if i % ncols == ncols-1:
            lines.append(r"\\")
        else:
            lines.append(r"&")
    lines.append(r"\end{array}")
    lines.append(r"\]")
    return '\n'.join(lines)

def s_adic_word(algo, nsubs=5, k=21):
    start = (1,e,pi)
    it = algo.coding_iterator(start)
    try:
        w = algo.s_adic_word(start)
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err.message)
    lines = []
    lines.append(r"Using vector $v={}$:".format(latex(start)))
    lines.append(r"\begin{align*}")
    lines.append(r"w &=")
    for _ in range(nsubs):
        key = next(it)
        lines.append(r"\sigma_{{{}}}".format(key))
    lines.append(r"\cdots(1)\\")
    lines.append(r"& = {}".format(w))
    lines.append(r"\end{align*}")
    C = map(w[:10000].number_of_factors, range(k))  
    lines.append(r"Factor Complexity of $w$ is ")
    lines.append(r"$(p_w(n))_{{0\leq n \leq {}}} =$".format(k-1))
    lines.append(r"\[")
    lines.append(r"({})".format(', '.join(map(str,C))))
    lines.append(r"\]")
    return '\n'.join(lines)

def dual_patch(algo, v, minsize=100, nsubs=5, width=.8):
    try:
        n = 2
        P = algo.e_one_star_patch(v, n)
        while len(P) < minsize:
            n += 1
            P = algo.e_one_star_patch(v, n)
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err.message)
    it = algo.coding_iterator(v)
    s = P.plot_tikz()
    file = 'dual_patch_{}'.format(algo.name())
    write_to_file('{}.tikz'.format(file), s)
    lines = []
    lines.append(r"Using vector $v={}$, the {}-th ".format(latex(v),n))
    lines.append(r"iteration on the unit cube is:")
    lines.append(r"\[")
    for _ in range(nsubs):
        key = next(it)
        lines.append(r"E_1^*(\sigma^*_{{{}}})".format(key))
    if nsubs < n:
        lines.append(r"\cdots")
    lines.append(r"(\includegraphics[width=1em]{cube.pdf})=")
    lines.append(r"\]")
    lines.append(r"\begin{center}")
    lines.append(r"\includegraphics[width={}\linewidth]{{{}.pdf}}".format(width, file))
    lines.append(r"\end{center}")
    return '\n'.join(lines)

def unit_cube():
    from sage.combinat.e_one_star import E1Star, Patch, Face
    cube = Patch([Face((1,0,0),1), Face((0,1,0),2), Face((0,0,1),3)])
    s = cube.plot_tikz()
    write_to_file('cube.tikz', s)

###################
# Utility functions
###################
def write_to_file(filename, s):
    with open(filename, 'w') as f:
        f.write(s)
        print "Creation of the file {}".format(filename)

def chiffres_significatifs(moy, error):
    r"""
    EXAMPLES::

        sage: chiffres_significatifs(123456.78887655, 0.000341)
        '123456.7889\\pm 0.0003'
        sage: chiffres_significatifs(123456.78887655, 341)
        '123500.\\pm 300.'
    """
    s = floor(log(abs(error), 10.))
    chiffre = int(error / (10.**s))
    E = chiffre * (10.**s)
    m = floor(log(abs(moy), 10.))
    rounded_moy = numerical_approx(moy, digits=m-s+1)
    return rounded_moy, str(E).rstrip('0')

###################
# Script
###################
open('sections.tex','w').close()
unit_cube()
algo_to_tex(mcf.Brun(), cylinders_depth=[1,2,3,4])
algo_to_tex(mcf.Poincare(), cylinders_depth=[1,2,3,4])
algo_to_tex(mcf.Selmer(), cylinders_depth=[1,2,3,4,5])
algo_to_tex(mcf.FullySubtractive(), cylinders_depth=[1,2,3,4,5,6])
algo_to_tex(mcf.ARP(), cylinders_depth=[1,2,3])
algo_to_tex(mcf.Reverse(), cylinders_depth=[1,2,3,4,5,6])
algo_to_tex(mcf.Cassaigne(), cylinders_depth=[1,2,3,4,5,6,7,8,9])

#algo_to_tex(mcf.ArnouxRauzy(), cylinders_depth=[1,2,3,4,5,6])
