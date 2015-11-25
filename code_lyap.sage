# coding=utf-8
r"""
Code for MCF Algorithms Cheat Sheets

Lyapunov exponents final table
"""
import slabbe.mult_cont_frac as mcf

#######################
# detect draft or final
#######################
with open('_version.txt', 'r') as f:
    s = f.readline()
    if 'draft' in  s:
        VERSION = 'draft'
    elif 'final' in s:
        VERSION = 'final'
    else:
        raise ValueError("should be draft or final not (={})".format(s))

###########
# Functions
###########
def lyapunov_global_comparison(algos, n_orbits, n_iterations):
    from slabbe.lyapunov import lyapunov_comparison_table
    T = lyapunov_comparison_table(algos, n_orbits, n_iterations)
    lines = []
    lines.append(r"\section{Comparison of Lyapunov exponents}")
    lines.append(r"({} orbits of ".format(n_orbits))
    lines.append(r"{} iterations each)".format(n_iterations))
    lines.append(r"\begin{center}")
    lines.append(latex(T))
    lines.append(r"\end{center}")
    with open('lyapunov_table.tex','w') as f:
        f.write('\n'.join(lines))

###################
# Script
###################
is_script = True
if is_script:
    algos = [mcf.Brun(), mcf.Poincare(), mcf.Selmer(), mcf.FullySubtractive(),
            mcf.ARP(), mcf.Reverse(), mcf.Cassaigne()]
    if VERSION == 'draft':
        n_iterations=10^6
    else:
        n_iterations=10^9
    lyapunov_global_comparison(algos, n_orbits=30, n_iterations=n_iterations)

