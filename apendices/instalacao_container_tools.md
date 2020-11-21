# Apêndice: Instalando Ferramentas de Container
Este apêndice é um guia para a instalação das ferramentas de container da Containers Organization, que são o Podman, Buildah e Skopeo. Note que essas ferramentas estão disponíveis apenas para Linux e não para Windows, e a versão de MacOS não é completamente funcional.

## Ubuntu / Debian
```bash
echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/Release.key | sudo apt-key add -

sudo apt -y update
sudo apt -y install buildah podman skopeo
```

## CentOS 8 / RHEL 8
```bash
sudo dnf -y module disable container-tools
sudo dnf -y install 'dnf-command(copr)'
sudo dnf -y copr enable rhcontainerbot/container-selinux
sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo
sudo dnf -y install podman
```