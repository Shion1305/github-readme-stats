# GitHub Actions Workflows

This directory contains automated CI/CD workflows for the GitHub Readme Stats project.

## Workflows

### 1. Docker Publish (`docker-publish.yml`)

Builds and publishes Docker images to GitHub Container Registry on every push and pull request.

**Triggers:**
- Push to `master` or `main` branches
- Pull requests to `master` or `main` branches
- Tags matching `v*.*.*` pattern
- Manual workflow dispatch

**What it does:**
- Sets up Docker Buildx for multi-platform builds
- Logs in to GitHub Container Registry (GHCR)
- Extracts metadata for tags and labels
- Builds Docker image for `linux/amd64` and `linux/arm64`
- Pushes to GHCR (except for PRs)
- Uses GitHub Actions cache for faster builds
- Generates build provenance attestation

**Published tags:**
- `latest` - Latest build from default branch
- `master` or `main` - Latest build from respective branch
- `pr-123` - Pull request builds (not pushed)
- `master-sha-abc1234` - Commit SHA tags

**Usage:**
This workflow runs automatically. No manual intervention required.

### 2. Docker Release (`docker-release.yml`)

Builds and publishes multi-architecture Docker images when a new release is created.

**Triggers:**
- GitHub release published

**What it does:**
- Sets up QEMU for ARM emulation
- Builds for `linux/amd64`, `linux/arm64`, and `linux/arm/v7`
- Creates semantic version tags (v1.0.0, 1.0, 1, latest)
- Includes provenance and SBOM
- Posts a comment on the release with pull instructions

**Published tags:**
- `v1.0.0` - Exact version
- `1.0` - Major.minor version
- `1` - Major version
- `latest` - Always points to latest release

**Usage:**
Create a new release on GitHub to trigger this workflow.

## Image Registry

All images are published to:
```
ghcr.io/shion1305/github-readme-stats
```

## Permissions

The workflows require the following permissions:
- `contents: read` - To checkout the repository
- `packages: write` - To push images to GHCR
- `id-token: write` - For attestation
- `attestations: write` - For build provenance

These are automatically granted by GitHub Actions.

## Environment Variables

The workflows use the following environment variables:

| Variable | Description | Value |
|----------|-------------|-------|
| `REGISTRY` | Container registry | `ghcr.io` |
| `IMAGE_NAME` | Image name | `${{ github.repository }}` |

## Secrets

The workflows use these secrets (automatically provided by GitHub):

| Secret | Description |
|--------|-------------|
| `GITHUB_TOKEN` | Automatic token for authentication |

No additional secrets need to be configured.

## Cache Strategy

The workflows use GitHub Actions cache to speed up builds:
- Cache key: `type=gha`
- Mode: `max` (cache all layers)
- Automatically invalidated when dependencies change

## Multi-Architecture Builds

### docker-publish.yml
Builds for:
- `linux/amd64` (x86-64)
- `linux/arm64` (ARM 64-bit)

### docker-release.yml
Builds for:
- `linux/amd64` (x86-64)
- `linux/arm64` (ARM 64-bit)
- `linux/arm/v7` (ARM 32-bit, e.g., Raspberry Pi)

## Build Provenance

All images include:
- **Provenance attestation** - Cryptographically signed metadata about how the image was built
- **SBOM** - Software Bill of Materials listing all dependencies
- Viewable in the GitHub UI under the package details

## Manual Workflow Trigger

You can manually trigger the `docker-publish.yml` workflow:

1. Go to the [Actions tab](../../actions)
2. Select "Build and Publish Docker Image"
3. Click "Run workflow"
4. Select the branch
5. Click "Run workflow"

## Troubleshooting

### Build fails with "unauthorized"

The workflow might not have permission to push to GHCR. Check:
1. Repository settings → Actions → General
2. Ensure "Read and write permissions" is enabled for workflows

### Multi-arch build takes too long

Multi-architecture builds can take 10-20 minutes. This is normal because:
- ARM builds run in QEMU emulation
- Multiple platforms are built simultaneously
- All dependencies must be installed for each platform

### Cache not working

If builds don't use cache:
1. Check that previous builds succeeded
2. Verify cache size isn't too large (max 10GB)
3. Try clearing cache in repository settings

### Release workflow doesn't trigger

Ensure you're creating a GitHub Release, not just a tag:
1. Go to Releases → Draft a new release
2. Choose a tag or create a new one
3. Click "Publish release"

Tags alone won't trigger the workflow.

## Monitoring

View workflow runs:
- [All workflows](../../actions)
- [Docker Publish runs](../../actions/workflows/docker-publish.yml)
- [Docker Release runs](../../actions/workflows/docker-release.yml)

View published images:
- [Packages page](../../pkgs/container/github-readme-stats)

## Updating Workflows

When modifying workflows:
1. Test changes in a pull request first
2. PR builds will run but not push images
3. Merge to main to publish
4. Monitor the workflow run for issues

## Security

The workflows follow security best practices:
- Use specific action versions (not `@latest`)
- Run with minimal required permissions
- Use official GitHub-maintained actions
- Sign artifacts with attestation
- No secrets in logs or output

## Performance

Typical build times:
- **Single platform (PR)**: 3-5 minutes
- **Multi-platform (main)**: 8-12 minutes
- **Release (3 platforms)**: 15-25 minutes

Optimization techniques used:
- Multi-stage Docker builds
- Layer caching
- Parallel platform builds
- BuildKit optimizations

## Related Documentation

- [Docker Deployment Guide](../../DOCKER.md)
- [Main README](../../readme.md)
- [Contributing Guidelines](../../CONTRIBUTING.md)
