# Go-Web-App

A simple Go web application with static HTML pages, Docker multi-stage build, and Kubernetes deployment manifests. This repository demonstrates how to build a minimal Go HTTP server, containerize it, and deploy it using Kubernetes and Helm.

## What this repository contains

- `main.go` — the Go HTTP server.
- `main_test.go` — a basic unit test for the `/home` route.
- `Dockerfile` — a multi-stage build that compiles the Go binary and packages it in a distroless container.
- `static/` — static HTML files served by the application.
- `k8s/manifests/` — Kubernetes YAML manifests for Deployment, Service, and Ingress.
- `helm/go-web-app/` — a Helm chart to package and deploy the application.

## What the app does

The Go app serves four static pages:

- `/home` → `static/home.html`
- `/courses` → `static/courses.html`
- `/about` → `static/about.html`
- `/contact` → `static/contact.html`

The server listens on `0.0.0.0:8080` and uses the standard `net/http` package.

## Development stages

### Stage 1: Know how the application works

- Read `main.go` to understand the route handlers and how `http.ServeFile` serves the HTML content.
- Confirm the endpoint mapping for `/home`, `/courses`, `/about`, and `/contact`.
- Verify the static files in the `static/` folder and ensure they match the served paths.

### Stage 2: Build the Docker image

- Use `Dockerfile` to compile the Go application in a `golang:1.22.5` builder image.
- Copy the compiled binary and `static/` assets into a minimal `gcr.io/distroless/base` runtime image.
- Build and run the container locally to ensure the application starts and serves pages.

### Stage 3: Create Kubernetes manifest files

- Define `k8s/manifests/deployment.yml` to run the containerized app in a Kubernetes Deployment.
- Create `k8s/manifests/service.yml` to expose the app internally on port `80` while targeting container port `8080`.
- Add `k8s/manifests/ingress.yml` to route external requests to the service via an NGINX ingress controller.

### Stage 4: Package and deploy with Helm

- Use `helm/go-web-app/Chart.yaml` as the Helm chart metadata for packaging the application.
- Install the chart with `helm install` and manage updates with `helm upgrade`.
- Use Helm to standardize deployment and eventual parameterization of values like image tag or replica count.

## How it is built

### Go application

- `main.go` defines handler functions that use `http.ServeFile`.
- `http.HandleFunc` registers the route handlers.
- `http.ListenAndServe("0.0.0.0:8080", nil)` starts the web server.

### Docker multi-stage build

The `Dockerfile` builds the Go binary in a `golang:1.22.5` builder image and copies the compiled `main` executable plus the `static/` folder into a minimal `gcr.io/distroless/base` runtime image.

Build and run locally with Docker:

```bash
docker build -t go-web-app:latest .
docker run --rm -p 8080:8080 go-web-app:latest
```

Then open `http://localhost:8080/home`.

## How deployment is done

### Kubernetes manifests

The repository contains plain Kubernetes manifests in `k8s/manifests/`:

- `deployment.yml` — deploys a single replica of the containerized app.
- `service.yml` — exposes the app internally on port `80` and forwards to container port `8080`.
- `ingress.yml` — routes `go-web-app.local` to the service using an NGINX ingress controller.

Example deploy commands:

```bash
kubectl apply -f k8s/manifests/deployment.yml
kubectl apply -f k8s/manifests/service.yml
kubectl apply -f k8s/manifests/ingress.yml
```

### Helm chart

A Helm chart is available in `helm/go-web-app/` and defines the application package metadata.

Chart metadata includes:

- `apiVersion: v2`
- `name: go-web-app`
- `type: application`
- `version: 0.1.0`
- `appVersion: "1.16.0"`

To install with Helm:

```bash
helm install go-web-app ./helm/go-web-app
```

To upgrade or uninstall:

```bash
helm upgrade go-web-app ./helm/go-web-app
helm uninstall go-web-app
```

## Testing

A simple test in `main_test.go` verifies that the `/home` handler returns HTTP 200 and serves HTML content.

Run tests with:

```bash
go test ./...
```

## Project structure

- `main.go` — server entrypoint and route handlers
- `main_test.go` — test coverage for the home page handler
- `Dockerfile` — container build instructions
- `go.mod` — Go module configuration
- `static/` — HTML pages and image assets
- `k8s/manifests/` — Kubernetes Deployment, Service, and Ingress manifests
- `helm/go-web-app/` — Helm chart metadata and templates

## Notes

- The app uses hard-coded paths to static HTML files.
- The Docker image is intentionally minimal with distroless runtime.
- The Kubernetes manifests use a fixed image `ravikudal/go-web-app:v1`; update this image tag to match your build and registry.
- The Ingress rules assume an NGINX ingress controller and a host named `go-web-app.local`.

## How to extend it

- Add a root `/` route and navigation page.
- Add configuration support for host, port, or static directory.
- Add more tests for other handlers.
- Parameterize Helm values for image repository, tag, and replica count.
- Add TLS support to the ingress manifest.
