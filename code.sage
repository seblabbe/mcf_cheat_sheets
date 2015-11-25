# coding=utf-8
r"""
Code for MCF Algorithms Cheat Sheets
"""
import slabbe.mult_cont_frac as mcf
from slabbe import TikzPicture
import numpy as np
from sage.functions.other import floor

###########
# detect draft or final
###########
with open('_version.txt', 'r') as f:
    s = f.readline()
    if 'draft' in  s:
        VERSION = 'draft'
    elif 'final' in s:
        VERSION = 'final'
    else:
        raise ValueError("should be draft or final not (={})".format(s))

###########
# Global function
###########
@parallel
def algo_to_tex(algo, cylinders_depth=[1,2,3]):
    lines = []
    lines.append(r"\section{%s algorithm}" % algo.name())
    lines.append(r"\subsection{Definition}")
    lines.append(r"\input{def_%s.tex}" % algo.class_name())
    lines.append(r"\subsection{Matrices}")
    lines.append(matrices(algo, ncols=3))
    lines.append(r"\subsection{Cylinders}")
    if VERSION == 'draft':
        cylinders_depth.pop()
    for d in cylinders_depth:
        lines.append(include_graphics_cylinders(algo,d,width=.3))
    lines.append(r"\subsection{Density function}")
    lines.append(input_density(algo))
    lines.append(r"\subsection{Invariant measure}")
    lines.append(include_graphics_inv_measure(algo, n_iterations=10^6,
        ndivs=30, width=.8, ext='pdf'))
    lines.append(r"\subsection{Natural extension}")
    lines.append(include_graphics_nat_ext(algo, n_iterations=1200, marksize=.8,
                                          width=1, ext='png'))
    #lines.append(include_graphics_nat_ext_PIL(algo))
    lines.append(r"\subsection{Lyapunov exponents}")
    if VERSION == 'draft':
        n_iterations=10^6
    else:
        n_iterations=10^8
    lines.append(lyapunov_array(algo, ntimes=30, n_iterations=n_iterations))
    lines.append(r"\subsection{Substitutions}")
    lines.append(substitutions(algo, ncols=3))
    lines.append(r"\subsection{$S$-adic word example}")
    lines.append(s_adic_word(algo, nsubs=10))
    lines.append(r"\subsection{Discrepancy}")
    if VERSION == 'draft':
        length=20
        fontsize=30
        bins=10
    else:
        length=500
        fontsize=20
        bins=20
    lines.append(discrepancy_histogram(algo, length=length, width=.6,
        fontsize=fontsize,figsize=[8,3],bins=bins))
    lines.append(r"\subsection{Dual substitutions}")
    lines.append(dual_substitutions(algo, ncols=3))
    lines.append(r"\subsection{E one star}")
    lines.append(dual_patch(algo, (1,e,pi), minsize=70, nsubs=5,
        height="3cm"))
    lines.append(r"\newpage")
    file_tex = 'section_{}.tex'.format(algo.class_name())
    write_to_file(file_tex, "\n".join(lines))
    with open('sections.tex', 'a') as f:
        f.write(r"\input{{{}}}".format(file_tex)+'\n')
    print "Done with algo {}".format(algo.class_name())

###########
# Functions
###########
def input_density(algo):
    import os
    filename = "density_{}.tex".format(algo.class_name())
    if os.path.exists(filename):
        return r"\input{{{}}}".format(filename)
    else:
        return "Unknown"

def include_graphics_inv_measure(algo, n_iterations=10^6, ndivs=40, width=1, ext='pdf'):
    try:
        fig = algo.invariant_measure_wireframe_plot(n_iterations, 
                           ndivs, norm='1')
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err)
    file = 'density_{}.{}'.format(algo.class_name(), ext)
    fig.savefig(file)
    print "Creation of the file {}".format(file)
    return r"\includegraphics[width={}\linewidth]{{{}}}".format(width, file)

def include_graphics_nat_ext(algo, n_iterations, marksize, width=1, ext='png'):
    try:
        t = algo.natural_extension_tikz(n_iterations, marksize=marksize,
                group_size="2 by 2")
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err)
    file = 'nat_ext_{}.{}'.format(algo.class_name(), ext)
    if ext == 'png':
        print t.png(file)
    elif ext == 'pdf':
        print t.pdf(file)
    else:
        raise ValueError('Unknown extention ext(={})'.format(ext))
    lines = []
    lines.append(r"\input{nat_ext_def.tex}")
    lines.append(r"\includegraphics[width={}"
                  "\linewidth]{{{}}}".format(width, file))
    return '\n'.join(lines)

def include_graphics_cylinders(algo, n, width=.3):
    try:
        cocycle = algo.matrix_cocycle()
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err)
    s = cocycle.tikz_n_cylinders(n, scale=3)
    file = 'cylinders_{}_n{}.pdf'.format(algo.class_name(), n)
    print s.pdf(file)
    return r"\includegraphics[width={}\linewidth]{{{}}}".format(width, file)

def include_graphics_nat_ext_PIL(algo, width=1):
    c = {}
    c[1] = c[2] = c[3] = [0,0,0]
    c[12] = c[13] = c[23] = c[21] = c[31] = c[32] = [255,0,0]
    b = [1,2,3,12,13,21,23,31,32]
    draw = 'image_right'
    n_iterations = 10^3
    P = algo.natural_extension_part_png(n_iterations, draw=draw,
      branch_order=b, color_dict=c, urange=(-.6,.6), vrange=(-.6,.6))
    file = 'nat_ext_{}_{}.png'.format(algo.class_name(), draw)
    P.save(file)
    print "Creation of the file {}".format(file)
    return r"\includegraphics[width={}\linewidth]{{{}}}".format(width, file)

def lyapunov_array(algo, ntimes, n_iterations):
    from slabbe.lyapunov import lyapunov_table
    try:
        T = lyapunov_table(algo, ntimes, n_iterations)
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err)
    lines = []
    lines.append(r"(using {} orbits of ".format(ntimes))
    lines.append(r"{} iterations each)\\".format(n_iterations))
    lines.append(latex(T))
    return "\n".join(lines)

def substitutions(algo, ncols=3):
    try:
        D = algo.substitutions()
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err)
    return dict_to_array(D, ncols, entry_code=r"\sigma_{{{}}}=\left\{{{}\right.")

def dual_substitutions(algo, ncols=3):
    try:
        D = algo.dual_substitutions()
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err)
    return dict_to_array(D, ncols, entry_code=r"\sigma^*_{{{}}}=\left\{{{}\right.")

def matrices(algo, ncols=3):
    try:
        cocycle = algo.matrix_cocycle()
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err)
    D = cocycle.gens()
    entry_code = r"M_{{{}}}={{\arraycolsep=2pt{}}}"
    return dict_to_array(D, ncols, entry_code=entry_code)

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
        return "{}: {}".format(err.__class__.__name__, err)
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

def dual_patch(algo, v, minsize=100, nsubs=5, height="3cm"):
    try:
        n = 2
        P = algo.e_one_star_patch(v, n)
        while len(P) < minsize:
            n += 1
            P = algo.e_one_star_patch(v, n)
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err)
    it = algo.coding_iterator(v)
    s = P.plot_tikz()
    file = 'dual_patch_{}.pdf'.format(algo.class_name())
    print TikzPicture(s).pdf(file)
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
    lines.append(r"\includegraphics[height={}]{{{}}}".format(height, file))
    lines.append(r"\end{center}")
    return '\n'.join(lines)

def unit_cube():
    from sage.combinat.e_one_star import E1Star, Patch, Face
    cube = Patch([Face((1,0,0),1), Face((0,1,0),2), Face((0,0,1),3)])
    s = cube.plot_tikz()
    print TikzPicture(s).pdf('cube.pdf')

def discrepancy_histogram(algo, length, width=.6, fontsize=30,
        figsize=[8,3], bins=10):
    try:
        D = algo.discrepancy_statistics(length)
    except Exception as err:
        return "{}: {}".format(err.__class__.__name__, err)
    H = histogram(D.values(), bins=bins)
    file = 'discrepancy_histo_{}.png'.format(algo.class_name())
    H.save(file, fontsize=fontsize, figsize=figsize)
    print "Creation of the file {}".format(file)
    lines = []
    lines.append(r"Discrepancy \cite{{MR593979}} for all {}".format(len(D)))
    lines.append(" $S$-adic words with directions")
    lines.append("$v\in\mathbb{N}^3_{>0}$")
    lines.append(r"such that $v_1+v_2+v_3={}$:".format(length))
    lines.append(r"\begin{center}")
    lines.append(r"\includegraphics[width={}\linewidth]{{{}}}".format(width, file))
    lines.append(r"\end{center}")
    return '\n'.join(lines)

###################
# Utility functions
###################
def write_to_file(filename, s):
    with open(filename, 'w') as f:
        f.write(s)
        print "Creation of the file {}".format(filename)

###################
# Script
###################
is_script = True
if is_script:
    with open('sections.tex','w') as f:
        # erase this file
        pass
    unit_cube()
    L = [(mcf.Brun(), [1,2,3,4,5,6]),
        (mcf.Poincare(), [1,2,3,4,5]),
        (mcf.Selmer(), [1,2,3,4,5,6]),
        (mcf.FullySubtractive(), [1,2,3,4,5,6]),
        (mcf.ARP(), [1,2,3]),
        (mcf.Reverse(), [1,2,3,4,5,6]),
        (mcf.Cassaigne(), [1,2,3,4,5,6,7,8,9]),
        #(mcf.ArnouxRauzy(), [1,2,3,4,5,6])
        ]
    list(algo_to_tex(L))

