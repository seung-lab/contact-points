from libc.stdint cimport (
  int8_t, int16_t, int32_t, int64_t,
  uint8_t, uint16_t, uint32_t, uint64_t,
)

from libcpp.vector cimport vector
import numpy as np

cdef extern from "contact_points.hpp" namespace "contact_points":
  cdef vector[uint32_t] find_contact_points3d[T](
    T* in_labels, T label1, T label2,
    int64_t sx, int64_t sy, int64_t sz,
    int64_t connectivity
  )

ctypedef fused INTEGER:
  uint8_t
  uint16_t
  uint32_t
  uint64_t
  int8_t
  int16_t
  int32_t
  int64_t

class DimensionError(Exception):
  """The array has the wrong number of dimensions."""
  pass

def _order_data(data):
  order = 'F' if data.flags['F_CONTIGUOUS'] else 'C'

  while len(data.shape) < 3:
    if order == 'C':
      data = data[np.newaxis, ...]
    else: # F
      data = data[..., np.newaxis ]

  if not data.flags['C_CONTIGUOUS'] and not data.flags['F_CONTIGUOUS']:
    data = np.copy(data, order=order)

  shape = list(data.shape)

  # The default C order of 4D numpy arrays is (channel, depth, row, col)
  # col is the fastest changing index in the underlying buffer.
  # fpzip expects an XYZC orientation in the array, namely nx changes most rapidly.
  # Since in this case, col is the most rapidly changing index,
  # the inputs to fpzip should be X=col, Y=row, Z=depth, F=channel
  # If the order is F, the default array shape is fine.
  if order == 'C':
    shape.reverse()

  cdef int sx = shape[0]
  cdef int sy = shape[1]
  cdef int sz = shape[2]

  return data, order, sx, sy, sz


def find_contact_points(data, label1, label2):
  """
  ndarray find_contact_points(data, label1, label2)

  Find all contact points between two labels in
  a 3D labeled volume.

  Required:
    data: Input labels in a 2D or 3D numpy array.
    label1, label2: Two labels we are interested in

  Returns: Array of pairs of coordinates that repesent
    contact points between the two labels. The first
    coordinate in the pair is a label1 coordinate, and
    the second a label2 one.
  """
  dims = len(data.shape)
  if dims not in (1,2,3):
    raise DimensionError("Only 1D, 2D, and 3D arrays supported. Got: " + str(dims))

  if data.size == 0:
    return np.zeros(shape=(0,), dtype=np.uint32)

  data, _, sx, sy, sz = _order_data(data)

  cdef uint8_t[:,:,:] arr_memview8u
  cdef uint16_t[:,:,:] arr_memview16u
  cdef uint32_t[:,:,:] arr_memview32u
  cdef uint64_t[:,:,:] arr_memview64u
  cdef int8_t[:,:,:] arr_memview8
  cdef int16_t[:,:,:] arr_memview16
  cdef int32_t[:,:,:] arr_memview32
  cdef int64_t[:,:,:] arr_memview64

  dtype = data.dtype
  # TODO: Support 18 and 26 connectivity
  connectivity = 6

  if dtype == np.uint64:
    arr_memview64u = data
    contact_points = find_contact_points3d[uint64_t](
      &arr_memview64u[0,0,0], label1, label2,
      sx, sy, sz, connectivity
    )
  elif dtype == np.uint32:
    arr_memview32u = data
    contact_points = find_contact_points3d[uint32_t](
      &arr_memview32u[0,0,0], label1, label2,
      sx, sy, sz, connectivity
    )
  elif dtype == np.uint16:
    arr_memview16u = data
    contact_points = find_contact_points3d[uint16_t](
      &arr_memview16u[0,0,0], label1, label2,
      sx, sy, sz, connectivity
    )
  elif dtype in (np.uint8, np.bool):
    arr_memview8u = data.view(np.uint8)
    contact_points = find_contact_points3d[uint8_t](
      &arr_memview8u[0,0,0], label1, label2,
      sx, sy, sz, connectivity
    )
  elif dtype == np.int64:
    arr_memview64 = data
    contact_points = find_contact_points3d[int64_t](
      &arr_memview64[0,0,0], label1, label2,
      sx, sy, sz, connectivity
    )
  elif dtype == np.int32:
    arr_memview32 = data
    contact_points = find_contact_points3d[int32_t](
      &arr_memview32[0,0,0], label1, label2,
      sx, sy, sz, connectivity
    )
  elif dtype == np.int16:
    arr_memview16 = data
    contact_points = find_contact_points3d[int16_t](
      &arr_memview16[0,0,0], label1, label2,
      sx, sy, sz, connectivity
    )
  elif dtype == np.int8:
    arr_memview8 = data
    contact_points = find_contact_points3d[int8_t](
      &arr_memview8[0,0,0], label1, label2,
      sx, sy, sz, connectivity
    )
  else:
    raise TypeError("Type {} not currently supported.".format(dtype))

  number_contact_sites = int(len(contact_points) / 6)
  return np.reshape(contact_points, newshape=(number_contact_sites, 2, 3))