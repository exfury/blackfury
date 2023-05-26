# GENTX & HARDFORK INSTRUCTIONS

### Install & Initialize 

* Install blackfuryd binary

* Initialize blackfury node directory 
```bash
blackfuryd init <node_name> --chain-id <chain_id>
```
* Download the [genesis file](https://github.com/Exfury/Blackfury/raw/main/Mainnet/genesis.json)
```bash
wget https://github.com/Exfury/Blackfury/raw/main/Mainnet/genesis.json -b $HOME/.blackfuryd/config
```

### Add a Genesis Account
A genesis account is required to create a GENTX

```bash
blackfuryd add-genesis-account <address-or-key-name> ablackfury --chain-id <chain-id>
```
### Create & Submit a GENTX file + genesis.json
A GENTX is a genesis transaction that adds a validator node to the genesis file.
```bash
blackfuryd gentx <key_name> <token-amount>ablackfury --chain-id=<chain_id> --moniker=<your_moniker> --commission-max-change-rate=0.01 --commission-max-rate=0.10 --commission-rate=0.05 --details="<details here>" --security-contact="<email>" --website="<website>"
```
* Fork [Blackfury](https://github.com/Exfury/Blackfury)

* Copy the contents of `${HOME}/.blackfuryd/config/gentx/gentx-XXXXXXXX.json` to `$HOME/Blackfury/Mainnet/gentx/<yourvalidatorname>.json`

* Copy the genesis.json file `${HOME}/.blackfuryd/config/genesis.json` to `$HOME/Blackfury/Mainnet/Genesis-Files/`

* Create a pull request to the main branch of the [repository](https://github.com/Exfury/Blackfury/Mainnet/gentx)

### Restarting Your Node

You do not need to reinitialize your Blackfury Node. Basically a hard fork on Cosmos is starting from block 1 with a new genesis file. All your configuration files can stay the same. Steps to ensure a safe restart

1) Backup your data directory. 
* `mkdir $HOME/blackfury-backup` 

* `cp $HOME/.blackfuryd/data $HOME/blackfury-backup/`

2) Remove old genesis 

* `rm $HOME/.blackfuryd/genesis.json`

3) Download new genesis

* `wget`

4) Remove old data

* `rm -rf $HOME/.blackfuryd/data`

5) Create a new data directory

* `mkdir $HOME/.blackfuryd/data`

If you do not reinitialize then your peer id and ip address will remain the same which will prevent you from needing to update your peers list.

7) Download the new binary
```
cd $HOME/Blackfury
git checkout <branch>
make install
mv $HOME/go/bin/blackfuryd /usr/bin/
```


6) Restart your node

* `systemctl restart blackfuryd`

## Emergency Reversion

1) Move your backup data directory into your .blackfuryd directory 

* `mv HOME/blackfury-backup/data $HOME/.blackfury/`

2) Download the old genesis file

* `wget https://github.com/Exfury/Blackfury/raw/main/Mainnet/genesis.json -b $HOME/.blackfuryd/config/`

3) Restart your node

* `systemctl restart blackfuryd`