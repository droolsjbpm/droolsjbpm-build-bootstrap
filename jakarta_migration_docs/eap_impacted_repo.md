# EAP 8.1 / WildFly 35 — Impacted Repositories

> Source: `eap_migration.md`. Only items with **❌ / ⚠️** status are listed; ✅-aligned items are omitted.

---

## 1. Version Upgrades — `droolsjbpm-build-bootstrap` (BOM)

All version properties below live in [`droolsjbpm-build-bootstrap/pom.xml`](../pom.xml) and propagate to every downstream repo via BOM import.

| Property | Current | Required | Risk |
|---|---|---|---|
| `version.org.infinispan` | 14.0.27.Final | **15.0.x.Final** | API changes in cluster/cache config |
| `version.io.undertow` | 2.2.38.Final | **2.3.x.Final** | SPI changes in request handlers |
| `version.org.keycloak` | 20.0.3 | **24.0.x** | Legacy WF adapter removed → OIDC only |
| `version.jakarta.persistence-api` | 3.1.0 | **3.2.0** | `SequenceGenerator` / `IdClass` API deltas |
| `version.jakarta.enterprise.cdi-api` | 4.0.1 | **4.1.0** | Minor — `@Produces` resolution edge-cases |
| `version.jakarta.websocket-api` | 2.1.1 | **2.2.0** | Minor API additions |
| `version.jakarta.enterprise.concurrent-api` | 3.0.4 | **3.1.0** | Minor — `ContextServiceDefinition` changes |
| `version.jakarta.security.jacc-api` | 1.6.1 (EE 8) | **3.0.0** (`jakarta.authorization-api`) | Package rename + API overhaul |
| `version.bootable` (wildfly-jar-maven-plugin) | 6.1.2.Final | **13.0.x.Final** | Plugin config syntax changed for EAP 8 |
| `wildfly-maven-plugin` (pluginManagement) | 1.2.0.Final | **5.0.x.Final** | Goal renames; `execute-commands` changed |

---

## 2. Spring Upgrade — `droolsjbpm-integration` + `droolsjbpm-knowledge` + `jbpm-work-items`

Spring Boot 2.x uses `javax.*`; EAP 8.1 requires Spring Boot 3.x (`jakarta.*`).

| Property | Current | Required |
|---|---|---|
| `version.org.springframework.boot` | 2.7.18 | **3.3.x** |
| `version.org.springframework` | 5.3.39 | **6.1.x** |
| `version.org.springframework.security.web` | 5.7.14 | **6.3.x** |

**Affected modules** (own Spring Boot usage):

| Repository | Module path |
|---|---|
| `droolsjbpm-integration` | `kie-spring-boot/**` (starters, autoconfiguration, samples) |
| `droolsjbpm-knowledge` | `kie-archetypes/kie-service-spring-boot-archetype` |
| `jbpm-work-items` | `repository-springboot`, `jbpm-workitem-itests` |

**Breaking changes at code level:**

| Area | Spring 5→6 / Boot 2→3 breaking change |
|---|---|
| Namespace | All `javax.*` → `jakarta.*` in auto-config classes |
| Security | `WebSecurityConfigurerAdapter` removed → `SecurityFilterChain` bean |
| Data/JPA | `JpaRepository` bootstrap changes; Hibernate 6 column naming strategy |
| Web MVC | `HttpMethod` is now an interface; `MockMvc` import changed |
| Actuator | Many endpoint paths renamed under `/actuator` |
| Properties | Several `spring.*` config key names changed |
| Embedded Tomcat | Must be ≥ 10.1.x for `jakarta.*` servlet support |

---

## 3. Process Migration Service — `process-migration-service`

| File | Change | Detail |
|---|---|---|
| `process-migration-service/pom.xml` | Bump `version.org.wildfly` | `23.0.2.Final` → **`35.0.1.Final`** |
| `process-migration-service/pom.xml` | Update Cargo container ID | `wildfly23x` → **`wildfly35x`** |
| `process-migration-service/pom.xml` | Update Arquillian container | Ensure `wildfly-arquillian-container` = `5.1.0.Final` |

**Breaking changes:** WildFly 35 subsystem XML schemas differ; any `standalone.xml` / `domain.xml` snippets in integration tests must be reviewed.

---

## 4. WildFly Camel — `droolsjbpm-integration`

| Module | Risk |
|---|---|
| `droolsjbpm-integration/kie-camel` | 🔴 **High** — `org.wildfly.camel` subsystem dropped after WF 26; entire module unusable on EAP 8.1 |
| `droolsjbpm-integration/camel-container-tests` | 🔴 Same — camel container tests rely on the removed subsystem |

**Action:** Remove or replace `kie-camel` module; Camel must be embedded (Camel Quarkus / Spring Camel) rather than provided by the server subsystem.

---

## 5. Errai — `kie-wb-common`, `appformer`, `drools-wb`, `jbpm-wb`, `kie-wb-distributions`

| Risk | Detail |
|---|---|
| 🔴 **High** | `org.jboss.errai` 4.19.0-SNAPSHOT has no Jakarta EE 10 / CDI 4.x release |
| Code-level | `@Inject`, `@Portable`, `@Dependent` Errai equivalents may not bind with CDI 4.1 |
| GWT integration | Errai's GWT-CDI bridge is effectively abandoned |

**Affected repos** (all repos importing `jboss.errai`): `kie-wb-common`, `appformer`, `drools-wb`, `jbpm-wb`, `kie-wb-distributions`, `kie-uberfire-extensions`.

---

## 6. PicketLink — `appformer`, `drools-wb`, `kie-wb-common`

| File | Change required |
|---|---|
| `jboss-deployment-structure.xml` (in WARs) | Remove `org.picketlink` module dependency |
| Security config classes | Replace PicketLink identity/auth with **Elytron** security domain |
| `beans.xml` | Update CDI schema to version `4.0` |

**Affected repos:** `appformer` (`uberfire-showcase`), `drools-wb` (`drools-wb-webapp`), `kie-wb-common`.

**Breaking:** PicketLink `SecurityContext`, `Identity`, `Credentials` APIs removed entirely; full migration to Elytron / `jakarta.security.enterprise` required.

---

## 7. Keycloak Adapter — `appformer`, `kie-wb-distributions`, `droolsjbpm-integration`

| Risk | Detail |
|---|---|
| 🔴 **High** | Keycloak 24.x removed the legacy WildFly adapter (`keycloak-wildfly-adapter`) |
| Required action | Migrate to `keycloak-servlet-oauth-client` or configure native OIDC in Elytron |
| `jboss-deployment-structure.xml` | Remove `org.keycloak.keycloak-adapter-subsystem` dependency |

---

## 8. Deployment Descriptor Changes (all WAR-producing repos)

Applies to `kie-wb-distributions`, `droolsjbpm-integration`, `jbpm-wb`, `kie-wb-common` and any module producing a deployable WAR/EAR.

| Descriptor | Required change |
|---|---|
| `jboss-deployment-structure.xml` | Remove `org.picketlink`, remove `org.jboss.as.camel` |
| `persistence.xml` | Namespace → `https://jakarta.ee/xml/ns/persistence`, version `3.2` |
| `beans.xml` | Namespace → `https://jakarta.ee/xml/ns/cdi`, version `4.0` |
| Security subsystem config | Replace PicketLink / legacy security with Elytron security domain |

---

## Summary Matrix

| Repository | POM change needed | Code-level breaking change | Severity |
|---|---|---|---|
| `droolsjbpm-build-bootstrap` | 10 version property bumps (see §1) | None (BOM only) | Medium |
| `droolsjbpm-integration` | Spring Boot 3.x; Camel removal | Namespace, Security API, Camel subsystem | 🔴 High |
| `droolsjbpm-knowledge` | Spring Boot 3.x (archetype) | Archetype template `javax.*` → `jakarta.*` | Medium |
| `jbpm-work-items` | Spring Boot 3.x | Security/Web MVC API changes | Medium |
| `process-migration-service` | WildFly 35 + Cargo container ID | Integration test config | Low |
| `kie-wb-common` | None (inherits BOM) | PicketLink removal; Errai CDI 4.1 compat | 🔴 High |
| `appformer` | None (inherits BOM) | PicketLink removal; Errai CDI 4.1 compat | 🔴 High |
| `drools-wb` | None (inherits BOM) | PicketLink removal; Errai CDI 4.1 compat | 🔴 High |
| `jbpm-wb` | None (inherits BOM) | Errai CDI 4.1 compat | High |
| `kie-wb-distributions` | None (inherits BOM) | Keycloak adapter removal; descriptors | High |
| `jbpm` | None (inherits BOM) | Keycloak adapter; `persistence.xml` v3.2 | Medium |
