FROM ubuntu:latest 

# add your keyname
ARG KEY_NAME <add your keyname>

# add the nickname for your validator on the network
ARG MONIKER <add your moniker>

# add the network id
ARG NETWORK_ID blackfury_9624-1

# arbitrary validator metadata
ARG DETAILS <details as string>

# add amount you're delegating
ARG TOKEN_DELEGATION <amount>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update &&\ 
	apt-get install -y apt-utils git git-extras software-properties-common vim \
	wget ca-certificates curl build-essential libssl-dev make openssh-server snap

RUN snap install go --classic

# builds out blackfuryd
RUN git clone https://github.com/Exfury/Blackfury-Testnet
WORKDIR /Blackfury-Testnet/cmd/blackfuryd
RUN go install -tags ledger ./... &&\
    mv $HOME/go/bin/blackfuryd /usr/bin/

# generate keys
RUN blackfuryd keys add $KEY_NAME
    # blackfuryd keys add $KEY_NAME --recover &&\
    # blackfuryd keys add $KEY_NAME --ledger 

# initialize node
RUN blackfuryd init $MONIKER --chain-id blackfury_9624-1

# get genesis file
RUN wget https://github.com/Exfury/Blackfury-Testnet-v2/raw/main/genesis.json -P $HOME/.blackfuryd/config/
RUN sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.0001ablackfury"/g' $HOME/.blackfuryd/config/app.toml
RUN wget https://github.com/Exfury/Blackfury-Testnet-v2/raw/main/Docker/blackfuryd.service -P $HOME/systemd/system/

# run blackfuryd
WORKDIR /Blackfury-Testnet/cmd/blackfuryd
RUN sudo systemctl daemon-reload &&\
    sudo systemctl enable blackfuryd.service &&\
    systemctl start blackfuryd && journalctl -u blackfuryd -f

ENTRYPOINT ["/bin/bash"]
