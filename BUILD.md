Build Commands

For RPi4
docker run --rm --log-driver none -v `pwd`:/build -w /build -it -e PROJECT=RPi -e DEVICE=RPi4 -e ARCH=arm libreelec make image

Generic build
docker run --rm --log-driver none -v `pwd`:/build -w /build -it -e PROJECT=Generic -e ARCH=x86_64 libreelec make image
