# coding=utf-8
r"""
Code for MCF Algorithms Cheat Sheets
"""
import slabbe.mult_cont_frac as mcf
import numpy as np
from sage.functions.other import floor

def write_to_file(filename, s):
    with open(filename, 'w') as f:
        f.write(s)
        print "Creation of the file {}".format(filename)

def algo_to_tex(algo, quick=True):
    n_iterations = 10^6
    ndivs = 40

    # File 1 : Invariant measure
    algo.invariant_measure_plot(n_iterations, ndivs, norm='1')
    file1 = 'mesure_%s_iter%s_div%s.png' % (algo.name(), n_iterations, ndivs)

    # File 2 : Natural extension
    file2 = create_file_natural_extension(algo, quick)
    #file2 = create_file_natural_extension_PIL(algo)

    # Data 3 : Lyapunov exponents
    ntimes = 10
    n_iterations = 10^6
    data = lyapunov(algo, ntimes, n_iterations)

    # Substitutions
    try:
        subs = substitutions(algo)
    except NotImplementedError:
        subs = "TODO (not implemented)"

    # latex code
    lines = []
    lines.append(r"\section{%s algorithm}" % algo.name())
    lines.append(r"\subsection{Definition}")
    lines.append(r"TODO")
    lines.append(r"\subsection{Invariant measure}")
    lines.append(r"\includegraphics[width=\linewidth]{%s}" % file1)
    lines.append(r"\subsection{Density function}")
    lines.append(r"TODO")
    lines.append(r"\subsection{Natural extension}")
    lines.append(r"\includegraphics[width=\linewidth]{%s}" % file2)
    lines.append(r"\subsection{Lyapunov exponents}")
    lines.append(data)
    lines.append(r"\subsection{Substitutions}")
    lines.append(subs)
    lines.append(r"\newpage")
    file_tex = 'section_{}.tex'.format(algo.name())
    write_to_file(file_tex, "\n".join(lines))

def create_file_natural_extension(algo, quick=True):
    if quick:
        n_iterations = 1000
        marksize = 1
    else:
        n_iterations = 3000
        marksize = .4
    s = algo.natural_extension_tikz(3000, marksize=.4, group_size="2 by 2")
    file2 = 'nat_ext_{}'.format(algo.name())
    file2_tikz = '{}.tikz'.format(file2)
    file2_pdf = '{}.pdf'.format(file2)
    write_to_file(file2_tikz, s)
    return file2_pdf

def create_file_natural_extension_PIL(algo):
    c = {}
    c[1] = c[2] = c[3] = [0,0,0]
    c[12] = c[13] = c[23] = c[21] = c[31] = c[32] = [255,0,0]
    b = [1,2,3,12,13,21,23,31,32]
    draw = 'image_right'
    n_iterations = 10^3
    P = algo.natural_extension_part_png(n_iterations, draw=draw,
      branch_order=b, color_dict=c, urange=(-.6,.6), vrange=(-.6,.6))
    filename = 'nat_ext_{}_{}'.format(algo.name(), draw)
    P.save(filename)
    print "Creation of the file {}".format(filename)
    return filename

def lyapunov(algo, ntimes, n_iterations):
    rep = algo.lyapounov_exponents_sample(ntimes, n_iterations)
    T1, T2, U = map(np.array, rep)
    A = moy_error_to_plus_moins_notation(T1.mean(), 2*T1.std())
    B = moy_error_to_plus_moins_notation(T2.mean(), 2*T2.std())
    C = moy_error_to_plus_moins_notation(U.mean(), 2*U.std())
    lines = []
    lines.append(r"({} experiments of {} iterations each)\\".format(ntimes, n_iterations))
    lines.append(r"\[")
    lines.append(r"\begin{array}{lr}")
    lines.append(r" & \mu \pm 2\sigma \\")
    lines.append(r"\hline")
    lines.append(r"\theta_1 & {}\\".format(A))
    lines.append(r"\theta_2 & {}\\".format(B))
    lines.append(r"1-\theta_2/\theta_1 & {}".format(C))
    lines.append(r"\end{array}")
    lines.append(r"\]")
    return "\n".join(lines)

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

def substitutions(algo):
    lines = []
    for (k,v) in algo.substitutions().iteritems():
        lines.append(r"$\sigma(%s)=\left\{%s\right.$\\" % (k,latex(v)))
    return '\n'.join(lines)

algo_to_tex(mcf.ARP())
algo_to_tex(mcf.Brun())
algo_to_tex(mcf.Cassaigne())
algo_to_tex(mcf.ARrevert())

