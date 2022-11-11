#!/bin/bash

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

# Instalação containerd 
mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update && apt install -y  containerd.io 
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

# Instalação kubeadm Kubelete kubectl 
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list


apt update && apt install -y  kubelet kubectl kubeadm
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet

# Habilitando Cgroup Systemd no containerd 
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd


#https://kubernetes.io/docs/reference/kubectl/cheatsheet/
# Kubectl autocomplete
su -c 'source <(kubectl completion bash)' vagrant
su -c 'echo "source <(kubectl completion bash)" >> /home/vagrant/.bashrc' vagrant

# Kubectl alias
su -c 'echo alias k=kubectl >> /home/vagrant/.bashrc' vagrant
su -c 'echo complete -o default -F __start_kubectl k >> /home/vagrant/.bashrc' vagrant

su -c "source /home/vagrant/.bashrc" vagrant