## Repo: api-cp-crime-prosecution-case-details

OpenAPI-first API spec library for retrieving crime prosecution case details by URN — this is a hybrid repo that includes both the generated Spring interface and a working controller implementation.

**Pattern**: Hybrid (spec + implementation)
**OpenAPI spec version**: 3.1.0
**OpenAPI Generator version**: 7.19.0 (target 7.22.0 per upgrade cycle)
**Spring Boot version**: 4.0.2 (target 4.0.6+ per upgrade cycle)

## API Endpoint(s)

```
GET /cases/{case_urn}
  → 200 CaseDetailResponse
  → 400 ErrorResponse
  → 401 Unauthorized
  → 403 Forbidden
  → 404 ErrorResponse
  → 500 ErrorResponse
```

Security: Bearer JWT auth.

## Generated Interfaces & Schema

- Schema files: schemas defined inline in `components/schemas` (no separate `.schema.json` files)
- Generated API interface: `uk.gov.hmcts.cp.openapi.api.CaseDetailsApi`
- Generated models:
  - `CaseDetailResponse` — prosecution case details including case URN, hearings, and defendant information
  - `ErrorResponse` — machine-readable error with `error`, `message`, `details`, `timestamp` (Instant), `traceId`

## Domain Models

| Model | Purpose |
|---|---|
| `CaseDetailResponse` | Full prosecution case view returned on GET /cases/{case_urn} |
| `ErrorResponse` | Structured error envelope with traceId for error correlation |

## Test Structure

| Class | What it validates |
|---|---|
| `OpenApiObjectsTest` | Reflection-based contract test verifying generated model fields and API interface method signatures match the spec |
| `GlobalExceptionHandlerTest` | Exception handler maps domain exceptions to correct HTTP status codes |
| `CaseDetailsControllerTest` | Controller delegates to service and returns correct responses; Mockito-based |
| `CaseDetailsServiceTest` | Service orchestration: calls clients and maps responses correctly |

## Generator Config Notes

- `@JsonInclude(NON_NULL)` is absent from `additionalModelTypeAnnotations` — add to align with standard.
- `inputSpec` uses modern `.set()` syntax.

## CI/CD Deviations

Standard workflow set — no deviations: `ci-draft.yml`, `ci-released.yml`, `lint-openapi.yml`, `code-analysis.yml`, `codeql.yml`, `secrets-scanner.yml`, `publish-openapi-spec.yml`.

## Repo-Specific Notes

- **Hybrid repo**: Contains `Application.java` with `@SpringBootApplication` and a `CaseDetailsController` that directly implements the generated `CaseDetailsApi` interface. Unlike pure spec-only repos, this repo is runnable as a Spring Boot application.
- **docs/ present**: Contains additional API documentation.
- The controller implementation lives alongside the generated interface in the same module — do not extract it to a separate service repo without updating the downstream consumers.
- Run `/openapi-spec-reviewer` when authoring or reviewing the OpenAPI spec.
