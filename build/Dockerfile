FROM debian:11 as base_image

#--- CONFIGURABLE VARIABLES ---#
# PYTHON_VERSION
# CODE_SERVER_VERSION

####################

# INSTALL PYTHON
FROM base_image as builder
ARG PYTHON_VERSION=3.9.5
RUN apt-get update && \
	apt-get install -y \
		build-essential \
		zlib1g-dev \
		libssl-dev \
		libffi-dev \
		wget \
		&& \
	rm -rf /var/lib/apt/lists/*
RUN wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz" -O /tmp/python.tgz && \
	tar -xvf /tmp/python.tgz --one-top-level=/tmp/python --strip-components 1 && \
	rm -f /tmp/python.tgz && \
	cd /tmp/python && \
	./configure --prefix=/opt/python && \
	make && \
	make install && \
	rm -rf /tmp/python

####################

FROM base_image as final_image

# SET TIMEZONE
RUN TZ=America/Los_Angeles && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

# ALLOW COLOR IN TERMINAL
ENV TERM=xterm-256color

# SET --no-install-recommends GLOBALLY
RUN echo 'APT::Install-Recommends "0";' >>/etc/apt/apt.conf.d/01norecommend && \
	echo 'APT::Install-Suggests "0";' >>/etc/apt/apt.conf.d/01norecommend

# INSTALL DOCKER
COPY --from=docker:dind /usr/local/bin /usr/local/bin

# INSTALL ESSENTIAL TOOLS
RUN apt-get update && \
	apt-get install -y \
		curl \
		vim \
		wget \
		telnet \
		traceroute \
		moreutils \
		procps \
		git \
		ca-certificates \
		&& \
	rm -rf /var/lib/apt/lists/*

# INSTALL TMUX
RUN apt-get update && \
	apt-get install -y \
		git \
		ca-certificates \
		tmux \
		&& \
	rm -rf /var/lib/apt/lists/* && \
	git clone https://github.com/tmux-plugins/tmux-battery.git ~/.tmux/plugins/tmux-battery && \
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# SETUP ZSH
RUN apt-get update && \
	apt-get install -y \
		zsh \
		git \
		ca-certificates \
		&& \
	rm -rf /var/lib/apt/lists/*
RUN chsh -s $(which zsh)
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
	rm -rf /var/lib/apt/lists/*
RUN echo "Installing oh-my-zsh themes and plugins . . ." && \
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
	git clone https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions && \
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
	git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k && \
	git clone https://github.com/JtMotoX/zsh-jt-themes.git ~/.oh-my-zsh/custom/themes/zsh-jt-themes && \
	echo "done"

# INSTALL CODE-SERVER
ARG CODE_SERVER_VERSION=4.2.0
COPY ./code-server-cert /root/.config/code-server/cert
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version ${CODE_SERVER_VERSION} && \
	rm -rf /var/lib/apt/lists/*

# ADD PYTHON
COPY --from=builder /opt/python /opt/python
ENV PATH=/opt/python/bin:${PATH}
RUN ln -s /opt/python/bin/python3 /usr/local/bin/python && \
	ln -s /opt/python/bin/pip3 /usr/local/bin/pip && \
	python --version

# ADD PYTHON MODULES
COPY ./requirements.txt /tmp/requirements.txt
RUN pip install wheel
RUN pip install -r /tmp/requirements.txt

# ADD DOTFILES
RUN cd ~ && \
	git clone https://github.com/JtMotoX/dotfiles.git dotfiles && \
	ln -sf dotfiles/ansible.cfg .ansible.cfg && \
	ln -sf dotfiles/bash_profile_custom .bash_profile_custom && \
	ln -sf dotfiles/p10k.zsh .p10k.zsh && \
	ln -sf dotfiles/sh_profile_custom .sh_profile_custom && \
	ln -sf dotfiles/tmux.conf .tmux.conf && \
	ln -sf dotfiles/zshrc .zshrc

# COPY SCRIPTS
COPY --chmod=755 ./scripts /scripts

WORKDIR /root

ENTRYPOINT ["/scripts/entrypoint.sh"]
