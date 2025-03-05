# Portfolio Site Infrastructure

- CNI: Calico (tigera operator)
   - for more customisability, like isolation between namespaces, ip filtering, traffic mirroring, changing load balancing algorithms, etc. Default CNI is KubeNet
- Ingress: Ingress-nginx
   - Exposed via NodePort (since we are running self managed kubernetes solely on vps(s))
- Cert-manager (uses letsencrypt)
- Trust-manager (for dev - for adding ca cert configmaps to each ns to mount and trust self issued certs)
- App
   - Frontend: React
   - Backend: Rust
   - Postgresql

All k8s manifests exist in their own helm charts and are to be applied using helmfile

# Use for development

If you have an existing k8s cluster, run `./scripts/remove_old_cluster.sh` to remove the old k8s cluster

Start a single node cluster for development using the `start_single_node_cluster.sh` script.

Immediately after creating the cluster you will need to apply the secrets displayed in the "secrets" section (otherwise pods will startup with errors)

Then, add the other repos to the `<git-root>/projects` directory by running `./scripts/pull_repos.sh`. This is required for tilt's live-update / hot-reload to work. It is recommended to test changes to these services by updating the repos automatically pulled to the `<git-root>/projects` directory (as they will hot-reload in the cluster automatically).

Then, in the root if this git repo, run `tilt up`. This will essentially run `helmfile sync -e dev -f kubernetes/helmfile.yaml --take-ownership` to bootstrap the k8s cluster with all the required resources. Tilt then monitors these resources, displays them in a nice ui, and takes care of live update for specified resources.

When run locally, everything is setup to use www.kblue-dev.io (on their appropriate ports), therefore in your hosts file set www.kblue-dev.io and api.kblue-dev.io to point toward 127.0.0.1.
Locally, the http port is set to be 30000 and the HTTPS port is set to be 30001 to avoid conflicts, so you can access the website on https://www.kblue-dev.io:30001


## Database

When in development mode, the postgres database is available outside the cluster on port 30003.
In this case the user is `cluster-admin`, the database used is `kblue`, the port is `30003` and the password is `password`.
Therefore you can login to the database with psql using the command: `PGPASSWORD=password psql -h localhost -p 30003 -U cluster-admin kblue`

In prod, the postgres database is not directly available to the outside world, and must be done through either a ssh tunnel or another k8s service.

## MacOS

The install_dependencies script was intended for debian or ubuntu, so it will not work for MacOS.

Manually install dependencies using:

```
brew install --cask docker
brew install helm
brew install helmfile
helm plugin install https://github.com/databus23/helm-diff
```

In order to run this cluster on MacOS (for dev) use [k3d](https://github.com/k3d-io/k3d).

Create cluster with `GIT_ROOT=$(git rev-parse --show-toplevel) && k3d cluster create cluster --volume "$GIT_ROOT/projects:$GIT_ROOT/projects" -p "30000-30100:30000-30100" && k3d kubeconfig merge cluster --kubeconfig-switch-context` (we need to mount the volume for hot reload to work, and expose part of kubernetes default port range as full range takes too long to startup)

Run `kubectl taint nodes --all node-role.kubernetes.io/control-plane-` to allow pods to be added to the master node.

As normal, now add the initial cluster secrets before running `tilt up` at the git root

## Secrets

- If running locally, you will have to manually create the secrets that are automatically created via github actions in the infrastructure repo on the main cluster machine
- One of these secrets is your ssh key. This is used to install private npm packages from private github repositories. When executing the ssh secret command, make sure that your ssh private key is NOT password authenticated (you can remove it with `ssh-keygen -p`). Also replace the ssh private key and public key paths if needed.

    - `kubectl create secret docker-registry regcred --docker-server=https://registry.gitlab.com --docker-username=${{ secrets.REGISTRY_USERNAME }} --docker-password=${{ secrets.REGISTRY_PASSWORD }} --docker-email=${{ secrets.REGISTRY_EMAIL }} -n app`
    - `kubectl create secret generic psql-password --from-literal=POSTGRES_PASSWORD=${{ secrets.POSTGRES_PASSWORD }} -n app`
    - `kubectl create secret generic ssh-keys --from-file=key=$HOME/.ssh/id_rsa --from-file=key.pub=$HOME/.ssh/id_rsa.pub -n app`

Note: Helmfile prepare hook will disable you from applying any releases if you do not have these secrets present (as well as setting up pre-requisite namespaces such as app and cert-manager).

## Setting up a VPS

Prerequisites:

- VPS must use Debian 11

1. Run new_vps_node_setup.sh script to setup vps with basic security, firewall, ssh etc.
2. Run install_dependencies.sh
3. Attach the node to the existing kubernetes cluster

# Future improvements:

It's probably better to have our own helm repo and pull all our helm templates into that (for easier upgrades) instead of having the manifests in here directly, but this is good for now for simplicity and time's sake.