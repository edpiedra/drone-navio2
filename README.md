# drone-navio2
Holds the install and drone scripts with a branch for each configuration.  Configurations:
> rpi-bookworm-32bit

# initialization
```
cd ~
bash <(wget -qO- https://raw.githubusercontent.com/edpiedra/drone-navio2/main/initialize.sh)
```

# github updates
```
cd ~ && bash scripts/git_pull.sh
```

# get branche name
```
echo $DRONE_CONFIG
```

# post initialization install
> to handle install breaks
```
cd ~
bash drone-navio2/install/install.sh {optional parameter}
# optional parameters:
# --reinstall : removes install flags from completed tasks
```
