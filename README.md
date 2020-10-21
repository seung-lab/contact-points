[![PyPI version](https://badge.fury.io/py/contact-points.svg)](https://badge.fury.io/py/contact-points)

Contact Points
==============

```python
import contact_points
l1 = 1
l2 = 2
pts = contact_points.find_contact_points(data, l1, l2)
>>> [ (x,y,z), (x,y,z), ... ] # label1, label2, label1, label2
```

A collection of algorithms for finding the contacts between one or more connected components in a 3D labeled image.