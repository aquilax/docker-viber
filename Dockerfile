FROM debian:stable

# Tell debconf to run in non-interactive mode
ENV DEBIAN_FRONTEND noninteractive

# Make sure the repository information is up to date
RUN apt-get update

# We need ssh to access the docker container, wget to download viber
RUN apt-get install -y openssh-server wget libxss1 libxrandr2 libxi6 libxslt1.1

RUN wget http://download.cdn.viber.com/cdn/desktop/Linux/viber.deb -O /usr/src/viber.deb
RUN dpkg -i /usr/src/viber.deb || true
RUN apt-get install -fy # Automatically detect and install dependencies

# Create user "docker" and set the password to "docker"
RUN useradd -m -d /home/docker docker
RUN echo "docker:docker" | chpasswd

# Create OpenSSH privilege separation directory, enable X11Forwarding
RUN mkdir -p /var/run/sshd
RUN echo X11Forwarding yes >> /etc/ssh/ssh_config

# Prepare ssh config folder so we can upload SSH public key later
RUN mkdir /home/docker/.ssh
RUN chown -R docker:docker /home/docker
RUN chown -R docker:docker /home/docker/.ssh

# Set locale (fix locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || true
RUN echo "Europe/Stockholm" > /etc/timezone

# Set up the launch wrapper - sets up PulseAudio to work correctly
RUN echo 'export PULSE_SERVER="tcp:localhost:64713"' >> /usr/local/bin/viber-pulseaudio
RUN echo 'PULSE_LATENCY_MSEC=60 /opt/viber/Viber' >> /usr/local/bin/viber-pulseaudio
RUN chmod 755 /usr/local/bin/viber-pulseaudio

# Expose the SSH port
EXPOSE 22

# Start SSH
ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
