core_services = [
    {
        "name": "frontend",
        "namespace": "app",
        "type": "deployment",
        "image": "registry.gitlab.com/bigboiblue/kblue-io-registry/frontend-dev:latest",
        "sync_src": "./projects/portfolio-site-frontend",
        "sync_src_excludes": ["*.log", "node_modules"],
        "sync_dest": "/app",
    },
    {
        "name": "backend",
        "namespace": "app",
        "type": "deployment",
        "image": "registry.gitlab.com/bigboiblue/kblue-io-registry/backend-dev:latest",
        "sync_src": "./projects/portfolio-site-backend",
        "sync_src_excludes": ["./target", "./target-rust-analyzer"],
        "sync_dest": "/app",
    },
    {
        "name": "postgresql",
        "namespace": "app",
        "type": "deployment",
        "image": "registry.gitlab.com/bigboiblue/kblue-io-registry/postgresql-dev:latest",
    },
]

def helmfile_sync(file):
  watch_file(file)
  return local("helmfile -f %s sync -e dev --take-ownership" % (file,))

allow_k8s_contexts('kubernetes-admin@kubernetes')
update_settings (max_parallel_updates = 5, k8s_upsert_timeout_secs = 60) 
load('ext://uibutton', 'cmd_button', 'location', 'text_input')
load('ext://file_sync_only', 'file_sync_only')
load('ext://k8s_attach', 'k8s_attach')

is_cluster_initialised = str(local('sh -c "kubectl get ns calico-system >/dev/null 2>&1 && echo true; exit 0"')).strip() == 'true'
if not is_cluster_initialised:
    helmfile_sync("kubernetes/helmfile.yaml")
else:
    print("Already deployed cluster. Skipping initialisation")


for svc in core_services:
    live_update = None
    deps = None
    copy_all_command = 'echo ""'
    if "sync_src" in svc and "sync_dest" in svc:
        live_update = sync(svc["sync_src"], svc["sync_dest"]) 
        deps = [svc["sync_src"]] 
        excludes = []
        if "sync_src_excludes" in svc:
            excludes = [" --exclude='%s' " % x for x in svc["sync_src_excludes"]]
        copy_all_command = "tar %s --ignore-failed-read -cf - -C %s . | kubectl exec -i %s/%s -n %s -- tar -xf - -C %s" % (''.join(excludes), svc["sync_src"], svc["type"], svc["name"], svc["namespace"], svc["sync_dest"])

        cmd_button(
            name='sync-local-file-%s' % svc['name'],
            resource=svc['name'],
            argv=['bash', '-c', copy_all_command],
            text='Sync local files',
            icon_name='upload'
        )

    k8s_attach(svc["name"], "%s/%s" % (svc['type'], svc['name']), 
        namespace=svc["namespace"],
        image_selector=svc["image"], 
        live_update=live_update,
        deps=deps
    )

    cmd_button(
        name='restart-%s' % svc['name'],
        resource=svc['name'],
        argv=['bash', '-c', "kubectl rollout restart %s/%s -n %s && sleep 10 && %s" % (svc['type'], svc['name'], svc['namespace'], copy_all_command)],
        text='Restart',
        icon_name='restart_alt'
    )

    local(copy_all_command)


local_resource(
    'Restart All Dev Volumes',
    cmd='./scripts/restart_dev_volumes.sh',
    trigger_mode=TRIGGER_MODE_MANUAL,
    auto_init=False
)


cmd_button(
    name='install-dependencies-frontend',
    resource='frontend',
    argv=['bash', '-c', "kubectl exec deployment/frontend -n app -- yarn"],
    text='Reinstall npm dependencies',
    icon_name='download'
)