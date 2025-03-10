FROM osrf/ros:melodic-desktop-full

# =========================================================
# =========================================================

# Are you are looking for how to use this docker file?
#   - https://docs.openvins.com/dev-docker.html
#   - https://docs.docker.com/get-started/
#   - http://wiki.ros.org/docker/Tutorials/Docker

# =========================================================
# =========================================================

# Dependencies we use, catkin tools is very good build system
# Also some helper utilities for fast in terminal edits (nano etc)
RUN apt-get update && apt-get install -y libeigen3-dev nano git
RUN sudo apt-get install -y python-catkin-tools

# Seems this has Python 3.6 installed on it...
RUN sudo apt-get install -y python3-dev python3-matplotlib python3-numpy python3-psutil python3-tk

# Maplab dependecies
# https://github.com/ethz-asl/maplab/wiki/Installation-Ubuntu
RUN sudo apt install -y autotools-dev ccache doxygen dh-autoreconf git liblapack-dev libblas-dev libgtest-dev libreadline-dev libssh2-1-dev pylint clang-format python-autopep8 python-catkin-tools python-pip python-git python-setuptools python-termcolor python-wstool libatlas3-base
RUN sudo pip install requests

# Install CMake 3.13.5
ADD https://cmake.org/files/v3.13/cmake-3.13.5-Linux-x86_64.sh /cmake-3.13.5-Linux-x86_64.sh
RUN mkdir /opt/cmake
RUN sh /cmake-3.13.5-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
RUN cmake --version

# Install deps needed for clion remote debugging
# https://blog.jetbrains.com/clion/2020/01/using-docker-with-clion/
RUN sed -i '6i\source "/catkin_ws/devel/setup.bash"\' /ros_entrypoint.sh
RUN apt-get update && apt-get install -y ssh build-essential gcc g++ \
    gdb clang cmake rsync tar python && apt-get clean
RUN ( \
    echo 'LogLevel DEBUG2'; \
    echo 'PermitRootLogin yes'; \
    echo 'PasswordAuthentication yes'; \
    echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_config_test_clion \
  && mkdir /run/sshd
RUN useradd -m user && yes password | passwd user
RUN usermod -s /bin/bash user
CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config_test_clion"]

