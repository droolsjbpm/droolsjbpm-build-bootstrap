Developing Drools and jBPM
==========================

**If you want to build or contribute to a kiegroup project, read this document.**

**This document will save you and us a lot of time by setting up your development environment correctly.**
It solves all known pitfalls that can disrupt your development.
It also describes all guidelines, tips and tricks.
If you want your pull requests (or patches) to be merged into main, please respect those guidelines.

If you are reading this document with a normal text editor, please take a look
at the more readable [formatted version](https://github.com/kiegroup/droolsjbpm-build-bootstrap/blob/main/README.md).

If you discover pitfalls, tips and tricks not described in this document,
please update it using the [markdown syntax](http://daringfireball.net/projects/markdown/syntax).

Table of content
----------------

* **[Source control with Git](#source-control-with-git)**

* **[Building with Maven](#building-with-maven)**

* **[CI Information](#ci-information)**

* **[Team communication](#team-communication)**

* **[Writing documentation](#writing-documentation)**

* **[FAQ](#faq)**


Quick start
===========

If you don't want to contribute to this project and you know git and maven, these build instructions should suffice:

* To build 1 repository, for example `drools`:

    ```shell
    $ git clone git@github.com:kiegroup/drools.git
    $ cd drools
    $ mvn clean install -DskipTests
    ```
* To build all repositories:

    ```shell
    $ git clone git@github.com:kiegroup/droolsjbpm-build-bootstrap.git
    $ droolsjbpm-build-bootstrap/script/git-clone-others.sh
    $ droolsjbpm-build-bootstrap/script/mvn-all.sh clean install -DskipTests
    ```

**If you want to contribute to this project, read the rest of this file!**

Source control with Git
=======================

Installing and configuring git
------------------------------

* Install git in your OS:

    * Linux: Install the package git

        ```shell
        $ sudo apt-get install git
        ```

        Tip: Also install *gitk* to visualize your git log:

        ```shell
        $ sudo apt-get install gitk
        ```

    * Windows, Mac OSX: Download from [the git website](http://git-scm.com).

        Tip for Mac OSX: Also install [*gitx*](http://gitx.frim.nl/) to visualize your git log.

    * More info in [GitHub's git installation instructions](http://help.github.com/git-installation-redirect).

* Check if git is installed correctly.

    ```shell
    $ git --version
    git version 2.21.2
    ```

* Configure git correctly:

    ```shell
    $ git config --global user.name "My Full Name"
    $ git config --global user.email myAccount@gmail.com
    $ git config --global -l
    user.name=<user name and surname >
    user.email=<user email address>
    ```

    * Warning: the field `user.name` is your full name, *not your username*.

    * Note: the field `user.email` should match an email address of your github account.

    * More info on [GitHub](http://help.github.com/git-email-settings/).

* Get a github account

    * And add your public key on github: [Follow these instructions](http://github.com/guides/providing-your-ssh-key).

* To learn more about git, read the free book [Pro Git](http://progit.org/book/).

Getting the sources locally
---------------------------

Because you'll probably want to change our code, it's recommended to fork our code before cloning it,
so it's easier to share your changes with us later.
For more info on forking, read [GitHub's help on forking](http://help.github.com/fork-a-repo/).

* First fork the repository you want to work on, for example `drools`:

    * Surf to [the blessed repositories on github](https://github.com/kiegroup) and log in.

        * Note: **Every git repository can be build alone.**
        You only need to fork/clone the repositories you're interested in (`drools` in this case).

    * Surf to [the specific repository (drools)](https://github.com/kiegroup/drools)

    * Click the top right button *Fork*

    * Note: by forking the repository, you can commit and push your changes without our consent
    and we can easily review and then merge your changes into the blessed repository.

* **Clone your fork locally:**

    ```shell
    # First make a directory to hold all the kiegroup projects
    $ mkdir kiegroup
    $ cd kiegroup

    # Then clone the repository you want to clone.
    $ git clone git@github.com:MY_GITHUB_USERNAME/drools.git
    $ cd drools
    $ ls
    ```

    * Warning: Always clone with the *SSH URL*, never clone with the *HTTPS URL* because the latter is unreliable.

    * Note: it's highly recommended to name the cloned directory the same as the repository (which is the default), so the helper scripts work.

    * By default you will be looking at the sources of the main branch, which can be very unstable.

        * Use git checkout to switch to a more stable branch or tag:

            ```shell
            $ git checkout <stable version> # i.e git checkout 7.33.x
            ```

* Add the blessed repository as upstream (if you've directly cloned the blessed repository, don't do this):

    ```shell
    $ git remote add upstream git@github.com:kiegroup/drools.git
    $ git fetch upstream
    ```

Working with git
----------------

* First make a topic branch:

    ```shell
    $ git checkout main
    $ git checkout -b myFirstTopic
    ```

    * Don't litter your local `main` branch: keep it equal to `remotes/upstream/main`

    * 1 branch can have only 1 pull request, because the pull requests evolves as you add more commits on that branch.

* Make changes, run, test and document them, then commit them:

    ```shell
    $ git commit -m "Fix typo in documentation"
    ```

* Push those commits on your topic branch to your fork

    ```shell
    $ git push origin myFirstTopic
    ```

* Get the latest changes from the blessed repository

    * Set your main equal to the blessed main:

        ```shell
        $ git fetch upstream
        $ git checkout main
        # Warning: this deletes all changes/commits on your local main branch, but you shouldn't have any!
        $ git reset --hard upstream/main
        ```

    * Start a new topic branch and set the code the same as the blessed main:

        ```shell
        $ git fetch upstream && git checkout -b mySecondTopic && git reset --hard upstream/main
        ```

    * If you have a long-running topic branch, merge main into it:

        ```shell
        $ git fetch upstream
        $ git merge upstream/main
        ```

        * If there are merge conflicts:

            ```shell
            $ git mergetool
            $ git commit
            ```

            or

            ```shell
            $ git status
            $ gedit conflicted-file.txt
            $ git add conflicted-file.txt
            $ git commit
            ```

            Many people get confused when a merge conflict occurs, because you're *in limbo*.
            Just fix the merge conflicts and commit (even if the git seems to contain many files),
            only then is the merge over. Then run `git log` to see what happened.
            The many files in the merge conflict resolving commit are a side effect of non-linear history.

* You may delete your topic branch after your pull request is closed (first one deletes remotely, second one locally):

    ```shell
    $ git push origin :myTopicBranch
    $ git branch -D myTopicBranch
    ```

* Tips and tricks

    * To see the details of your local, unpushed commits:

        ```shell
        $ git diff origin...HEAD
        ```

    * To run a git command (except clone) over all repositories (only works if you cloned all repositories):

        ```shell
        $ cd ~/projects/kiegroup
        $ droolsjbpm-build-bootstrap/script/git-all.sh push
        ```

        * Note: the `git-all.sh` script is working directory independent.

        * Linux tip: Create a symbolic link to the `git-all.sh` script and place it in your `PATH` by linking it in `~/bin`:

            ```shell
            $ ln -s ~/projects/kiegroup/droolsjbpm-build-bootstrap/script/git-all.sh ~/bin/kiegroup-git
            ```

            For command line completion, add the following line in `~/.bashrc`:

            ```shell
            $ complete -o bashdefault -o default -o nospace -F _git kiegroup-git
            ```

Share your changes with a pull request
--------------------------------------

A pull request is like a patch file, but easier to apply, more powerful and you'll be credited as the author.

* Creating a pull request

    * Push all your commits to a topic branch on your fork on github (if you haven't already).

        * You can only have 1 pull request per branch, so it's advisable to use topic branches to avoid mixing your changes.

    * Surf to that topic branch on your fork on github.

    * Click the button *Pull Request* on the top of the page.
        * Once the *Pull Request* is built the user who raised the PR gets an email (email address of user that is stored in github) with the result.
          If the user has access to the RedHat VPN he can access the links to the logs of the build and to its failed tests. In case the connection to VPN
          is not available the user gets the failed test in the message body (*UNSTABLE build*) or he gets the log file compressed as attachment (*FAILED build*).
          In case the build was *SUCCESSFUL* no mail is sent, only if the first build failed and the PR was fixed, so the second PR fixes the build. In these cases
          the user will get an email. 

* Accepting a pull request

    * Surf to the pull request page on github.

    * Review the changes

    * Click the button *Merge help* on the bottom of the page and follow the instructions of github to apply those changes on the blessed main.

        * Or use the button *Merge* if there are no merge conflicts.

If the change being proposed is affecting more than a single repository, it will require creating a pull request for each of the repositories being affected; in this case, it is required for the *topic branch* to share the same name across all pull requests, in order for the CI build tool to include the necessary dependencies while performing the build with the proposed change. It is also highly recommended to use the github *Autolinked references* in the pull request comments, in order to make these dependencies explicit and emphasized during code reviews.

Building with Maven
===================

All projects use Maven 3 to build all their modules.

Installing Maven
----------------

* Get Maven

    * [Download Maven](http://maven.apache.org/) and follow the installation instructions.

* Linux

    * Note: the `apt-get` version of maven is probably not up-to-date enough.

    * Linux trick to easily upgrade to future versions later:

        * Unzip maven to `~/opt/build`

        * Create a version-independent link:

            ```shell
            $ cd ~/opt/build/
            $ ln -s apache-maven-3.6.3 apache-maven
            ```

            Next time you only have to remove the link and recreate the link to the new version.

        * Add this to your `~/.bashrc` file:

            ```shell
            export M3_HOME="~/opt/build/apache-maven"
            export PATH="$M3_HOME/bin:$PATH"
            ```

    * Give more memory to maven:

        * Please read: [Configuring Apache Maven](http://maven.apache.org/configure.html)

* Windows:

    * Give more memory to maven, so it can build the big projects too:

        * Open menu *Configuration screen*, menu item *System*, tab *Advanced*, button *environment variables*:

            ```shell
            set MAVEN_OPTS="-Xms256m -Xmx1024m"
            ```

* Check if maven is installed correctly.

    ```shell
    $ mvn --version
    Apache Maven 3.6.3 (...)
    Java version: 1.8.0_112
    ```

    Note: the enforcer plugin enforces a minimum maven and java version.

Running the build
-----------------

* Go into a project's base directory, for example `drools`:

    ```shell
    $ cd ~/projects/kiegroup
    $ ls 
    ```
    the repositories displayed should be like listed here. [repository_list](https://github.com/kiegroup/droolsjbpm-build-bootstrap/blob/main/script/repository-list.txt)
    ```shell
    $ cd drools
    $ ls
    ...  drools-core  drools-cdi  pom.xml ...
    ```

    Notice you see a `pom.xml` file there. Those `pom.xml` files are the heart of Maven.

* **Run the build**:

    ```shell
    $ mvn clean install -DskipTests
    ```

    The first build will take a long time, because a lot of dependencies will be downloaded (and cached locally).

    It might even fail, if certain servers are offline or experience hiccups.
    In that case, you'll see an IO error, so just run the build again.

    If you consistently get `Could not transfer artifact ... Connection timed out`
    and you are behind a non-transparent proxy server,
    [configure your proxy server in Maven](http://maven.apache.org/settings.html#Proxies).

    After the first successful build, any next build should be fast and stable.

* Try running a different profile by using the option `-D<profileActivationProperty>`:

    ```shell
    $ mvn clean install -DskipTests -Dfull
    ```

    There are 3 profile activation properties:

    * *none*: Fast, for during development

    * `full`: Slow, but builds everything (including documentation). Used by Jenkins and during releases.

    * `productized`: activates branding changes for productized version

* To run a maven build over all repositories (only works if you cloned all repositories):

    ```shell
    $ cd ~/projects/kiegroup
    $ droolsjbpm-build-bootstrap/script/mvn-all.sh -DskipTests clean install
    ```

    * Note: the `mvn-all.sh` script is working directory independent.

* You can use `mvn-all.sh` to compile a specific repository and all repositories that your target repository depends on.
  This is done using the `--target-repo` option which will invoke `repo-dep-tree.pl` script to discover cross-repository
  project dependencies. Use `--repo-list` to specify custom list of repositories. These options work for `git-all.sh`
  too.

* Warning: The first `mvn` build of a day will download the latest SNAPSHOT dependencies of other kiegroup projects,
unless you build all those kiegroup projects from source.
Those SNAPSHOTS were built and deployed last night by Jenkins jobs.

    * If you've pulled all changes (or cloned a repository) today, this is a good thing:
    it saves you from having to download and build all those other latest kiegroup projects from source.

    * If you haven't pulled all changes today, this is probably a bad thing:
    you're probably not ready to deal with those new snapshots.

        In that case, add `-nsu` (= `--no-snapshot-updates`) to the `mvn` command to avoid downloading those snapshots:

        ```shell
        $ mvn clean install -DskipTests -nsu
        ```

        Note that using `-nsu` will also make the build faster.

### **Full build from sources**

If the purpose, instead, is to build the full set of projects that are dependent on each other, the recommendation is to use the [build-chain](https://github.com/kiegroup/github-action-build-chain) tool. This tool allows to build multiple projects from different repositories in one single command.

* Install **build-chain-action** npm tool (node/npm must be installed):
    
    ```shell
    $ npm i @kie/build-chain-action -g
    ```

Now in according to then need, the *build-chain-action* command line tool should be run with proper arguments. Check [build-chain](https://github.com/kiegroup/github-action-build-chain#github-action-build-chain) documentation for further details on commands and arguments. Below one of the most common use cases you might face into. 

* **Branch Flow**, this allows to build the *whole set of projects* from RHBA community stream, either following upstream or downstream flow:

    ``` shell
    $ build-chain build branch -f https://raw.githubusercontent.com/kiegroup/droolsjbpm-build-bootstrap/main/.ci/compilation-config.yaml -b main --fullProjectDependencyTree -p kiegroup/droolsjbpm-build-bootstrap [--skipExecution]
    ```

    > Consider to change `main` by the branch/tag to build

    This command clones all repositories starting from specific project (in this case *kiegroup/droolsjbpm-build-bootstrap*, see [project structure](#kiegroup-project-structure)), checkouts one by one all projects and build them in according to their specific build instructions that are defined in the definition file you provided.
    
   
    - `build branch`, build functionality with flow type as branch.
    -  - `-f <definition-file>`, url or path to the build-chain definition file (more details [here](https://github.com/kiegroup/build-chain-configuration-reader)).
    - `-b <br>`, checkout projects in according to their branch starting from `<br>` branch in `<starting-project>` project.
    - `--fullProjectDependencyTree`, checks out and execute the whole tree instead of the upstream build, if omitted the upstream flow is used.
    - `-p <starting-project>`, from which project (in the tree structure) start from.
    - `--skipExecution`, add this if you only want to clone all repositories without building them.
    
    More info on *branch flow* arguments usage in [Execution Build Action - Branch flow arguments](https://github.com/kiegroup/github-action-build-chain#execution-build-action---branch-flow-arguments)

Running tests
-------------

* All modules

    ```shell
    $ cd ~/projects/kiegroup/drools
    $ mvn test [-Dtest=ATestClassName]
    ```


* Full build with tests
    
    This can be reached using the `build-chain` tool, introduced in [Running the Build](#running-the-build) section. Omitting the `--skipExecution` flag it will check out and build the whole set of RHBA projects (also executing all tests).

    ```shell
    $ build-chain build branch -f <definition-file> -b <br> --fullProjectDependencyTree -p <starting-project>
    ```

Running code-coverage checks
----------------------------

JaCoCo plugin allows to measure code-coverage for any child of droolsjbpm-build-bootstrap. 
The check binds to the verify phase and for the plugin to run, the code-coverage profile has to be enabled.

* From the module/project folder run command:
   
    ```shell
    $ mvn clean verify -Pcode-coverage
    ```

* The coverage report is then generated in ./target/site/jacoco/index.html

Running Pitest mutation coverage analysis
-----------------------------------------

Mutation coverage is used to measure how good the tests are at making assertions about the tested code.
It is a good idea to check the mutation coverage of tests added together with any changes, be it a newly developed
feature or a bug fix. Code coverage is analyzed for free as part of the mutation analysis.

To analyze the complete module:

```shell
$ mvn verify -Dmutation-coverage
```

To limit analyzed classes to a sub-package:

```shell
$ mvn verify -Dmutation-coverage -DtargetClasses=org.drools*
```

The HTML report will be stored in `local/pit-reports/` directory.
Currently, it is not possible to get a report aggregated over multiple modules.
Learn more about using [Pitest](http://pitest.org/quickstart/maven/).

Configuring Maven
-----------------

To deploy snapshots and releases to nexus, you need to add this to the file `~/.m2/settings.xml`:

```xml
<settings>
  ...
  <servers>
    <server>
      <id>jboss-snapshots-repository</id>
      <username>jboss.org_username</username>
      <password>jboss.org_password</password>
    </server>
    <server>
      <id>jboss-releases-repository</id>
      <username>jboss.org_username</username>
      <password>jboss.org_password</password>
    </server>
    </servers>
    ...
</settings>
```

Furthermore, you'll need nexus rights to be able to do this.

More info in [the JBoss.org guide to get started with Maven](http://community.jboss.org/wiki/MavenGettingStarted-Developers).

Requirements for dependencies
-----------------------------

Any dependency used in any KIE project must fulfill these hard requirements:

* The dependency must have **an Apache 2.0 compatible license**.

    * Good: BSD, MIT, Apache 2.0

    * Avoid: EPL, LGPL

        * Especially LGPL is a last resort and should be abstracted away or contained behind an SPI.

        * Test scope dependencies pose no problem if they are EPL or LPGL.

    * Forbidden: no license, GPL, AGPL, proprietary license, field of use restrictions ("this software shall be used for good, not evil"), ...

        * Even test scope dependencies cannot use these licenses.
        
    * To check the ALS compatibility license please visit these links:[Similarity in terms to the Apache License 2.0](http://www.apache.org/legal/resolved.html#category-a)&nbsp; 
    [How should so-called "Weak Copyleft" Licenses be handled](http://www.apache.org/legal/resolved.html#category-b)

* The dependency shall be **available in [Maven Central](http://search.maven.org/) or [JBoss Nexus](https://repository.jboss.org/nexus)**.

    * Any version used must be in the repository Maven Central and/or JBoss (Nexus) Public repository group

        * Never add a `<repository>` element in a `pom.xml`.

        * Note: JBoss Public repository group mirrors java.net, codehaus.org, ... Most jars are available there.

    * Why?

        * Build reproducibility. Any repository server we use, must still run 7 years from now.

        * Build speed. More repositories slow down the build.

        * Build reliability. A repository server that is temporarily down can break builds.

    * Workaround to still use a great looking jar as a dependency:

        * Get that dependency into JBoss Nexus as a 3rd party library.

* The dependency must be able to run on any **JVM 1.8 and higher**.

    * It must be compiled for Java target 1.8 or lower (even if it's compiled with JDK 7 or JDK 8).

    * It must not use any JDK APIs that were not yet available in Java 1.8.

* **Do not release the dependency yourself** (by building it from source).

    * Why? Because it's not an official release, by the official release guys.

        * A release must be 100% reproducible.

        * A release must be reliable (sometimes the release person does specific things you might not reproduce).

* **No security issues** (CVE's) reported on that version of the dependency

    * We don't expect you to check this manually:
    The victims enforcer plugin will automatically fail the build if a known bad dependency is used.

* **The sources are publicly available**

    * We may need to rebuild the dependency from sources ourselves in future. This may be in the rare case when
      the dependency is no longer maintained, but we need to fix a specific CVE there. The other reason is that
      productisation needs to be able to easily rebuild the dependency internally.

    * Make sure the dependency's pom.xml contains link to the source repository (`scm` tag).

* The dependency needs to use **reasonable build system**

    * Since we may need to rebuild the dependency from sources, we also need to make sure it is easily buildable.
      Maven or Gradle are acceptable as build systems.

Any dependency used in any KIE project should fulfill these soft requirements:

* **Edit dependencies** in **[kie-parent](https://github.com/kiegroup/droolsjbpm-build-bootstrap/blob/main/pom.xml)**.

    * Dependencies in subprojects should avoid overwriting the dependency versions of kie-parent
        

* **Prefer dependencies with the groupId `org.jboss.spec`** over those with the groupId `javax.*`.

    * Dependencies with the groupId `javax.*` are unreliable and are missing metadata. No one owns/maintains them consistently.

    * Dependencies with the groupId `org.jboss.spec` are checked and fixed by JBoss.

* Only use dependencies with **an active community**.

    * Check for activity in the last year through [Open Hub](https://www.openhub.net).

* Less is more: **less dependencies is better**. Bloat is bad.

    * Try to use existing dependencies if the functionality is available in those dependencies

        * For example: use `poi` instead of `jexcelapi` if `poi` is already a KIE dependency

* **Do not use fat jars, nor shading jars.**

    * A fat jar is a jar that includes another jar's content. For example: `weld-se.jar` which includes `org/slf4j/Logger.class`

    * A shaded jar is a fat jar that shades that other jar's content. For example: `weld-se.jar` which includes `org/weld/org/slf4j/Logger.class`

    * Both are bad because they cause dependency tree trouble. Use the non-fat jar instead, for example: `weld-se-core.jar`

There are currently a few dependencies which violate some of these rules.
If you want to add a dependency that violates any of the rules above, get approval from the project leads.

Regenerating Protobuf Files
---------------------------

Some modules include Protobuf files (like drools-core and jbpm-flow). Every time a .proto file is changed, the java files have to be regenerated. In order to do that, on the module that contains the files to be regenerated, execute the following command:

```shell
$ mvn exec:exec -Dproto
```

After testing the regenerated files, don't forget to commit them.

**IMPORTANT:** before trying to regenerate the protobuf java files, you must install the protobuf compiler (protoc) in your machine. Please follow the instructions. You can download it from here: [https://developers.google.com/protocol-buffers/docs/downloads](https://developers.google.com/protocol-buffers/docs/downloads).

For Linux/Mac, you have to compile it yourself as there are no binaries available. Follow the instructions in the README file for that.


kiegroup project structure
==================
![Project hierarchy](/docs/project-dependencies-hierarchy.png)


CI Information
==================

See [CI Information document](.ci)

Team communication
==================

To develop a great project as a team, we need to communicate efficiently as a team.

Team workflows
--------------

* Fixing a community issue in JIRA:

    * Find/create the issue in JIRA ([Drools](https://issues.redhat.com/projects/DROOLS/issues/),
    [OptaPlanner](https://issues.redhat.com/projects/PLANNER/issues), [jBPM](https://issues.redhat.com/projects/JBPM/issues))

    * Fix the issue and push those changes to the appropriate branch(es) on github.

        * If you don't have push permissions, create a pull request (PR). See [Using pull requests](https://help.github.com/articles/using-pull-requests/) for more info.

    * Change the *Status* to `Resolved`.
        * When you file a PR, do not mark the issue as `Resolved` until the PR gets merged. Link the PR to the JIRA issue and wait till someone reviews the changes.

        * Once the reporter verifies the fix, he changes *Status* to `Closed`. Or we bulk change it to `Closed` after a year.


Knowing what's going on
-----------------------

* **Subscribe to the [Drools Development](https://groups.google.com/forum/#!forum/drools-development) Google Group and check it daily.**

    * Start a new topic for every important organizational or structural decision.

    * If you (accidentally) push a change that can severely hinder or disrupt other developers (such as a compilation failure), notify the Development group.

* Subscribe to the RSS feeds.

    * **It's recommended to subscribe at least to the RSS feeds of the project/repositories you're working on.**

    * Prefer an RSS reader which shows which RSS articles you've already read, such as:

        * Thunderbird

            * Open menu *File*, menu item *Subscribe*.

            * Tip: create a new, separate directory for each feed: some feeds (such as about the project you are working on) are more important to you than others.

    * Subscribe to jira issue changes:

        * [DROOLS](https://issues.jboss.org/plugins/servlet/streams?key=DROOLS&os_authType=basic)

        * [PLANNER](https://issues.jboss.org/plugins/servlet/streams?key=PLANNER&os_authType=basic)

        * [JBPM](https://issues.jboss.org/plugins/servlet/streams?key=JBPM&os_authType=basic)

    * Subscribe to github repository commits:

        * [droolsjbpm-build-bootstrap](https://github.com/kiegroup/droolsjbpm-build-bootstrap/commits/main.atom)

            * Example how to build a right URL: `https://github.com/kiegroup/<repository>/commits/main.atom`

            * where you will find `<repository>` used in kiegroup here: [repositories](https://github.com/kiegroup/droolsjbpm-build-bootstrap/blob/main/script/repository-list.txt)

* Join us on Zulip: [Chat](https://kie.zulipchat.com/)

Writing documentation
=====================

* Optionally install a DocBook editor to write documentation more comfortably, such as:

    * [oXygen](http://www.oxygenxml.com/)

        * Open menu *Options*, menu item *Preferences...*.

        * Click tree item *Global*

            * Combobox *Line separator*: `Unix-like`

        * Click tree item *Format*

            * Checkbox *Detect indent on open*: `off`

            * Checkbox *Indent with tabs*: `off`

            * Combobox *Indent size*: `2`

            * Textfield *Line width - Format and Indent*: `120`

    * [XMLmind](http://www.xmlmind.com/xmleditor/)

        * Open menu *Options*, menu item *Preferences...*.

        * Click tree item *Save*

            * Combobox *Encoding*: `UTF-8`

            * Textfield *Identation*: `2`

            * Textfield *Max. line length*: `120`

            * Checkbox *Before saving, make a backup copy of the file*: `off`

                * To avoid committing backups to source control.

                * Source control history is better than backups.

* To generate the html and pdf output run maven with `-Dfull`:

    ```shell
    $ cd kiegroup
    $ cd optaplanner/optaplanner-docs
    $ mvn clean install -Dfull
    ...
    $ firefox target/docbook/publish/en-US/html_single/index.html
    ```

* **[Read and follow the documentation guidelines](documentation-guidelines.txt).**

* The Drools Expert manual uses railroad diagrams.

    These are generated from a BNF file into images files with the application
    [Ebnf2ps, Automatic Railroad Diagram Drawing](http://www.informatik.uni-freiburg.de/~thiemann/haskell/ebnf2ps/)

FAQ
===

* Why do you not accept `@author` lines in your source code?

    * Because the author tags in the java files are a maintenance nightmare

        * A large percentage is wrong, incomplete or inaccurate.

        * Most of the time, it only contains the original author. Many files are completely refactored/expanded by other authors.

        * Git is accurate, that is the canonical source to find the correct author.

    * Because the author tags promote *code ownership*, which is bad in the long run.

        * If people work on a piece they perceive as being owned by someone else, they tend to:

            * only fix what they are assigned to fix, instead of everything that's broken

            * discard responsibility if that code doesn't work properly

            * be scared of stepping on the feet of the owner.

        * For more motivation, see [this video on How to get a healthy open source project?](http://video.google.com/videoplay?docid=-4216011961522818645#)

    * Credit to the authors is given:

        * on [the team page](http://www.jboss.org/drools/team)

             * Please contact Geoffrey (or any of us) if you want to add/change/expand your entry in the team page. Don't be shy!

        * on [the blog](http://blog.athico.com)

            * Write an article about the improvements you did! Contact us if you don't have write authorization on the blog yet.

        * with [Open Hub](https://www.openhub.net/p/jboss-drools/contributors) which also has statistics

        * in [the GitHub web interface](https://github.com/kiegroup).
