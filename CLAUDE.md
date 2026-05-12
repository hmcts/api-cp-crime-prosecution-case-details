# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Keep replies extremely concise. No filler.

## Code Rules (non-negotiable)
- No comments unless the WHY is genuinely non-obvious (hidden constraint, workaround, surprising invariant). Never explain WHAT the code does.
- No multi-line comment blocks or docstrings.
- No error handling for scenarios that cannot happen. Trust internal code and framework guarantees. Only validate at real system boundaries (user input, external APIs).
- No features, refactoring, or abstractions beyond what the task requires. Three similar lines > premature abstraction.
- No half-finished implementations. No TODOs left in code.
- No feature flags or fallbacks for hypothetical future requirements.
- Bug fix = fix the bug only. Do not clean up surroundings.

## Overview

This is an **OpenAPI-first API specification library** for the HMCTS Common Platform — it defines the Crime Prosecution Case Details API contract and generates Spring Boot Java models and controller interfaces from an OpenAPI 3.1 spec. Unlike pure spec-only libraries, this repo also contains a runnable Spring Boot application with controller, service, and exception handler implementations.

- **Java 25**, **Spring Boot 4.0.2**, **Gradle**
- Generated code lives in `build/generated/` — do not edit directly
- Source of truth: `src/main/resources/openapi/openapi-spec.yml`

## Commands

### Build
```bash
./gradlew build -DAPI_SPEC_VERSION=<version>   # full build with tests
./gradlew build -x test                         # skip tests
```

`API_SPEC_VERSION` defaults to `0.0.999` locally. In CI it is generated from git history.

### Test
```bash
./gradlew test                                                                      # all tests
./gradlew test --tests 'uk.gov.hmcts.cp.config.OpenApiObjectsTest'                 # single class
./gradlew test --tests 'uk.gov.hmcts.cp.config.OpenApiObjectsTest.methodName'      # single method
./gradlew check                                                                     # tests + JaCoCo coverage
```

### Code Quality
```bash
./gradlew pmdMain                                                      # PMD static analysis
./gradlew spotlessCheck                                                # code formatting check
./gradlew spotlessApply                                                # auto-fix formatting
spectral lint "src/main/resources/openapi/*.{yml,yaml}"               # OpenAPI spec linting
./gradlew jacocoTestReport                                             # coverage report → build/reports/jacoco/
./gradlew publishToMavenLocal                                          # publish to local Maven repo
```

## Architecture

### OpenAPI-First Code Generation

The build pipeline generates Java from the OpenAPI spec via the **OpenAPI Generator** (Gradle plugin, `gradle/openapi.gradle`):

1. Input: `src/main/resources/openapi/openapi-spec.yml`
2. Schema definitions: `src/main/resources/openapi/schema/prosecutionCase.schema.json`
3. Output: `build/generated/src/main/java/uk/gov/hmcts/cp/openapi/`
   - `api/CaseDetailsApi.java` — Spring `@RequestMapping` interface
   - `model/*.java` — DTOs with Lombok (`@Builder`, `@AllArgsConstructor`, `@NoArgsConstructor`) and `@JsonInclude(NON_NULL)`

Changing the data model or endpoint means editing the OpenAPI spec, then running `./gradlew openApiGenerate`.

### API Endpoint

```
GET /cases/{case_urn}
  → 200 CaseDetailResponse
  → 400 ErrorResponse
  → 404 (no body)
```

### Implementation Layer

Unlike sibling `api-cp-*` spec-only repos, this repo contains a Spring Boot application implementing the generated `CaseDetailsApi` interface:

- `CaseDetailsController` — implements `CaseDetailsApi`; sanitizes `case_urn` input via OWASP Encoder before delegating to the service
- `CaseDetailsService` — validates the URN is non-blank, returns a stub `CaseDetailResponse`; throws `ResponseStatusException` for invalid input
- `GlobalExceptionHandler` (`@RestControllerAdvice`) — catches `ResponseStatusException` and `Exception`; builds `ErrorResponse` with `traceId` (UUID) and `timestamp` (Instant)

### Key Domain Models

| Model | Purpose |
|---|---|
| `CaseDetailResponse` | Response body: `caseStatus` (String), `reportingRestrictions` (Boolean) |
| `ErrorResponse` | Machine-readable error: `error`, `message`, `details`, `timestamp` (Instant), `traceId` |

`OffsetDateTime` is mapped to `java.time.Instant` globally in `gradle/openapi.gradle`.

### Test Structure

- `OpenApiObjectsTest` — reflection-based; verifies generated model fields and API interface methods match the spec. Update this when adding fields to the OpenAPI spec.
- `CaseDetailsControllerTest` — Mockito unit test for the controller; mocks `CaseDetailsService`
- `CaseDetailsServiceTest` — plain unit test; verifies happy path and blank-URN validation
- `GlobalExceptionHandlerTest` — tests exception-to-response mapping

Test method names use underscores; this is intentional and permitted by the PMD ruleset.

### Gradle Configuration Modules

- `gradle/openapi.gradle` — OpenAPI code generation settings (packages, type mappings, Lombok injection)
- `gradle/java.gradle` — Java 25 (Temurin toolchain), `-Xlint:unchecked -Werror` (warnings are compiler errors); adds `build/generated/src/main/java` to the main source set
- `gradle/test.gradle` — JUnit Platform, JaCoCo, fail-fast enabled
- `gradle/pmd.gradle` — PMD rules (see `.github/pmd-ruleset.xml`); generated code is excluded
- `gradle/repositories.gradle` — GitHub Packages + Azure Artifacts; publishes to both
- `gradle/jar.gradle` — JAR manifest configuration
- `gradle/dependency.gradle` — `dependencyUpdates` task rejects non-stable candidate versions

## CI/CD Workflows

| Workflow | Trigger | Purpose |
|---|---|---|
| `ci-draft.yml` | PR / push to main | Generates artefact version, updates spec version, builds, publishes draft to GitHub Packages + Azure Artifacts + SwaggerHub |
| `ci-released.yml` | GitHub Release published | Publishes release version |
| `lint-openapi.yml` | PR | Spectral + AJV validation of OpenAPI spec and JSON schemas |
| `code-analysis.yml` | PR | PMD static analysis |
| `codeql.yml` | PR + weekly | Security analysis + CycloneDX SBOM |
| `secrets-scanner.yml` | PR + push | Secret scanning |
| `publish-openapi-spec.yml` | Called by ci-draft / ci-released | Publishes spec to SwaggerHub/APIHub |

Artifact publishing requires `GITHUB_TOKEN`, `AZURE_DEVOPS_ARTIFACT_USERNAME`, and `AZURE_DEVOPS_ARTIFACT_TOKEN` environment variables.
