# [DBACLD-240809] Upgrade embedded Maven to 3.9.16

> **PR scope:** `pom.xml` only (2 files touched: `pom.xml` + migration doc update).  
> **Author:** Abhijit Humbe — merged into `7.81.x-blue-jakarta` (commit `2b674243`).

---

## 1. Version Property Changes

| Property | Before | After |
|---|---|---|
| `version.org.apache.maven` | `3.8.6` | `3.9.16` |
| `version.org.apache.maven.resolver` | `1.6.3` | `1.9.27` |
| `version.org.apache.maven.wagon` | `3.5.1` | `3.5.3` |
| `version.org.codehaus.plexus.plexus-classworlds` | `2.6.0` | `2.11.0` |

> `version.org.eclipse.sisu` (`0.3.5` → `1.0.1`) was part of the broader Jakarta migration, not this specific PR — it is documented in `javax_jakarta_migration.md`.

---

## 2. New `guice` Exclusions in `dependencyManagement`

Maven 3.9.x bundles its own `com.google.inject:guice`, which conflicts with the project's own Guice dependency. The PR added explicit exclusions to the following managed artifacts:

| Artifact (`groupId:artifactId`) | Exclusion added |
|---|---|
| `org.apache.maven:maven-embedder` | `com.google.inject:guice` |
| `org.apache.maven:maven-core` | `com.google.inject:guice` |
| `org.apache.maven:maven-compat` | `com.google.inject:guice` |
| `org.apache.maven:maven-model-builder` | `com.google.inject:guice` |
| `org.apache.maven.resolver:maven-resolver-util` | `com.google.inject:guice` |

---

## 3. Rationale

Maven 3.9.x ships Guice 6.x as an internal dependency. Without explicit exclusions the Guice version bundled inside `maven-embedder` / `maven-core` would conflict with the project's own `com.google.inject:guice:4.0`, causing `NoSuchMethodError` / duplicate-class issues at runtime when running embedded Maven builds (e.g. kie-ci, drools-compiler tests).
