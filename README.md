# KIMP
KnightOS Image Manipulation Program

![KIMP](https://sr.ht/QSLM.png)

Just a small project for me to mess around with for KnightOS. A basic grid-based pixel-art/sprite editor. General idea is the first screen has a 'name' field and a 'size' field (#x# like 30x30), and the program would be saved in a binary file (literal 1's and 0's).

Example:

4x4 Image

[ ][x][x][ ]

[x][ ][ ][x]

[x][ ][ ][x]

[ ][x][x][ ]

would save to

0 1 1 0
1 0 0 1
1 0 0 1
0 1 1 0

If the file was opened, the program would determine the amount of numbers and calculate the square root in order to re-create the images size (wouldn't support rectangular images though, need to think of a better method for saving it). Ideally, it would use whatever format KnightOS uses (see: [kimg](https://github.com/knightos/kimg))
