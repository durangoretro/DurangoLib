# Durango Lib

[![Compile](https://github.com/durangoretro/DurangoLib/actions/workflows/compile.yml/badge.svg)](https://github.com/durangoretro/DurangoLib/actions/workflows/compile.yml)

Durango Computer FrameWork.

[https://www.durangoretro.com/](https://www.durangoretro.com/)

This repository contains the source code and configuration, needed to generate the Durango Computer FrameWork.

## Install Durango Lib

To use this FrameWork, you can use the next approach:

1. Install on your own machine.

    a. Download the Last Release from the [Release page](https://github.com/durangoretro/DurangoLib/releases).
    
    b. unzip in your computer the Zip File.
    
    c. Create a new Environment Variable ```DDK``` (Durango Dev Kit) that contains the Path where the Zip was unzipped.
    
2. Use a [Docker Image](https://hub.docker.com/r/zerasul/durangodevkit/tags).

```bash
docker pull zerasul/durangodevkit:latest
```

## Compile Durango Lib

To Compile and generate Durango Lib, you need the Next Prerequisites (Only if you don't use Docker Image):

1. Make
2. [CC65](https://cc65.github.io/)
3. Git
4. Curl
5. zip & unzip

After installing the prerequisites you can compile and generate a zip file

1. Using make

```bash
make && make makeziplib
```

2. using Docker

```bash
docker run --rm -v $PWD:/src/durango zerasul/durangodevkit:latest make && make makeziplib
```
## Running Examples

In the folder ```examples```, you can find several examples of the uses of Durango Framework; and can generate a Rom from Each example. Each Example has its own Makefile and the source Code.

To compile each Example, you need first to Compile the Durango Framework.


```bash
git clone https://github.com/durangoretro/DurangoLib.git
make
```

If you are using the [Durango Docker Image](https://hub.docker.com/r/zerasul/durangodevkit):


```bash
git clone https://github.com/durangoretro/DurangoLib.git
docker run --rm -v $PWD:/src/durango zerasul/durangodevkit:latest
```

Once you compile the last version of Durango FrameWork, you can compile each example:

```bash
make -C examples/fill_screen
```

Or using Docker:

```bash
docker run --rm -v $PWD:/src/durango zerasul/durangodevkit:latest make -C examples/fill_scren
```

### Use Template

To create a new ROM, you can use our [Template Repository](https://github.com/durangoretro/hello_durango).
