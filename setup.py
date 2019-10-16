import setuptools

# NOTE: If contact_points.cpp does not exist:
# cython -3 --fast-fail -v --cplus contact_points.pyx

import numpy as np

setuptools.setup(
  name='contact_points',
  version='0.0.4',
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
  ])