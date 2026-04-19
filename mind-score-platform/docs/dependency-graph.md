# Dependency Graph

> Generated during codebase cleanup (Track 4 — Circular Dependencies audit).  
> Last verified: April 2026. No circular dependencies found.

---

## Backend Assembly Graph

```
Domain            (zero external references)
   ↑
Application  →  Domain
   ↑
Infrastructure  →  Application  →  Domain
   ↑
WebApi  →  Infrastructure  →  Application  →  Domain
```

Direction is strict and unidirectional. Verified by inspecting all four `.csproj` files:
- `Domain.csproj` — no `<ProjectReference>`
- `Application.csproj` — references Domain only
- `Infrastructure.csproj` — references Application + Domain only
- `WebApi.csproj` — references Infrastructure + Application only

No assembly-level cycle is even possible in the current build — a circular `<ProjectReference>` would be a compile error.

---

## Backend Namespace Graph (within Infrastructure)

```
Infrastructure.Persistence
        ↑ (DB context)
Infrastructure.Services           ──→  Infrastructure.Services.Mpi
Infrastructure.Services.Scoring   ──→  Infrastructure.Services.Mpi
                                            ↓
                                   Application.* only (interfaces, DTOs)
```

Detailed flow:

| Namespace | Imports from |
|---|---|
| `Services/` (root) | `Services/Mpi`, `Services/Scoring`, `Persistence`, `Application.*` |
| `Services/Scoring/` | `Services/Mpi`, `Persistence`, `Application.*`, `Domain.*` |
| `Services/Mpi/` | `Application.*` only — **never references back to `Services/` or `Services/Scoring/`** |
| `Persistence/` | `Domain.*` only |

All arrows are DAG edges. **No cycle.**

---

## Flutter Provider Graph

```
core/* (models, constants, network, services)   ← leaf layer
        ↑
auth_provider           → core/*
tests_provider          → core/*
test_provider           → core/*
        ↑
results_provider        → core/*, auth_provider
        ↑
mpi_result_provider     → mpi_models, results_provider
```

Verified by tracing `import` directives in all 5 provider files.  
**No cycle.** `results_provider` does NOT import from `mpi_result_provider`.

---

## Flutter Screen / Widget Graph

```
core/* ← widgets/* ← screens/* ← router/app_router.dart
```

- Screens import providers and widgets — never vice versa
- Widgets import only `core/*` and occasionally other `widgets/*`
- Router imports all screens — nothing imports the router

**No cycle.**

---

## Verdict

| Layer | Cycles found | Action required |
|---|---|---|
| .NET assembly references | ❌ None | None |
| .NET namespace-level (Infrastructure) | ❌ None | None |
| Flutter providers | ❌ None | None |
| Flutter screens / widgets | ❌ None | None |

The codebase maintains clean unidirectional dependency flow throughout.
