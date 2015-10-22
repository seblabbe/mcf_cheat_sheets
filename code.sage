# coding=utf-8
r"""
Code for MCF Algorithms Cheat Sheets
"""
import slabbe.mult_cont_frac as mcf
import numpy as np
from sage.functions.other import floor

def algo_to_tex(algo, quick=True, cylinders_depth=[1,2,3]):
    lines = []
    lines.append(r"\section{%s algorithm}" % algo.name())
    lines.append(r"\subsection{Definition}")
    lines.append(r"\input{def_%s.tex}" % algo.name())
    lines.append(r"\subsection{Invariant measure}")
    lines.append(include_graphics_inv_measure(algo, n_iterations=10^6, ndivs=40))
    lines.append(r"\subsection{Density function}")
    lines.append(input_density(algo))
    lines.append(r"\subsection{Cylinders}")
    for d in cylinders_depth:
        lines.append(include_graphics_cylinders(algo,d,width=.3))
    lines.append(r"\subsection{Natural extension}")
    lines.append(include_graphics_nat_ext(algo, quick))
    #lines.append(include_graphics_nat_ext_PIL(algo))
    lines.append(r"\subsection{Lyapunov exponents}")
    lines.append(lyapunov_array(algo, ntimes=10, n_iterations=10^6))
    lines.append(r"\subsection{Substitutions}")
    lines.append(substitutions(algo, ncols=3))
    lines.append(r"\subsection{Matrices}")
    lines.append(matrices(algo, ncols=2))
    lines.append(r"\newpage")
    file_tex = 'section_{}.tex'.format(algo.name())
    write_to_file(file_tex, "\n".join(lines))

def input_density(algo):
    import os
    filename = "density_{}.tex".format(algo.name())
    if os.path.exists(filename):
        return r"\input{{{}}}".format(filename)
    else:
        return "Unknown"

def include_graphics_inv_measure(algo, n_iterations=10^6, ndivs=40, width=1):
    algo.invariant_measure_plot(n_iterations, ndivs, norm='1')
    file = 'mesure_%s_iter%s_div%s.png' % (algo.name(), n_iterations, ndivs)
    return r"\includegraphics[width={}\linewidth]{{{}}}".format(width, file)

def include_graphics_nat_ext(algo, quick=True, width=1):
    if quick:
        n_iterations = 500
        marksize = 2
    else:
        n_iterations = 3000
        marksize = .4
    s = algo.natural_extension_tikz(3000, marksize=.4, group_size="2 by 2")
    file = 'nat_ext_{}'.format(algo.name())
    write_to_file('{}.tikz'.format(file), s)
    return r"\includegraphics[width={}\linewidth]{{{}.pdf}}".format(width, file)

def include_graphics_cylinders(algo, n, width=.3):
    try:
        cocycle = algo.matrix_cocycle()
    except NotImplementedError:
        return "TODO (not implemented)"
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
    rep = algo.lyapounov_exponents_sample(ntimes, n_iterations)
    T1, T2, U = map(np.array, rep)
    A = moy_error_to_plus_moins_notation(T1.mean(), 2*T1.std())
    B = moy_error_to_plus_moins_notation(T2.mean(), 2*T2.std())
    C = moy_error_to_plus_moins_notation(U.mean(), 2*U.std())
    lines = []
    lines.append(r"({} experiments of {} iterations each)\\".format(ntimes, n_iterations))
    lines.append(r"\[")
    lines.append(r"\begin{array}{lr}")
    lines.append(r" & \text{Mean} \pm 2\cdot\text{SD}\\")
    lines.append(r"\hline")
    lines.append(r"\theta_1 & {}\\".format(A))
    lines.append(r"\theta_2 & {}\\".format(B))
    lines.append(r"1-\theta_2/\theta_1 & {}".format(C))
    lines.append(r"\end{array}")
    lines.append(r"\]")
    return "\n".join(lines)

def substitutions(algo, ncols=3):
    try:
        D = algo.substitutions()
    except NotImplementedError:
        return "TODO (not implemented)"
    lines = []
    lines.append(r"\[")
    lines.append(r"\begin{array}{%s}" % ('l'*ncols))
    for i,key in enumerate(sorted(D.keys())):
        v = D[key]
        lines.append(r"\sigma(%s)=\left\{%s\right." % (key,latex(v)))
        if i % ncols == ncols-1:
            lines.append(r"\\")
        else:
            lines.append(r"&")
    lines.append(r"\end{array}")
    lines.append(r"\]")
    return '\n'.join(lines)

def matrices(algo, ncols=3):
    try:
        cocycle = algo.matrix_cocycle()
    except NotImplementedError:
        return "TODO (not implemented)"
    D = cocycle.gens()
    lines = []
    lines.append(r"\[")
    lines.append(r"\begin{array}{%s}" % ('l'*ncols))
    for i,key in enumerate(sorted(D.keys())):
        v = D[key]
        lines.append(r"M({})={}".format(key,latex(v)))
        if i % ncols == ncols-1:
            lines.append(r"\\")
        else:
            lines.append(r"&")
    lines.append(r"\end{array}")
    lines.append(r"\]")
    return '\n'.join(lines)

###################
# Utility functions
###################
def write_to_file(filename, s):
    with open(filename, 'w') as f:
        f.write(s)
        print "Creation of the file {}".format(filename)

def moy_error_to_plus_moins_notation(moy, error):
    r"""
    EXAMPLES::

        sage: moy_error_to_plus_moins_notation(123456.78887655, 0.000341)
        '123456.7889\\pm 0.0003'
        sage: moy_error_to_plus_moins_notation(123456.78887655, 341)
        '123500.\\pm 300.'
    """
    s = floor(log(abs(error), 10.))
    chiffre = int(error / (10.**s))
    E = chiffre * (10.**s)
    m = floor(log(abs(moy), 10.))
    rounded_moy = numerical_approx(moy, digits=m-s+1)
    s = r"{}\pm {}".format(rounded_moy, E)
    return s.rstrip('0')

###################
# Script
###################
algo_to_tex(mcf.ARP(), cylinders_depth=[1,2,3])
algo_to_tex(mcf.Brun(), cylinders_depth=[1,2,3,4])
algo_to_tex(mcf.Cassaigne(), cylinders_depth=[1,2,3,4,5,6,7,8,9])
algo_to_tex(mcf.ARrevert(), cylinders_depth=[1,2,3,4,5,6])

