# Urho3D Custom UI Mesh

Description
-----
Custom UI mesh to convert mdl file format into UIBatch and render it using custom shaders in UI render cycle.
### How to UV Map a disk
Simplest way to map it:
1) start with a cylinder model.
2) remove top and bottom caps.
3) UV map the model using cylinderical mapping.
4) select the verts on top of the cylinder and scale in xyz and bring them closer to a desired diameter.
5) select all verts on top and bottom and scale in y (z in some modeling tool but vertically) and flatten to a disk.


### VS2015 Release -- Resolved
I had trouble getting Release build to display the UIMesh properly. Resolved by adding optimization pragma for \_WIN32 in UIMesh.cpp. You don't have to touch any compiler options and shouldn't have any issues. But, let me know if you do.

Screenshot
-----
![alt tag](https://github.com/Lumak/Urho3D-Custom-UI-Mesh/blob/master/screenshot/uimesh.gif)

Thanks To
-----
JTippetts for his *Diablo 3 Resource Bubble* resource. His resource is the best looking thing in this demo.
His resource can be found here - https://github.com/JTippetts/D3ResourceBubbles

Simon Schreibt for his plethora of VFX resources. The Diablo 3 Bubble and the Rime Fire VFX blog can be found at https://simonschreibt.de/


To Build
-----
To build it, unzip/drop the repository into your Urho3D/ folder and build it the same way as you'd build the default Samples that come with Urho3D.
**Built with Urho3D 1.7 tag.**

License
-----
The MIT License (MIT)







