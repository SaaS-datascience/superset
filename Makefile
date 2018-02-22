EDITOR=vim

include /etc/os-release

install-prerequisites:
ifeq ("$(wildcard /usr/bin/docker)","")
        @echo install docker-ce, still to be tested
        sudo apt-get update
        sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common

        curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo apt-key add -
        sudo add-apt-repository \
                "deb https://download.docker.com/linux/ubuntu \
                `lsb_release -cs` \
                stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
endif

download:
	wget https://my.vertica.com/client_drivers/9.0.x/9.0.0-1/vertica-client-9.0.0-1.x86_64.tar.gz

network: 
	@docker network create latelier 2> /dev/null; true


build:
	docker build --build-arg proxy=${http_proxy} -t superset .

init-db:
	docker exec -it superset superset-init

up: network
	docker-compose up -d

down:
	docker-compose down

restart: down up



