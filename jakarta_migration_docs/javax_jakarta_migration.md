# javax → jakarta Migration Notes — droolsjbpm-build-bootstrap

## Overview

This is the BOM/parent POM repository. All changes are in `pom.xml` (property version upgrades for Jakarta EE 10 compatibility).

---

## 1. Changed Dependencies (by module)

### Root `pom.xml` — Jakarta EE API versions

| Property | Old version | New version |
|---|---|---|
| `version.jakarta.annotation-api` | `1.3.5` | `2.1.1` |
| `version.jakarta.activation-api` | `1.2.2` | `2.1.4` |
| `version.jakarta.ejb-api` | `3.2.6` | `4.0.1` |
| `version.jakarta.el` | `3.0.3` | `5.0.0` |
| `version.jakarta.el-api` | `3.0.3` | `5.0.1` |
| `version.jakarta.enterprise.cdi-api` | `2.0.2` | `4.1.0` |
| `version.jakarta.enterprise.concurrent-api` | `1.1.2` | `3.1.1` |
| `version.jakarta.interceptor-api` | `1.2.5` | `2.2.0` |
| `version.jakarta.inject-api` | `1.0.3` | `2.0.1` |
| `version.jakarta.jms-api` | `2.0.3` | `3.1.0` |
| `version.jakarta.mail-api` | `1.6.8` | `2.1.5` |
| `version.jakarta.persistence-api` | `2.2.3` | `3.2.0` |
| `version.jakarta.resource-api` | `1.7.4` | `2.1.0` |
| `version.jakarta.servlet-api` | `4.0.3` | `6.1.0` |
| `version.jakarta.servlet.jsp-api` | `2.3.6` | `3.1.1` |
| `version.jakarta.servlet.jsp.jstl-api` | `2.0.0` | `3.0.2` |
| `version.jakarta.transaction-api` | `1.3.3` | `2.0.1` |
| `version.jakarta.ws.rs-api` | `2.1.6` | `4.0.0` |
| `version.jakarta.xml.ws-api` | `2.3.3` | `4.0.3` |
| `version.jakarta.validation-api` | _(absent)_ | `3.1.1` |
| `version.org.apache.maven` | `3.8.6` | `3.9.16` |
| `version.org.apache.maven.resolver` | `1.6.3` | `1.9.27` |
| `version.org.apache.maven.wagon` | `3.5.1` | `3.5.3` |
| `version.org.codehaus.plexus.plexus-classworlds` | `2.6.0` | `2.11.0` |
| `version.org.eclipse.sisu` | `0.3.5` | `1.0.1` |


### Root `pom.xml` — Third-party library versions

| Property | Old version | New version |
|---|---|---|
| `version.org.hibernate` | `5.4.24.Final` | `6.2.13.Final` |
| `version.org.hibernate.validator` | `6.2.0.Final` | `8.0.1.Final` |
| `version.org.hibernate.commons.annotations` | `5.0.5.Final` | `6.0.6.Final` |
| `version.org.jboss.resteasy` | `3.15.6.Final` | `6.2.16.Final` |
| `version.org.jboss.weld.weld` | `3.1.6.Final` | `5.1.7.Final` |
| `version.org.jboss.weld.weld-api` | `3.1.SP3` | `5.0.SP3` |
| `version.org.jboss.jbossts.jta` (Narayana) | `4.17.29.Final` | `7.0.2.Final` |
| `version.org.jboss.integration.narayana-tomcat` | `1.0.0.Final` | `2.0.0.Final` |
| `version.org.jboss.narayana.tomcat` | `5.9.0.Final` | `7.0.2.Final` |
| `version.org.jboss.ejb.client` | `4.0.39.Final` | `5.0.0.Final` |
| `version.org.jboss.logging.jboss-logging` | `3.4.1.Final` | `3.6.1.Final` |
| `version.org.apache.tomcat` | `9.0.111` | `10.1.56` |
| `version.org.apache.tomcat.tomcat-dbcp` | `9.0.111` | _removed_ (absorbed into `version.org.apache.tomcat`) |
| `version.org.apache.deltaspike.core` | `1.9.4` | `2.0.1` |
| `version.org.eclipse.jdt` | `3.18.0` | `3.33.0` |
| `version.org.eclipse.jetty` | `9.4.57.v20241219` | `11.0.26` |
| `version.org.eclipse.jgit` | `6.10.1.x` | `7.7.0.202606012155-r` |
| `version.org.eclipse.sisu` | `0.3.5` | `1.0.1` |
| `version.org.eclipse.parsson` | _(absent)_ | `1.1.9` |
| `version.org.glassfish.jaxb` | `2.3.2` | `4.0.5` |
| `version.org.javassist` | `3.26.0-GA` | `3.32.0-GA` |
| `version.com.sun.xml.bind` | `2.3.0` | _removed_ (→ `org.glassfish.jaxb`) |
| `version.com.fasterxml.jackson` | `2.18.6` | `2.20.0` |
| `version.com.fasterxml.jackson.annotations` | `${version.com.fasterxml.jackson}` | `2.22` |
| `version.com.google.code.gson` | `2.8.9` | `2.11.0` |
| `version.com.google.gwt` | `2.11.0` | `2.13.1` |
| `version.ch.qos.logback` | `1.5.15` | `1.5.37` |
| `version.commons-fileupload` | `1.6.0` | `2.0.0-M5` |
| `version.enforcer.plugin` | `3.0.0-M3` | `3.6.3` |

### New artifacts added

| groupId | artifactId | Notes |
|---|---|---|
| `io.swagger.core.v3` | `swagger-core-jakarta` | Jakarta variant |
| `io.swagger.core.v3` | `swagger-models-jakarta` | Jakarta variant |
| `io.swagger.core.v3` | `swagger-jaxrs2-jakarta` | Jakarta variant |
| `org.kie.server` | `kie-server` (classifier `ee10`) | EE10 WAR |
| `com.sun.jakarta.mail` | (new coords) | `2.0.2` |
| `com.sun.jakarta.activation` | (new coords) | `2.0.1` |
| `jakarta.validation` | `jakarta.validation-api` | `3.1.1` |
| `org.eclipse.parsson` | `parsson` | `1.1.9` |

### Removed artifacts

| groupId | artifactId | Replacement |
|---|---|---|
| `org.hibernate` | `hibernate-entitymanager` | merged into `hibernate-core` 6.x |
| `org.jboss.spec.javax.transaction` | `jboss-transaction-api_1.2_spec` | `jakarta.transaction-api` |
| `javax.persistence` | `javax.persistence-api` | `jakarta.persistence-api` |
| `com.sun.xml.bind` | `jaxb-impl` / `jaxb-core` | `org.glassfish.jaxb:jaxb-runtime` |
| `io.swagger` | `swagger-parser` | `swagger-parser-v3` |

### GWT exclusions added (gwt-dev)

Deprecated/CVE-affected transitive dependencies now explicitly excluded from `gwt-dev`:
`jetty-webapp`, `jetty-servlets`, `jetty-annotations`, `apache-jsp`, `net.sourceforge.htmlunit:htmlunit`.

---

## 2. Code Changes

No Java source files in this repository — it is a pure BOM/parent POM project.

---

## 3. Potential Breaking Changes

| Area | Risk |
|---|---|
| Hibernate 5 → 6 | `hibernate-entitymanager` removed; `SessionFactory` and `Criteria` API changed; `hbm.xml` mappings may need updating |
| `jakarta.persistence-api` 2.2 → 3.1 | `persistence.xml` namespace must change to `https://jakarta.ee/xml/ns/persistence`, version `3.0` |
| RESTEasy 3 → 6 | Package path `org.jboss.resteasy.plugins` unchanged but client API and multipart API changed |
| Servlet API 4 → 6 | `jakarta.servlet` only; any `javax.servlet` references in WAR deployments will fail |
| Weld 3 → 5 | CDI 4.0; `beans.xml` schema must reference `https://jakarta.ee/xml/ns/jakartaee`, version `4.0` |
| Narayana 4 → 7 | Config property names changed; JTA coordinator class names unchanged |
| Tomcat 9 → 10.1 | Servlet 6 only; `javax.*` filters/servlets will not deploy |
| JAXB: `com.sun.xml.bind` removed | Any code or POMs directly referencing `com.sun.xml.bind:jaxb-impl` must switch to `org.glassfish.jaxb:jaxb-runtime` |
| `commons-fileupload` 1.x → 2.x | API breaking change; multipart upload code must use `commons-fileupload2-jakarta-servlet6` |
| Swagger `swagger-parser` → `swagger-parser-v3` | Different artifact coordinates and API |
| GWT 2.11 → 2.13 | Dev-mode Jetty removed; integration-test setups using GWT dev mode must be updated |

