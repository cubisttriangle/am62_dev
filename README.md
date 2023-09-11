# SK-AM62 Development environment

## Dependencies

- docker
- docker-compose

## Setup

- Install Dependencies
- Generate env file: `./generate-env.sh`

## Build docker image

`docker compose build`

## Show docker images

`docker images`

## Run docker instance

`docker run -it --rm --privileged am62_dev`

If you want to mount an additional directory into the container, maybe
one containing custom code, you can do so with:

`docker run -it --rm -v ~/my_code:/home/$USER/my_code --privileged am62_dev`

## SDK setup

At this point, the SDK is ready for setup.

`$ cd /opt/am62/ti-processor-sdk-linux-am62xx-evm-09.00.00.03`
`USER=$(id -un) ./setup.sh`

The setup script expects the USER env var to be set, but isn't in docker.
This is why it's set before the setup script invocation. Respond to the
setup script prompts however you'd like.

If you tell the setup script generate a minicom script, it attempts to detect the
device on a serial port by searching dmesg. It won't be able to access dmesg, but
don't worry about it. The `--privileged` flag specified in the command to launch
the container instance should mount USB devices in the container.

One issue with the USB devices in the container is that the group ids set on TTY
devices on your host may not correspond to valid groups in your container. For
example, my host system has a group 'uucp' with id 986 which is assigned to
/dev/ttyUSB* devices when they show up on the bus. When accessing these devices
from the container, the container system may not have a group with this id. So you
can update the the group number to correspond to group name 'dialout' or 'plugdev'
which your user should already be a part of (type `groups` to see):

`sudo groupmod -g 986 plugdev`

You'll need to commit this (see below) and log out and back into the container
so you user groups correspond to the group. Now you can just run `minicom` and it
will load the script with all the parameters gathered by the setup script and
connect to the device.

Once you have everything set up the way you like, you can commit the changes to
your image. With your docker container setup and running, open another terminal
so you can find the container id:

`docker ps`

Then, commit the image change:

`docker commit ${CONTAINER_ID} am62_dev:sdk_setup`

Access an instance of your new image with:

`docker run -it --rm --privileged am62_dev:sdk_setup`

