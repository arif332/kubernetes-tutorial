
**Table of Contents**
- [Install dnsmasq](#install-dnsmasq)
- [Create a resolver file in macos](#create-a-resolver-file-in-macos)
- [References](#references)


# Install dnsmasq
Instal dnsmasq on macos using brew.

```bash
brew install dnsmasq
``` 

Now configure dnsmasq file.
```bash
# config file in m1 mac
/opt/homebrew/etc/dnsmasq.conf

# config file in intel mac
/usr/local/etc/dnsmasq.conf


# In dnsmasq.conf, Add a new ‘address’ line for each TLD you want to add.
address=/.test/127.0.0.1
port=53
```

Now start dnsmasq service.
```bash
# check service status
brew services list

# start service
sudo brew services start dnsmasq
sudo brew services restart dnsmasq

# check listen port and connection
sudo lsof -nP -iUDP | grep :53
```

Check current dns on macos
```bash
scutil --dns
```


# Create a resolver file in macos

```bash
sudo mkdir /etc/resolver

cat <<EOF | sudo tee /etc/resolver/test
domain test
nameserver 127.0.0.1
search_order 1
timeout 5
EOF

```

Restart mDNSResponder process.
```bash
sudo killall -HUP mDNSResponder
```

Check resolver configuration.
```bash
scutil --dns
```


# References
- https://minikube.sigs.k8s.io/docs/handbook/addons/ingress-dns/
- https://mjpitz.com/blog/2020/10/21/local-ingress-domains-kind/
- https://thekelleys.org.uk/dnsmasq/doc.html
- https://gist.github.com/davebarnwell/c408533d608bfe24f4f5