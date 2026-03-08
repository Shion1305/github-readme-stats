# Docker Deployment Guide

This guide explains how to self-host GitHub Readme Stats using Docker.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
  - [Using Pre-built Images (Easiest)](#using-pre-built-images-easiest)
  - [Building from Source](#building-from-source)
- [Configuration](#configuration)
- [Deployment Methods](#deployment-methods)
  - [Docker Compose (Recommended)](#docker-compose-recommended)
  - [Docker CLI](#docker-cli)
  - [Building Custom Images](#building-custom-images)
- [Environment Variables](#environment-variables)
- [GitHub Container Registry](#github-container-registry)
- [Health Checks](#health-checks)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- Docker installed (version 20.10 or higher)
- Docker Compose (optional, but recommended)
- A GitHub Personal Access Token (PAT) - [How to create one](https://github.com/settings/tokens)

## Quick Start

### Using Pre-built Images (Easiest)

Use the pre-built Docker images from GitHub Container Registry:

1. Create a `.env` file:
   ```bash
   cat > .env << 'EOF'
   PAT_1=your_github_personal_access_token_here
   PORT=9000
   CACHE_SECONDS=21600
   EOF
   ```

2. Run with Docker Compose:
   ```bash
   curl -O https://raw.githubusercontent.com/Shion1305/github-readme-stats/master/docker-compose.ghcr.yml
   docker-compose -f docker-compose.ghcr.yml up -d
   ```

3. Or run with Docker CLI:
   ```bash
   docker run -d \
     --name github-readme-stats \
     -p 9000:9000 \
     -e PAT_1=your_github_token_here \
     --restart unless-stopped \
     ghcr.io/shion1305/github-readme-stats:latest
   ```

4. Access the service at `http://localhost:9000`

### Building from Source

If you want to build the image yourself:

1. Clone this repository:
   ```bash
   git clone https://github.com/Shion1305/github-readme-stats.git
   cd github-readme-stats
   ```

2. Create a `.env` file from the example:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` and add your GitHub Personal Access Token:
   ```bash
   PAT_1=your_github_personal_access_token_here
   ```

4. Start the service using Docker Compose:
   ```bash
   docker-compose up -d
   ```

5. Access the service at `http://localhost:9000`

## Configuration

### Creating a GitHub Personal Access Token

For detailed instructions on creating a PAT, see the [main README](readme.md#first-step-get-your-personal-access-token-pat).

**Classic Token Scopes:**
- `repo`
- `read:user`

**Fine-grained Token Permissions:**
- Commit statuses: read-only
- Contents: read-only
- Issues: read-only
- Metadata: read-only
- Pull requests: read-only

## Deployment Methods

### Docker Compose (Recommended)

Docker Compose is the easiest way to deploy the application.

**Basic deployment:**
```bash
docker-compose up -d
```

**View logs:**
```bash
docker-compose logs -f
```

**Stop the service:**
```bash
docker-compose down
```

**Restart the service:**
```bash
docker-compose restart
```

**Update to latest version:**
```bash
git pull
docker-compose build
docker-compose up -d
```

### Docker CLI

If you prefer using Docker commands directly:

**Build the image:**
```bash
docker build -t github-readme-stats .
```

**Run the container:**
```bash
docker run -d \
  --name github-readme-stats \
  -p 9000:9000 \
  -e PAT_1=your_github_token_here \
  -e CACHE_SECONDS=21600 \
  --restart unless-stopped \
  github-readme-stats
```

**Using environment file:**
```bash
docker run -d \
  --name github-readme-stats \
  -p 9000:9000 \
  --env-file .env \
  --restart unless-stopped \
  github-readme-stats
```

**Stop the container:**
```bash
docker stop github-readme-stats
```

**Remove the container:**
```bash
docker rm github-readme-stats
```

### Building Custom Images

The Dockerfile includes multi-stage builds for different use cases:

**Production build (default):**
```bash
docker build -t github-readme-stats:latest --target runner .
```

**Development build:**
```bash
docker build -t github-readme-stats:dev --target dev .
```

**Run tests in Docker:**
```bash
docker build -t github-readme-stats:test --target dev .
docker run --rm github-readme-stats:test npm test
```

## Environment Variables

All environment variables should be defined in the `.env` file or passed to Docker. See `.env.example` for all available options.

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `PAT_1` | GitHub Personal Access Token | `ghp_xxxxxxxxxxxx` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `9000` |
| `CACHE_SECONDS` | Cache duration in seconds | `21600` (6 hours) |
| `WHITELIST` | Comma-separated list of allowed usernames | All users allowed |
| `GIST_WHITELIST` | Comma-separated list of allowed Gist IDs | All gists allowed |
| `EXCLUDE_REPO` | Comma-separated list of repositories to exclude | None |
| `FETCH_MULTI_PAGE_STARS` | Fetch all starred repos (may increase response time) | `false` |
| `PAT_2`, `PAT_3`, ... | Additional tokens for load balancing | None |

### Using Multiple Tokens

To handle higher traffic, you can provide multiple GitHub tokens:

```env
PAT_1=your_first_token
PAT_2=your_second_token
PAT_3=your_third_token
```

The application will automatically rotate between tokens to avoid rate limits.

## GitHub Container Registry

This repository automatically publishes Docker images to GitHub Container Registry (GHCR) on every push to the main branch and on releases.

### Available Tags

Images are available at `ghcr.io/shion1305/github-readme-stats` with the following tags:

- `latest` - Latest build from the main branch
- `master` - Latest build from the master branch
- `v1.0.0` - Specific version tags (when releases are created)
- `1.0` - Major.minor version tags
- `1` - Major version tags
- `master-sha-abc1234` - Specific commit SHA tags

### Multi-Architecture Support

Pre-built images support multiple architectures:
- `linux/amd64` - Standard x86-64 systems
- `linux/arm64` - ARM64 systems (Apple Silicon, AWS Graviton, etc.)
- `linux/arm/v7` - ARMv7 systems (Raspberry Pi, etc.)

Docker will automatically pull the correct image for your platform.

### Pull Images

**Latest version:**
```bash
docker pull ghcr.io/shion1305/github-readme-stats:latest
```

**Specific version:**
```bash
docker pull ghcr.io/shion1305/github-readme-stats:v1.0.0
```

**Check available tags:**
Visit the [packages page](https://github.com/Shion1305/github-readme-stats/pkgs/container/github-readme-stats) to see all available tags.

### Using in Docker Compose

Use the pre-built image by using `docker-compose.ghcr.yml`:

```bash
curl -O https://raw.githubusercontent.com/Shion1305/github-readme-stats/master/docker-compose.ghcr.yml
docker-compose -f docker-compose.ghcr.yml up -d
```

Or modify your `docker-compose.yml` to use the pre-built image:

```yaml
services:
  github-readme-stats:
    image: ghcr.io/shion1305/github-readme-stats:latest
    # ... rest of your configuration
```

### Image Size and Layers

The production image is optimized for size:
- Base image: Alpine Linux
- Multi-stage build to minimize layers
- Production-only dependencies
- Typical compressed size: ~200-250MB

### Security

All published images include:
- Build provenance attestation
- SBOM (Software Bill of Materials)
- Vulnerability scanning via GitHub Security
- Running as non-root user
- Read-only filesystem support

### CI/CD Pipeline

Images are automatically built and published when:
1. **Push to master/main** - Creates `latest` and branch-specific tags
2. **Pull requests** - Builds but doesn't push (for testing)
3. **Releases** - Creates version tags (v1.0.0, 1.0, 1, latest)
4. **Manual trigger** - Via GitHub Actions workflow dispatch

See [.github/workflows/docker-publish.yml](.github/workflows/docker-publish.yml) for the complete workflow.

## Health Checks

The Docker Compose configuration includes a health check that pings the API every 30 seconds.

**Check health status:**
```bash
docker ps
```

Look for the `STATUS` column showing `healthy` or `unhealthy`.

**Manual health check:**
```bash
curl http://localhost:9000/api?username=anuraghazra
```

You should receive an SVG response.

## Troubleshooting

### Container exits immediately

**Check logs:**
```bash
docker logs github-readme-stats
```

Common issues:
- Missing `PAT_1` environment variable
- Port 9000 already in use
- Invalid configuration

### Port already in use

Change the port in `.env`:
```env
PORT=3000
```

Or in `docker-compose.yml`:
```yaml
ports:
  - "3000:9000"
```

### API rate limit errors

Solutions:
1. Add multiple GitHub tokens (`PAT_2`, `PAT_3`, etc.)
2. Increase `CACHE_SECONDS` to cache responses longer
3. Use a token with higher rate limits

### Cards not showing private stats

Ensure your GitHub token has the correct scopes:
- Classic token: `repo` and `read:user`
- Fine-grained token: All required repository permissions

### Container uses too much memory

If you're on Vercel Pro plan or have memory constraints:
1. Reduce concurrent requests
2. Increase cache duration
3. Consider vertical scaling of your host

### Cannot connect to Docker daemon

**Start Docker:**
```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker
```

### Updating the deployment

**Pull latest changes:**
```bash
git pull origin master
```

**Rebuild and restart:**
```bash
docker-compose build
docker-compose up -d
```

**Or using Docker CLI:**
```bash
docker build -t github-readme-stats .
docker stop github-readme-stats
docker rm github-readme-stats
docker run -d --name github-readme-stats -p 9000:9000 --env-file .env github-readme-stats
```

## Usage Examples

Once deployed, use your self-hosted instance instead of the public one:

```markdown
![GitHub Stats](http://localhost:9000/api?username=anuraghazra)
![Top Languages](http://localhost:9000/api/top-langs?username=anuraghazra)
![Repo Card](http://localhost:9000/api/pin/?username=anuraghazra&repo=github-readme-stats)
```

For production deployment, replace `localhost:9000` with your domain:

```markdown
![GitHub Stats](https://your-domain.com/api?username=anuraghazra)
```

## Production Considerations

### Reverse Proxy

For production, it's recommended to use a reverse proxy like Nginx or Caddy:

**Nginx example:**
```nginx
server {
    listen 80;
    server_name stats.yourdomain.com;

    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**Caddy example:**
```
stats.yourdomain.com {
    reverse_proxy localhost:9000
}
```

### SSL/TLS

Use Let's Encrypt with Caddy (automatic) or Certbot with Nginx for HTTPS.

### Monitoring

Consider adding monitoring tools like:
- Prometheus + Grafana for metrics
- Uptime monitoring services
- Log aggregation (ELK stack, Loki, etc.)

### Backup

Backup your `.env` file securely (encrypted):
```bash
# Encrypt
gpg -c .env

# Decrypt
gpg .env.gpg
```

## Docker Hub

If you want to push your custom image to Docker Hub:

```bash
docker tag github-readme-stats:latest yourusername/github-readme-stats:latest
docker push yourusername/github-readme-stats:latest
```

Then others can use:
```bash
docker pull yourusername/github-readme-stats:latest
```

## Support

For issues related to:
- **Docker setup**: Open an issue in this repository
- **GitHub Readme Stats features**: See the [main README](readme.md)
- **General questions**: Check the [FAQ](https://github.com/anuraghazra/github-readme-stats/discussions/1770)
