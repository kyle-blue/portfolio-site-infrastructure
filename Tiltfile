def helmfile_sync(file):
  watch_file(file)
  return local("helmfile -f %s sync -e dev --take-ownership" % (file,))

def helmfile_template(file):
  watch_file(file)
  # -l selector to avoid triggering calico uninstall job / attempting to reinstall calico
  return local("helmfile -f %s template -e dev -l hideInTilt!=true" % (file,))

allow_k8s_contexts('kubernetes-admin@kubernetes')
update_settings (max_parallel_updates = 5, k8s_upsert_timeout_secs = 60) 

docker_build('registry.gitlab.com/bigboiblue/kblue-io-registry/frontend-dev:latest', './projects/portfolio-site-frontend', live_update=[
    sync('./projects/portfolio-site-frontend', '/app')
])

docker_build('registry.gitlab.com/bigboiblue/kblue-io-registry/backend-dev:latest', './projects/portfolio-site-backend', live_update=[
    sync('./projects/portfolio-site-backend', '/app')
])

helmfile_sync("kubernetes/helmfile.yaml")

k8s_yaml(helmfile_template("kubernetes/helmfile.yaml"))
k8s_resource(
    workload="backend",
    labels=["app"]
)
k8s_resource(
    workload="frontend",
    labels=["app"]
)
k8s_resource(
    workload="postgresql",
    labels=["app"]
)
