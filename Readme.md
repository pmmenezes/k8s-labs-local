https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/


```bash
cd vagrant
vagrant status
vagrant up 
vagrant status
vagrant ssh controlplane

```

### Kubeadm com containerd
Habilite o containerd no Vagrantfile

sed -i 's/#runc = "containerd"/runc = "containerd"/' Vagrantfile
sed -i 's/runc = "crio"/#runc = "crio"/' Vagrantfile

```bash
sudo kubeadm init --upload-certs --control-plane-endpoint=$(hostname) --apiserver-advertise-address $(hostname -i)  --cri-socket unix:///var/run/containerd/containerd.sock --pod-network-cidr 192.168.99.0/24

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

vagrant ssh worker01

kubeadm join controlplane.k8s.lab:6443 --token <token> \
        --discovery-token-ca-cert-hash  <hash>

vagrant ssh worker02

kubeadm join controlplane.k8s.lab:6443 --token <token> \
        --discovery-token-ca-cert-hash  <hash>


```
### Kubeadm com Cri-O

Habilite o crio no Vagrantfile

sed -i 's/runc = "containerd"/#runc = "containerd"/' Vagrantfile
sed -i 's/#runc = "crio"/runc = "crio"/' Vagrantfile

```bash
sudo kubeadm init --upload-certs --control-plane-endpoint=$(hostname) --apiserver-advertise-address $(hostname -i)  --cri-socket unix:///var/run/crio/crio.sock  --pod-network-cidr 192.168.99.0/24	


mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

vagrant ssh worker01

kubeadm join controlplane.k8s.lab:6443 --token <token> \
        --discovery-token-ca-cert-hash  <hash>

vagrant ssh worker02

kubeadm join controlplane.k8s.lab:6443 --token <token> \
        --discovery-token-ca-cert-hash  <hash>


```


