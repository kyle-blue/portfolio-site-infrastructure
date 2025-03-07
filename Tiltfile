def helmfile_sync(file):
  watch_file(file)
  return local("helmfile -f %s sync -e dev --take-ownership" % (file,))

def helmfile_template(file):
  watch_file(file)
  # -l selector to avoid triggering calico uninstall job / attempting to reinstall calico
  return local("helmfile -f %s template -e dev -l hideInTilt!=true" % (file,))

allow_k8s_contexts('kubernetes-admin@kubernetes')
update_settings (max_parallel_updates = 5, k8s_upsert_timeout_secs = 60) 
load('ext://uibutton', 'cmd_button', 'location', 'text_input')
load('ext://file_sync_only', 'file_sync_only')
load('ext://k8s_attach', 'k8s_attach')

is_cluster_initialised = local(' kubectl get ns calico-system >/dev/null 2>&1 && echo true') != 'true'
if not is_cluster_initialised:
    helmfile_sync("kubernetes/helmfile.yaml")
else:
    print("Already deployed cluster. Skipping initialisation")


k8s_attach('frontend', 'deployment/frontend', 
    namespace='app',
    image_selector='registry.gitlab.com/bigboiblue/kblue-io-registry/frontend-dev:latest', 
    live_update=[
        sync('./projects/portfolio-site-frontend', '/app')
    ],
        deps = ['./projects/portfolio-site-frontend']

)

k8s_attach('backend', 'deployment/backend', 
    namespace='app',
    image_selector='registry.gitlab.com/bigboiblue/kblue-io-registry/backend-dev:latest', 
    live_update=[
        sync('./projects/portfolio-site-backend', '/app')
    ],
)

k8s_attach('postgresql', 'deployment/postgresql',
    namespace='app'

)

cmd_button(
    name='restart-frontend',
    resource='frontend',
    argv=['kubectl', 'rollout', 'restart', 'deployment/frontend', '-n', 'app'],
    text='Restart',
    icon_name='restart_alt'
)

cmd_button(
    name='restart-backend',
    resource='backend',
    argv=['kubectl', 'rollout', 'restart', 'deployment/backend', '-n', 'app'],
    text='Restart',
    icon_name='restart_alt'
)

cmd_button(
    name='restart-postgresql',
    resource='postgresql',
    argv=['kubectl', 'rollout', 'restart', 'deployment/postgresql', '-n', 'app'],
    text='Restart',
    icon_name='restart_alt'
)

cmd_button(
    name='restart-postgresql',
    resource='postgresql',
    argv=['kubectl', 'rollout', 'restart', 'deployment/postgresql', '-n', 'app'],
    text='Restart',
    icon_name='restart_alt'
)

local_resource(
    'Restart All Dev Volumes',
    cmd='./scripts/restart_dev_volumes.sh',
    trigger_mode=TRIGGER_MODE_MANUAL,
    auto_init=False
)
