# coding=utf-8
r"""
Call tikz2pdf on all .tikz file in this folder
"""
import os
from sage.parallel.decorate import parallel

@parallel
def tikz_2_pdf(filename):
    os.system("tikz2pdf {}".format(filename))

tikz_files = [f for f in os.listdir('.') if f.endswith('.tikz')]
list(tikz_2_pdf(tikz_files))

