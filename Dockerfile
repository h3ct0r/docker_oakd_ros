FROM ros:noetic-ros-base-focal
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update; exit 0
RUN apt-get install -y wget
RUN wget -qO - https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

COPY scripts/install_dependencies.sh /
RUN /install_dependencies.sh

RUN apt-get install wget
RUN wget https://github.com/libusb/libusb/releases/download/v1.0.24/libusb-1.0.24.tar.bz2
RUN tar xf libusb-1.0.24.tar.bz2
RUN cd libusb-1.0.24 && \
    ./configure --disable-udev && \
    make -j && make install

RUN pip install opencv-python

RUN git clone -b develop https://github.com/luxonis/depthai-python
RUN cd /depthai-python && git submodule update --init --recursive
RUN mkdir -p /depthai-python/build
RUN cd /depthai-python && \
    cd build && \
    cmake .. && \
    make -j
ENV PYTHONPATH=/depthai-python/build

RUN mkdir -p /depthai-python/examples/models/
RUN cd /depthai-python/examples/models/ && \
    wget https://artifacts.luxonis.com/artifactory/luxonis-depthai-data-local/network/mobilenet-ssd_openvino_2021.2_6shave.blob

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools 

# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-noetic-perception=1.5.0-1* 

# prepare ros oakd
RUN apt-get update && apt-get install -y python3-catkin-tools python3-catkin-lint python3-pip python3-rosdep ros-noetic-xacro ros-noetic-hector-xacro-tools ros-noetic-robot-state-publisher ros-noetic-robot-state-publisher-dbgsym
RUN pip3 install osrf-pycommon
RUN rosdep update
RUN apt-get install python3-vcstool
RUN wget -qO- https://raw.githubusercontent.com/luxonis/depthai-ros/noetic-devel/install_dependencies.sh | bash
RUN mkdir -p /catkin_ws/src
RUN cd /catkin_ws && wget https://raw.githubusercontent.com/luxonis/depthai-ros/noetic-devel/underlay.repos && vcs import src < underlay.repos
RUN cd /catkin_ws && rosdep install --from-paths src --ignore-src -r -y
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; cd /catkin_ws && catkin build'
RUN cd /catkin_ws/src && git clone https://github.com/h3ct0r/oakd_pcloud
RUN /bin/bash -c '. /opt/ros/noetic/setup.bash; source /catkin_ws/devel/setup.bash; cd /catkin_ws && catkin build'
RUN touch /root/.bashrc \
 && echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc \
 && echo "source /catkin_ws/devel/setup.bash" >> /root/.bashrc

# remove apt cache files
RUN rm -rf /var/lib/apt/lists/*
