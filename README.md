# docker_oakd_ros
## _A docker image with ROS and the depth-ai packages for the OAKD camera. Compatible with Ubuntu 16.04!_

## Features

Uses the https://github.com/h3ct0r/oakd_pcloud package for image and depth cloud publishing.
Installs the depth-ai setup under Ubuntu 20.04, including a modified version of libusb so the Docker image can access the USB camera.

## Installation

### Install Docker

Follow steps from: https://docs.docker.com/engine/install/ubuntu/

```
sudo apt-get remove docker docker-engine docker.io containerd runc

sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

 echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Test the installation with:

```
sudo docker run hello-world
```

## Run container

Build the container (this could take some minutes):

```
cd docker_oakd_ros/
docker build . -t oakd_ros
```

Run the container and the xhost trick so to GUI apps can display on X when executed from inside the container:

```
xhost local:root

docker run -it \                                   
    --privileged \
    --network host \
    -v /dev/bus/usb:/dev/bus/usb \
    --device-cgroup-rule='c 189:* rmw' \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    oakd_ros
```

From outisde the container you must have a `roscore` instance running. After that just run from inside the container:

```
roslaunch oakd_pcloud stereo_nodelet_no_rviz.launch
```

And from outside the container run an RViz instance to view the camera data:

```
rviz
```

A topic list should show something like this:
```
$ rostopic list
sh: 0: getcwd() failed: No such file or directory
/clicked_point
/initialpose
/move_base_simple/goal
/rosout
/rosout_agg
/stereo_rgb_node/color/image
/stereo_rgb_node/stereo/depth
/stereo_rgb_node/stereo/points
/stereo_rgb_node/stereo/wls_depth_image
/tf
/tf_static
```

## License

GNU

**Free Software, Hell Yeah!**
