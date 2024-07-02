apiVersion: v1
kind: Config
clusters:
- name: ${cluster_name}
  cluster:
    server: ${cluster_endpoint}
    certificate-authority-data: ${cluster_ca_certificate}
users:
- name: ${cluster_name}-user
  user:
    auth-provider:
      config:
        cmd-args: config config-helper --format=json
        cmd-path: gcloud
        expiry-key: '{.credential.token_expiry}'
        token-key: '{.credential.access_token}'
      name: gcp
contexts:
- name: ${cluster_name}
  context:
    cluster: ${cluster_name}
    user: ${cluster_name}-user
current-context: ${cluster_name}
