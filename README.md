# FreshCart

FreshCart is a small grocery-delivery application built with a TypeScript/Express checkout API, a Vite-powered storefront, and PostgreSQL.

This repository contains my containerization work on the FreshCart application, including multi-stage Docker builds, Docker Compose orchestration, container security, vulnerability investigation, and Docker build-cache optimization.

## Architecture

FreshCart consists of three main services:

- **`storefront/`** — a Vite + TypeScript frontend that serves the grocery storefront.
- **`checkout-api/`** — an Express + TypeScript API responsible for products, search, and orders.
- **PostgreSQL** — stores product and order data.

The application is orchestrated locally using Docker Compose.

## Containerization

The application is containerized using:

- Multi-stage Docker builds
- Minimal Alpine-based runtime images
- Non-root container users
- Docker Compose
- Docker's Compose network
- A named PostgreSQL volume
- PostgreSQL initialization through `checkout-api/db/init.sql`

### Checkout API

The Checkout API uses a multi-stage Docker build.

The builder stage installs the application dependencies, compiles the TypeScript application, and removes development dependencies before the production files are copied into the final runtime stage.

The final image contains only what is required to run the application.

This keeps build tooling and unnecessary development dependencies out of the runtime image.

### Storefront

The storefront also uses a multi-stage Docker build.

The Node.js build stage installs the frontend dependencies and generates the Vite production build.

The resulting static files are then copied into an Nginx Alpine runtime image, where Nginx serves the application as a non-root user.

## Docker Compose

Docker Compose runs the storefront, checkout API, and PostgreSQL database together.

The basic service relationship is:

```text
                    Docker Compose Network

              ┌─────────────────────┐
              │     Storefront      │
              │      :8080          │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │    Checkout API     │
              │      :3000          │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │     PostgreSQL      │
              │      :5432          │
              └──────────┬──────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │   postgres_data     │
              │   Named Volume      │
              └─────────────────────┘
```

The Checkout API communicates with PostgreSQL using the Docker Compose service name `db`.

PostgreSQL uses the `postgres_data` named volume so that database data is not tied to the lifecycle of the database container.

The `checkout-api/db/init.sql` file is mounted into PostgreSQL's initialization directory so the database can be initialized with the application's schema and seed data.

## Build Optimization

The Dockerfiles are intentionally structured so that dependency installation happens before application source code is copied.

For example, the Checkout API follows this order:

```dockerfile
COPY package*.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src ./src

RUN npm run build
```

This allows Docker to reuse the dependency installation layer when only application source code changes.

I tested this by rebuilding the Checkout API after a source-code change.

Docker reused the existing dependency and build layers from cache, which meant that `npm ci` did not need to run again.

This demonstrated why Dockerfile layer ordering matters when optimizing rebuild times.

## Security

The final containers are configured to run as non-root users.

The multi-stage builds also prevent development dependencies and unnecessary build tooling from being included in the final runtime images.

I also scanned the Checkout API image using Docker Scout to investigate vulnerabilities in the final image.

### Vulnerability Investigation

The initial scan identified vulnerabilities in several packages, including:

- `ip-address`
- `brace-expansion`
- `undici`
- `tar`

At first, I assumed the vulnerabilities were coming directly from my application dependencies.

After investigating the dependency tree, I found that some of the vulnerable packages were transitive dependencies, including packages pulled in through npm's own dependency chain.

Rather than simply trying to force the vulnerability count to zero, I investigated where the packages came from, checked the available fixed versions, updated the relevant dependencies where appropriate, rebuilt the image, and scanned it again.

The final Checkout API image scan reported:

```text
0 Critical
3 High
6 Medium
0 Low
```

The remaining findings were documented and investigated rather than blindly attempting to eliminate every finding without understanding its source and relevance.

The vulnerability scan output and image inspection information are included in this repository.

## Running the Application

### Prerequisites

- Docker Desktop
- Docker Compose

### Start the Application

```bash
docker compose up -d
```

### Check the Running Services

```bash
docker compose ps
```

The services are available locally at:

| Service | Address |
|---|---|
| Storefront | http://localhost:8080 |
| Checkout API | http://localhost:3000 |
| PostgreSQL | localhost:5432 |

The Checkout API does not serve a webpage at `/`. Its functionality is exposed through its API endpoints.

For example:

```bash
curl http://localhost:3000/healthz
```

## API Reference

| Method | Path | Description |
|---|---|---|
| `GET` | `/healthz` | Checks API health and database connectivity |
| `GET` | `/api/products` | Lists all products |
| `GET` | `/api/products/:id` | Returns a single product |
| `POST` | `/api/orders` | Creates an order |
| `GET` | `/api/orders/:id` | Returns an order and its line items |

## Project Documentation

Supporting documentation for the containerization work includes:

- Multi-stage build layer diagram
- Container topology diagram
- Docker Scout vulnerability scan
- Docker image inspection output
- Docker build-cache testing

The repository also contains the supporting scan and inspection files used during the vulnerability investigation.

## What I Learned

This project changed the way I think about containerization.

I initially approached the vulnerability findings as something that needed to be fixed directly inside my application dependencies. Investigating the dependency tree showed me that vulnerabilities can originate several levels down a dependency chain, including packages pulled in by tooling such as npm itself.

The build-cache exercise also made Docker's layer model much more concrete for me. I now understand that a Dockerfile is not simply a list of commands used to create an image. The order of those commands affects caching, rebuild time, image contents, and the final runtime attack surface.

I also learned that vulnerability scanning is not just about chasing a zero-vulnerability score. It is about understanding what was found, where it came from, whether a fix exists, and making a reasonable security decision.

## Original Application

FreshCart started as a learning application containing a storefront, checkout API, and PostgreSQL schema. This repository contains my containerization, security investigation, optimization, and documentation work built on top of that application.