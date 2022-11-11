#!/bin/bash
#https://github.com/cri-o/cri-o/blob/main/install.md
modprobe overlay
modprobe br_netfilter
cat <<EOF > /etc/modules-load.d/k8s.conf
        overlay
        br_netfilter
EOF

# Disabilita memoria swap  
sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

# sysctl params required by setup, params persist across reboots

cat <<EOF > /etc/sysctl.d/k8s.conf
        net.bridge.bridge-nf-call-iptables  = 1
        net.bridge.bridge-nf-call-ip6tables = 1
        net.ipv4.ip_forward = 1
EOF

## Apply sysctl params without reboot
sysctl --system

# Pacotes Necessarios
apt-get install -y apt-transport-https ca-certificates curl gnupg2 lsb-release

# Add Cri-o repo
mkdir -p /etc/apt/keyrings

OS="xUbuntu_22.04"
VERSION=1.24
echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
mkdir -p /usr/share/keyrings
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/Release.key | gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg


# Install CRI-O
apt update
apt install cri-o cri-o-runc -y

# Start and enable Service
systemctl daemon-reload
systemctl restart crio
systemctl enable crio



# Instalação kubeadm Kubelete kubectl 
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list


apt update && apt install -y  kubelet kubectl kubeadm
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet

#https://kubernetes.io/docs/reference/kubectl/cheatsheet/
# Kubectl autocomplete
su -c 'source <(kubectl completion bash)' vagrant
su -c 'echo "source <(kubectl completion bash)" >> /home/vagrant/.bashrc' vagrant

# Kubectl alias
su -c 'echo alias k=kubectl >> /home/vagrant/.bashrc' vagrant
su -c 'echo complete -o default -F __start_kubectl k >> /home/vagrant/.bashrc' vagrant

su -c "source /home/vagrant/.bashrc" vagrant