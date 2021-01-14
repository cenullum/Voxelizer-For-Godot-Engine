# Voxelizer For Godot Engine
 A demo of voxelation which makes 3d mesh from 2d sprites


# Demo Video
[![IMAGE ALT TEXT HERE](https://i.imgur.com/djm9qMS.png)](https://www.youtube.com/watch?v=tlB_bOLxVzQ)

# Demo Introduction
You can drag and drop your image to be voxelated then move this voxelated mesh by using A W S D keys. Also you can give depth value and alpha cut value (alpha_offset) which is for considering a pixel as opaque instead of transparent.


# HOW TO IMPLEMENT TO YOUR OWN PROJECT:

* Add voxelizer.gd to a MeshInstance node
* Set sprite to "Voxel Me" on inspector
* Set TransparentMaterial.tres to "Material" on inspector as script parametre, NOT DIRECTLY
* You can change alpha offset and depth if you want
* If you want to change sprite via code you can use func voxelization() and send sprite as parametre in it


# What voxelizer.gd does?

This code build a wall which is 2 triangles. It does this if there are no pixels nearby by looking at the bottom, top left and right of each pixel of the image then creates transparent up and down faces. These faces have the image of the whole picture.

![alt text](https://img.itch.zone/aW1nLzM5NDM2NTUucG5n/original/a51F9p.png)
