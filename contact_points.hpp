#ifndef CONTACT_POINTS_HPP
#define CONTACT_POINTS_HPP 

#include <functional>
#include <vector>

namespace contact_points {

template <typename T>
std::vector<uint32_t> find_contact_points3d_6(
    T* data, T label1, T label2,
    const int64_t sx, const int64_t sy, const int64_t sz
  ) {

  const int64_t sxy = sx * sy;

  /*
    Layout of forward pass mask (which faces backwards).
    N is the current location.

    z = -1     z = 0
    A B C      J K L   y = -1
    D E F      M N     y =  0
    G H I              y = +1
   -1 0 +1    -1 0   <-- x axis
  */

  // Z - 1
  const int64_t E = -sxy;

  // Current Z
  const int64_t K = -sx;
  const int64_t M = -1;

  int64_t loc = 0;
  std::vector<uint32_t> contact_points;

  auto add_contact_point = [&] (T point1_label, int64_t xcoord, int64_t ycoord,
    int64_t zcoord,  T point2_label, int64_t xcoord2,
    int64_t ycoord2, int64_t zcoord2
  ) {
    if (point1_label == label1) {
      uint32_t coords[6] = {
        static_cast<uint32_t>(xcoord), 
        static_cast<uint32_t>(ycoord), 
        static_cast<uint32_t>(zcoord), 
        static_cast<uint32_t>(xcoord2), 
        static_cast<uint32_t>(ycoord2), 
        static_cast<uint32_t>(zcoord2)
      };
      contact_points.insert(contact_points.end(), coords, std::end(coords));
    } else {
      uint32_t coords[6] = {
        static_cast<uint32_t>(xcoord2), 
        static_cast<uint32_t>(ycoord2), 
        static_cast<uint32_t>(zcoord2),        
        static_cast<uint32_t>(xcoord), 
        static_cast<uint32_t>(ycoord), 
        static_cast<uint32_t>(zcoord)
      };
      contact_points.insert(contact_points.end(), coords, std::end(coords));
    }
  };


  for (int64_t z = 0; z < sz; z++) {
    for (int64_t y = 0; y < sy; y++) {
      for (int64_t x = 0; x < sx; x++) {
        loc = x + sx * (y + sy * z);
        const T cur = data[loc];
        if (cur == label1 || cur == label2) {
          const T test_value = (cur == label1) ? label2 : label1;
          if (x > 0 && data[loc + M] == test_value) {
            add_contact_point(cur, x, y, z, test_value, x-1, y, z);
          }
          if (y > 0 && data[loc + K] == test_value) {
            add_contact_point(cur, x, y, z, test_value, x, y-1, z);
          }
          if (z > 0 && data[loc + E] == test_value) {
            add_contact_point(cur, x, y, z, test_value, x, y, z-1);
          }
        }
      }
    }
  }

  return contact_points;
}

template <typename T>
std::vector<uint32_t> find_contact_points3d(
    T* data, T label1, T label2,
    const int64_t sx, const int64_t sy, const int64_t sz,
    const int64_t connectivity
  ) {
  if (connectivity == 6) {
    return find_contact_points3d_6<T>(
      data, label1, label2, sx, sy, sz
    );
  }
  else {
    throw "Currently, only 6 3D connectivity is supported.";
  }
}

};

#endif