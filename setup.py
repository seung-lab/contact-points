import os
import setuptools
import sys

import numpy as np

# NOTE: If contact_points.cpp does not exist:
# cython -3 --fast-fail -v --cplus contact_points.pyx

def read(fname):
  with open(os.path.join(os.path.dirname(__file__), fname), 'rt') as f:
    return f.read()

setuptools.setup(
  name='contact_points',
  version='0.0.6',
  author='Manuel Castro',
  author_email='macastro@princeton.edu',
  setup_requires=['numpy'],
  install_requires=['numpy'],
  ext_modules=[
    setuptools.Extension(
      'contact_points',
      sources=[ 'contact_points.cpp' ],
      depends=['contact_points.hpp'],
      language='c++',
      include_dirs=[ np.get_include() ],
      extra_compile_args=[
        '-std=c++11', '-O3', '-ffast-math'
      ]
    )
  ],
  packages=setuptools.find_packages(),
  description="Find contact points in a 3D Volume.",
  long_description=read('README.md'),
  long_description_content_type="text/markdown",
  keywords = "contact-points connected-components volumetric-data numpy connectomics image-processing biomedical-image-processing 2d 3d",
  url = "https://github.com/seung-lab/contact-points",
  classifiers=[
    "Intended Audience :: Developers",
    "Development Status :: 3 - Alpha",
    "Programming Language :: Python",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.6",
    "Programming Language :: Python :: 3.7",
    "Programming Language :: Python :: 3.8",
    "Topic :: Scientific/Engineering",
    "Intended Audience :: Science/Research",
    "Operating System :: POSIX",
    "Operating System :: MacOS",
    "Operating System :: Microsoft :: Windows :: Windows 10",
  ], 
)