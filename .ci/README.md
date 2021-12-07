# CI documentation

This document tries to clarify the CI status and configuration for the RHBA set of projects. [See projects dependency tree](https://github.com/kiegroup/droolsjbpm-build-bootstrap#kiegroup-project-structure).

Table of content
----------------

* **[We use cross-repo pull requests as CI strategy](#we-use-cross-repo-pull-requests-as-ci-strategy)**

* **[Where are the jobs defined?](#where-are-the-jobs-defined)**

* **[Where can I find the commands which are going to be executed?](#where-can-i-find-the-commands-which-are-going-to-be-executed)**

* **[How are the project dependencies defined?](#how-are-the-project-dependencies-defined)**

* **[Productization Nightly Job](#productization-nightly-job)**

## We use cross-repo pull requests as CI strategy

How can we assure one specific pull request will work with the latest changes from/in the dependant/dependency projects and it won't break something? This is what we call cross-repository pull requests and [build-chain](https://github.com/kiegroup/github-action-build-chain) is the way we have to solve it.

Imagine a CI with more than 20 projects, different branch involves there, different product versions 7.x, 8.x ... and all of them have to be maintained for different build systems or automation services...  What does happen whenever a developer opens a set of pull requests and we have to assure they are not breaking anything from the rest of the related projects? It would be very hard to make it works and to maintain it, right? Well it is, but we have mitigated the complexity by using build-chain tool in order to delegate how to deal with it and we just care about how the projects are related between them ([project-dependencies.yaml](project-dependencies.yaml) file) and what to execute per project ([project-definition.yaml](pull-request-config.yaml) file). More information at [Cross-repo Pull Requests? build-chain tool to the rescue!](https://blog.kie.org/2021/07/cross-repo-pull-requests-build-chain-tool-to-the-rescue.html)


## Where are the jobs defined?

The CI jobs either for Jenkins and GitHub Action. Every project defines the type of jobs and where they want to be executed but the configuration for the project relationships, build commands and pipeline is centralized in one single place no matter whether the jobs are running on Jenkins, GitHub runners or any other machine, we always assure the commands and the project checkout information are always the same.

### Jenkins jobs

The Jenkins CI jobs are automatically created by a [Groovy script](https://github.com/kiegroup/kie-jenkins-scripts/blob/main/job-dsls/jobs/kie/main/pr_jobs.groovy) every time the Jenkins instance machine is refreshed/restarted.

The jobs are basically [pipeline jobs type](https://www.jenkins.io/doc/book/pipeline/) and the pipeline itself is externalized in a [Jenkinsfile](jenkins/Jenkinsfile.buildchain), this way it is split and distinguished between what the Jenkins job should be (it changes very rarely) and the pipeline itself (it changes from time to time depending on the build requirements).

### GitHub Actions jobs

The GitHub Action workflows are stored in `.github/workflows` folder as it is required by GitHub Actions to be executed for each repository. The difference with Jenkins job DSL definition is the pipeline and the job definitions are both mixed in the same yaml file.

kiegroup GitHub Actions use [composite actions](https://docs.github.com/en/actions/creating-actions/creating-a-composite-action) to point to the most common steps centralized in single repository (droolsjbpm-build-bootstrap), this way reduces maintaining in multiple repositories or adapting, updating versions and similar changes for all the repositories and branches involved in the kiegroup organization CI processes.

See [our composite actions definitions](actions).

Thanks to this composite actions strategy most of the GitHub Action jobs are basically the same and build-chain tool is in charge of making "the magic" in background:

* [droolsjbpm-build-boostrap](../.github/workflows/pull_request.yml)
* [appformer](https://github.com/kiegroup/appformer/blob/main/.github/workflows/pull_request.yml)
* [jbpm](https://github.com/kiegroup/jbpm/blob/main/.github/workflows/pull_request.yml)


## Where can I find the commands which are going to be executed?

All the build commands are listed in the [project-definition file](pull-request-config.yaml). [More information about project definition files](https://github.com/kiegroup/build-chain-configuration-reader). Just to summarize it, you will see something like:

```yaml
  build-command:
    current: whatever command for current.
    upstream: whatever command for upstream.
    downstream: whatever command for downstream.
```

* `current` means the command/s to be executed by the project triggering the job (or starting-project).
* `upstream` means the command/s to be executed by the dependant projects of the project triggering the job (or starting-project).
* `downstream` means the command/s to be executed by the projects that depend on the project triggering the job (or starting-project).

You can find them on the default section (whether this section exists) or in the specific project section (whether this section exists, otherwise the information will be taken from the default section).

More information about this at [github-action-build-chain#usage-example](https://github.com/kiegroup/github-action-build-chain#usage-example).

> **_Note:_** You can always check the "Execution Summary" from any Jenkins or GitHub Actions job.

## How are the project dependencies defined?

As mentioned above, the project dependencies is delegated to build-chain tool and the project dependency information is externalized in one single yaml file. See [project-dependencies.yaml file](https://github.com/kiegroup/droolsjbpm-build-bootstrap/blob/main/.ci/project-dependencies.yaml).

There you will find a list of projects (all the projects involved on the different kiegroup GitHub organization projects) and the dependencies between them. For instance

```yaml
  - project: kiegroup/lienzo-core

  - project: kiegroup/lienzo-tests
    dependencies:
      - project: kiegroup/lienzo-core
```

defines `kiegroup/lienzo-tests` repository project as part of the workflow set and depends on `kiegroup/lienzo-core` repository project (with no additional dependencies) which is also defined on top of the definition.

> **_Note:_** So in case `lienzo-tests` pull request is opened the new PR job checks out `lienzo-core` and `lienzo-tests` PR CI job will be launched, where it is built `lienzo-core` repository project first and then `lienzo-tests` repository project.

This way you can easily understand the rest of document.

### What about this mapping thing?

You will be able to see more complex definitions for projects like `drools` or `optaplanner`. For instance:

```yaml
 - project: kiegroup/drools
    dependencies:
      - project: kiegroup/kie-soup
      - project: kiegroup/droolsjbpm-knowledge        
    mapping:
      dependencies:
        default:
          - source: 7.x
            target: main
      dependant:
        default:
          - source: main
            target: 7.x
      exclude:
        - kiegroup/optaweb-employee-rostering
        - kiegroup/optaweb-vehicle-routing
        - kiegroup/optaplanner          
        - kiegroup/droolsjbpm-knowledge  
```

`mapping` is about "branch mapping" and it requires to take different branches per repository project depending on the repository project triggering the job (the repository project PR that launches the CI build) and the target branch for a particular PR. In this case we want to get `drools:7.x` for every pull request targeting `main` branch, except for `kiegroup/opta*` and `kiegroup/droolsjbpm-knowledge`.
The opposite is also wanted, to get `drools:main` branch for every pull request targeting `7.x` branch, the rest of branches if not declared is a basic flat branch mapping from branch A to branch A.

## Productization nightly job

The product nightly jobs are totally different to the pull request jobs.

The product job definition defines a [multibranch pipeline](https://www.jenkins.io/doc/book/pipeline/multibranch/#creating-a-multibranch-pipeline) job in [Jenkinsfile.nightly file](jenkins/Jenkinsfile.nightly). The high level process flow is:

1. Reads project collection.
2. Reads Build Configuration.
3. Executes POM Manipulation Extension (PME).
4. Executes Maven (the build itself).
5. Uploads artifacts to the internal nexus repository.
6. Uploads properties to remote storage place for archive purpose.
7. Sends UMB Message to QE.


> **_Note:_** Part of the job (steps 3 and 4) is delegated to the [pmebuild.groovy](https://github.com/kiegroup/jenkins-pipeline-shared-libraries/blob/main/vars/pmebuild.groovy) script.


### Reads project collection

The execution is defined by the Jenkinsfile file, which is centralized in droolsjbpm-build-bootstrap repo. The pipeline reads the project list from [repository-list.txt](../script/repository-list.txt) text file and merges it with the non-community one from rhba-project-list-production jenkins file (stored as a Jenkins secret). 
The stages are loaded from nightly.stages script file where we call pmebuild.buildProjects.

> **_Note:_** The repository-list.txt is automatically generated by [generate files job](../.github/workflows/generate_files.yml) reading [project-dependencies.yaml](project-dependencies.yaml) information. This way it is  decreased possible discrepancies between community and product nightly job.


### Reads Build Configuration

The file build-configurations repository URL is taken from BUILD_CONFIGURATION_REPO_URL Jenkins environment variable, the repository is cloned and the __build-config.yaml__ file path is sent as an argument to the pmebuild.buildProjects groovy script from the __nightly.stages__ file.

The content is read and the #! are treated replacing the {{variable}} by the one from #!variable. The yaml is parsed to a String, Object map.

### Executes POM Manipulation Extension (PME) 

This step is executed once per project getting the [PME](https://release-engineering.github.io/pom-manipulation-ext/) configuration from the build configuration file. The jar path is taken from PME_CLI_PATH.

### Executes Maven (the build itself)

This step is executed once per project getting the maven command from the build configuration file where the maven settings from `managed-files_nightly` is taken.

The artifacts are deployed locally thanks to the flag `-DaltDeploymentRepository=local::default::file://${env.WORKSPACE}/deployDirectory`.

### Uploads artifacts to the internal nexus repository

The `${env.WORKSPACE}/deployDirectory` folder is zipped and uploaded to `KIE_GROUP_DEPLOYMENT_REPO_URL` using a curl command.


### Uploads properties to rcm-guest service

The job `rhpam-properties-generator` is called. Every variable used in the product nightly process (from the build-config.yaml file and from the product nightly itself) are stored as an environment variable, this is how we can send the variables needed by the job.
The Jenkins `rhpam-properties-generator` job was created to support this product nightly build job but the job can be triggered by other processes or even by hand, so it has more logic than the one needed by the product nightly itself but it’s reusable by any other processes.


### Sends UMB Message to QE

The job `send-umb-message` is called. These are steps involved:

* To take the map from `env.PME_BUILD_VARIABLES`.
* To get the versionIdentifier from `PME_BUILD_VARIABLES['productVersion']`.
* To compose the message topic and eventType adding the versionIdentifier.
* To call the job defined by `env.SEND_UMB_MESSAGE_PATH` sending the required parameters.
