# inodesfs

Experiments to build a virtual file system based on fuse that can store huge numbers of files with a limited number of inodes on the real file system.

## Posgresql backend

The postgresql backend is based on [pgfuse](http://www.andreasbaumann.cc/software/pgfuse/). A first test with a Conda-based sefl content environment (including Postgres server) showed an important increase of both real storage size and of number of inodes. I am leaving this backend aside for the moment.
