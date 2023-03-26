# Helm push action

This action package helm chart and publish it to your chart registry (OCI registry included)
Add helm supported FLAGS to every (almost) process

## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows`
folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

```yaml
name: Build & Push ecs-exporter chart
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - uses: staysub/helm-push-action@master
        env:
          SOURCE_DIR: '.'
          REGISTRY_DIR: 'ecs-exporter'
          OCI_ENABLED_REGISTRY: 'False'  #NOT required
          REGISTRY_URL: 'https://registry.url'
          REGISTRY_USER: '${{ secrets.REGISTRY_USER }}'
          REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }}
```

```yaml
name: Build & Push chart to OCI REGISTRY
on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - uses: staysub/helm-push-action@master
        env:
          SOURCE_DIR: '.'
          REGISTRY_DIR: 'ecs-exporter'
          OCI_ENABLED_REGISTRY: 'True'  #required
          REGISTRY_URL: 'europe-west1-docker.pkg.dev/my-project-id/my-image-registry/' #DO NOT add the oci protocol "oci://"
          REGISTRY_USER: '${{ secrets.REGISTRY_USER }}'
          REGISTRY_PASSWORD: ${{ secrets.REGISTRY_PASSWORD }}
```

### Configuration

The following settings must be passed as environment variables as shown in the example. Sensitive information,
especially `REGISTRY_USER` and `REGISTRY_PASSWORD`, should
be [set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) —
otherwise, they'll be public to anyone browsing your repository.

| Key                            | Value                                                                                                                           | Suggested Type                                | Required |
|--------------------------------|---------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|----------|
| `REGISTRY_DIR`                 | Folder with charts in repo                                                                                                      | `env`                                         | **Yes**  |
| `REGISTRY_URL`                 | registry url                                                                                                                    | `env`                                         | **Yes**  |
| `REGISTRY_USER`                | Username for registry                                                                                                           | `secret`                                      | **Yes**  |
| `REGISTRY_PASSWORD`            | Password for registry                                                                                                           | `secret`                                      | **Yes**  |
| `SOURCE_DIR`                   | The local directory you wish to upload. For example, `./charts`. Defaults to the root of your repository (`.`) if not provided. | `env`                                         | No       |
| `OCI_ENABLED_REGISTRY`         | Set to `True` if your registry is OCI based like (GCP artifcat registry). Defaults is `False` if not provided.                  | `env`                                         | No       |
| `HELM_INSPECT_FLAGS`           | Combination of helm inspect supported flags. [here                                                                              | https://helm.sh/docs/helm/helm_inspect/]      | `env`    | No       |
| `HELM_DEPENDENCY_UPDATE_FLAGS` | Combination of helm dependency update supported flags. [here                                                                    | https://helm.sh/docs/helm/dependency_update/] | `env`    | No       |
| `HELM_PACKAGE_FLAGS`           | Combination of helm package supported flags. [here                                                                              | https://helm.sh/docs/helm/helm_package/]      | `env`    | No       |
| `HELM_PUSH_FLAGS`              | Combination of helm push supported flags. [here                                                                                 | https://helm.sh/docs/helm/helm_push/]         | `env`    | No       |

## Action versions

- master: helm3 v3.11.2

## License

This project is distributed under the [MIT license](LICENSE.md).
