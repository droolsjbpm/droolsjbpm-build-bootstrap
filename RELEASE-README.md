Table of content
================
* **[Releasing a community release](#releasing)**

* **[Building a Product Tag](#building-a-product-tag)**

Releasing
=========

Expecting a release
-------------------

A week in advance:

* Announce on the upcoming release on all the developer mailing lists bsig@redhat.com .

    * Include a list of projects on Jenkins that are yellow or red.

        * Daily remind the lead of any project that is red.

    * For a CR/Final, also mention the FindBugs reports on Jenkins.

* All external dependencies must be on a non-SNAPSHOT version, to avoid failing to *close* the staging repo on nexus near the end of the release.

* Ask kiegroup modules (appformer, kie-wb-common, drools-wb, jbpm-wb, jbpm-designer and kie-wb-distributions) leads to update the i18n translations:

    * Translations are at the time beeing a manual process since Zanata shut down

* Since Zanata translations was outsourced it have to be clarified before a release if the i18n translations have to be updated..
  
* Get access to `filemgmt.jboss.org`

    * Create an SSH key (if not already done)

        * Key must:

            * be RSA-2 (default for many keygen apps)
            * have 1024+ bit (2048 is preferred)
            * have comment with user email address

        * Using many keygen tools the following command will work

                $ ssh-keygen -C your@email.com -b 2048

            * enter key name
            * enter passcode you want

        * Send ticket to IT

            * Have it forwarded to https://engineering.redhat.com/rt/Ticket/Create.html?Queue=58 (RT3 eng-ops-mw) queue
            * Specify that you would like access to drools@filemgmt.jboss.org
            * Attach the *.pub that you created above

48 hours in advance:

* Push deadline: Announce on the upcoming push deadline on all the developer mailing lists kie-jenkins-builds@redhat.com.

    * Commits pushed before the deadline will make the release, the rest won't.


Creating a release branch or new branch
---------------------

A new release branch name should always end start withy `r` so it looks different from a tag name and a topic branch name.

* When do we create a new branch?

    * We only create a new branch just before releasing CR1.

        * For example, just before releasing 7.7.0.CR1, we created the release branch 7.33.x

            * The new branch 7.33.x contained the releases 7.7.0.CR1, CR+ and 7.33.1-SNAPSHOT, ...

    * Alpha/Beta releases are released directly from main, because we don't backport commits to Alpha/Beta's.

* Alert the bsig mail list that you're going to branch main.

* Pull the latest changes.

    ```shell
    $ ./droolsjbpm-build-bootstrap/script/git-all.sh fetch origin
    $ ./droolsjbpm-build-bootstrap/script/git-all.sh rebase origin/main main
    ```

* Create a release branch (based on main branch):

    ```shell
    $ ./droolsjbpm-build-bootstrap/git-all.sh checkout -b $releaseBranch main (i.e. rX.Y.Z = r7.x.x.Final)
    ```


If required and a new branch has to be created based on main (i.e. 7.33.x for 7.7. product) following step has to be executed:

* Create new branch from main

      ```shell
      $ ./droolsjpbm-build-bootstrap/git-all.sh checkout -b $newBranch main (i.e. newBranch = 7.33.x)
      ```

* Important:

  In case we are creating a new branch (i.e. 7.33.x) and a release branch (i.e. r7.33.0.Final) we will have three branches
  
  main
  
  newBranch (i.e. 7.33.x)
  
  releaseBranch (i.e. r7.33.0.Final)
  
  All these branches need to have their own version to avoid clashing the artifacts on Nexus of main and all other branches. The versions of each branch have to be upgraded.
  Except the release branch the other two branches have to be upgraded to their new SNAPSHOT version.  
   
* Switch to the new branches ($newBranch or $releaseBranch) for all git repositories

    * If you haven't made the branches yourself, first make sure your local repository knows about them:

        ```shell
        $ ./droolsjbpm-build-bootstrap/script/git-all.sh fetch origin
        ```
    
    * Swith to the new branch or release branch

        ```shell
        $ ./droolsjbpm-build-bootstrap/script/git-checkout-all.sh $main or $newBranch or $releaseBranch (i.e. main or 7.33.x or r7.33.0.Final)
        ```

    * Update versions:

        main branch
        ```shell
        $ ./droolsjbpm-build-bootstrap/script/release/update-version-all.sh $nextSNAPSHOT_main community (i.e. nextSNAPSHOT = 7.34.0-SNAPSHOT)
        ```
        
        $releaseBranch
        ```shell
        $ ./droolsjbpm-build-bootstrap/script/release/update-version-all.sh $kieVersion_releaseBranch community (i.e. kieVersion = 7.33.0.Final)  
        ```

        $newBranch
        ```shell
        $ ./droolsjbpm-build-bootstrap/script/release/update-version-all.sh $nextSNAPSHOT_newBranch community (i.e. nextSNAPSHOT_newBranch = 7.33.1-SNAPSHOT )  
        ```

        * Note: the arguments are `new version` `community`

        * WARNING: script update-version-all.sh did not update all versions in all modules for the desired version. Check all have been updated with the following and re-run if required.

            ```shell
            $ grep -r '$newVersion' **/pom.xml
            # or
            $ for i in $(find . -name "pom.xml"); do grep '$newVersion' $i; done
            ```

        * Note: 
        $newVersion could be here or the release version or the upcoming -SNAPSHOT versions (main or new branch)
        
        in either case it is important to search for `-SNAPSHOT`, as there are various hidden `-SNAPSHOT` dependencies in some pom.xml files and they should be prevented for releases
        
        * Commit those changes (so you can tag them properly):

            * Add changes from untracked files if there are any. WARNING: DO NOT USE `git add .`. You may accidentally add files that are not meant to be added into git.

                ```shell
                $ git add {filename}
                ```

            * Commit all changes

                ```shell
                $ ./droolsjbpm-build-bootstrap/script/git-all.sh commit -m "Set version to: $newVersion"
                ```

    * Push the new `-SNAPSHOT` version to `main` of the blessed directory

        ```shell
        $ ./droolsjbpbm-build-bootstrap/script/git-all.sh pull --rebase origin main (pulls all changes for main that could be commited in the meantime and prevents merge problems when pushing commits)
        $ ./droolsjbpm-build-bootstrap/script/git-all.sh push origin main (pushes all commits to main)
        ```

    * Switch back to the *new* or *release* branch name with `droolsjbpm-build-bootstrap/script/git-checkout-all.sh $newBranch or $releaseBranch` :

        ```shell
        $ ./droolsjbpbm-build-bootstrap/script/git-all.sh checkout $newBranch or $releaseBranch  
        $ ./droolsjbpm-build-bootstrap/script/git-all.sh push origin $newBranch or $releaseBranch
        ```
        
    *Important:
    
    At this point in time we should have three upgraded branches on git hub. The new branch (i.e. 7.33.x), the release branch (i.e. r7.33.0.Final) and the upgraded main branch.
    Depending on the need of a new branch (main branch has often to be upgraded but not branched) we will have one or two new branches on git hub. The new branch and the release branch.
    To save storage the release branch of the previous release (i.e. r7.32.0.Final) will be removed, so that on git hub there is only one release branch. These release branches are only and exclusive fro the community 
    releases and no dev should commit to them.
    
* Build release (mvn clean deploy to a local directory)

    If we checkout to the $releaseBranch we can do a mvn clean deploy executing all test
    
      ```shell
      $ ./droolsjbpbm-build-bootstrap/script/git-all.sh checkout $releaseBranch
      A local directory deployDir where the binaries are deplyed to should be created (i.e. deployDir=<WORKING_DIR>/community-deploy-dir)
      The SETTINGS_XML_FILE should point to a existing settings.xml file with configuration the all dependencies can be downloaded
      $ ./droolsjbpbm-build-bootstrap/script/mvn-all.sh -B -e -U clean deploy -s $SETTINGS_XML_FILE -Dkie.maven.settings.custom=$SETTINGS_XML_FILE -Dfull -Drelease -DaltDeploymentRepository=local::default::file://$deployDir -Dmaven.test.failure.ignore=true -Dgwt.memory.settings="-Xmx10g"     
      ```

NOTE: the steps until here are explaining the manual way to create a release.
At least the release branches of every repository in [repository-list.txt](https://github.com/kiegroup/droolsjbpm-build-bootstrap/blob/main/script/repository-list.txt)      
were build and a "raw" release is available. All binaries are in the $deployDir.
To finish a release there are still a few steps to be done (that are done automatically when executing the community-release-pipeline)

  * Sanity checks
  
      * Warning: It is not uncommon to run out of either PermGen space or Heap Space. The following settings are known (@Sept-2012) to work:-
  
            ```shell
            $ export MAVEN_OPTS='-Xms1g -Xmx4g -XX:+CMSClassUnloadingEnabled'
            ```
  
      * Warning: Verify that workspace contains no uncommitted changes or rogue module directories of older branches:
  
            ```shell
            $ ./droolsjbpm-build-bootstrap/script/git-all.sh status
            ```
  
      * Do a sanity check of the artifacts by running each runExamples.sh from the zips.
  
          * Go to `kie-wb-distributions/droolsjbpm-uber-distribution/target/*/download_jboss_org`:
  
              * Unzip the zips to a temporary directory.
  
              * Start the `runExamples.sh` script for drools, droolsjbpm-integration and optaplanner
  
              * Deploy the guvnor WildFly 14 war and surf to it:
  
                  * Install the mortgages examples, build it and run the test scenario's
  
              * Verify that the reference manuals open in a browser (HTML) and Adobe Reader (PDF).

  As a consequence of the result of sanity checks it will be decided if the build was stable enough for a release or not.
  This [document](https://docs.google.com/document/d/1FTCimpPp5KK-cfk0b6mgjKhDP68OKbXOBkC7D0Ya6C8/edit) describes how to release using the Jenkins job community-release-pipeline 
        
* Set up Jenkins build jobs for the new branch.

    * Add a new branch to kiegroup/kie-jenkins-jobs

    * Edit the [jobs](https://github.com/kiegroup/kie-jenkins-scripts/tree/main/job-dsls) and do the needed adaptations for the new branch

    * Note:since all these Jenkins Jobs are done with a DSL Plugin there are two things that should be done so all jobs are available:
   
        - the Jenkins Jobs
        
          https://github.com/kiegroup/kie-jenkins-scripts/tree/main/job-dsls/jobs/seed-job.groovy
        
          should be updated to the new branch, because maybe bit all DSL scriptsare requiered. The file https://github.com/kiegroup/kie-jenkins-scripts/blob/main/job-dsls/src/main/groovy/org/kie/jenkins/jobdsl/Constants.groovy
          
          should be updated to0.
      
#### NOTE:
* at this point we have created a release branch
* we have updated the main branch to the new development version (`*-SNAPSHOT`)
* we have pushed the created release branches to origin
* we have set up a new Jenkins view for the created "release branch"


Releasing from a release branch
-------------------------------

* Alert the IRC dev channels that you're starting the release.

* Pull the latest changes of the branch that will be the base for the release (branchName == main or i.e. 7.33.x)

    ```shell
    $ ./droolsjbpm-build-bootstrap/script/git-all.sh checkout <branchName>
    $ ./droolsjbpm-build-bootstrap/script/git-all.sh pull --rebase
    ```

* Create a local release branch

    Name should begin with r, i.e if the release will be 7.33.0.Final the name should be r7.33.0.Final (localReleaseBranchName == r7.33.0.Final)

    ```shell
    $ git-all.sh checkout -b r<localReleaseBranchName> <branchname>    
    ```

* Create a new version:

    * First define the version.

        * There are only 4 acceptable patterns:

            * `major.minor.micro.Alpha[n]`, for example `1.2.3.Alpha1`

            * `major.minor.micro.Beta[n]`, for example `1.2.3.Beta1`

            * `major.minor.micro.CR[n]`, for example `1.2.3.CR1`

            * `major.minor.micro.Final`, for example `1.2.3.Final`

        * See the [JBoss version conventions](http://community.jboss.org/wiki/JBossProjectVersioning)

            * Not following those, for example `1.2.3` or `1.2.3.M1` results in OSGi eclipse updatesite corruption.

        * **The version has 3 numbers and qualifier. The qualifier is case-sensitive and starts with a capital.**

            * Use the exact same version everywhere (especially in URL's).

    * Adjust the version in the poms, manifests and other eclipse stuff.

            '''shell
            $ ./droolsjbpm-build-bootstrap/script/release/update-version-all.sh $newVersion community
            '''
            
        * Note: the arguments are `newVersion` i.e. 7.x.x.Final

        * WARNING: FIXME the update-version-all script does not work correctly if you are releasing a hotfix version.

    * Commit those changes (so you can tag them properly):

        * Add changes from untracked files if there are any. WARNING: DO NOT USE `git add .` . You may accidentally add files that are not meant to be added into git.

            ```shell
            $ git add {filename}
            ```

        * Commit all changes

            ```shell
            $ ./droolsjbpm-build-bootstrap/script/git-all.sh commit -m "Set release version: 7.x.x.Final"
            ```

        * Adjust the property *`<latestReleasedVersionFromThisBranch>`* in *droolsjbpm-build-bootstrap/pom.xml*

         This should be the version that will be released now.
         This is important as productisation takes this version to define theirs.

         * Add this change
         * Commit this change.


        
* Push release branches to github repository

    The release branches rX.X.X.Y should be pushed to the github repository (community=kiegroup/... or product=jboss-integration/...), so the branch
    is available for all future steps. People can access it to review, if all commits that should be in the release were commited.<br>
    This branch has to be removed when doing the next release as a new branch starting with "r" will be pushed and we want prevent having a bunch of "obsolete" release branches.
   
    ```shell
    $ ./droolsjbpm-build-bootstrap/script/release/git-all.sh push origin <$newVersion> (i.e. 7.x.x.Final)
    ```

* Go to [nexus](https://repository.jboss.org/nexus), menu item *Staging repositories*, drop all your old staging repositories.


* Deploy the artifacts:

    ```shell
    $ ./droolsjbpm-build-bootstrap/script/release/05a_communityDeployLocally.sh <$newVersion> (i.e. 7.x.x.Final)
    ```
    * Executing this script a new directory will be created locally where all artifacts will be dployed.
    
    ```shell
    $ ./droolsjbpm-build-bootstrap/script/release/06_uploadBinariesToNexus.sh 
    ```
    * The binaries in the local created directory will be uploaded to Nexus

    * This will take a long while (8+ hours)

    * If it fails for any reason, go to nexus and drop your stating repositories again and start over.

* Go to [nexus](https://repository.jboss.org/nexus), menu item *Staging repositories*, find your staging repository.

    * Look at the files in the repository.

        * Sometimes they are split into 2 staging repositories (with no intersecting files): just threat those 2 as 1 staging repository.

    * Button *close*

        * This will validate the nexus rules. If any fail: fix the issues, and force a git retag locally.
        
* Do sanity checks

    * If the artifacts are uploaded to Nexus you will find the closed staging-respository (kie-<newVersion>) on [nexus](https://repository.jboss.org/nexus)         

    * This [document](https://docs.google.com/spreadsheets/d/1jPtRilvcOji__qN0QmVoXw6KSi4Nkq8Nz_coKIVfX6A/edit#gid=167259416) describes how (waht) to do for sanity checks

* This is **the point of no return**.

    * Warning: The slightest change after this requires the use of the next version number!

        * **NEVER TAG OR DEPLOY A VERSION THAT ALREADY EXISTS AS A PUSHED TAG OR A DEPLOY!!!**

            * Except deploying `SNAPSHOT` versions.

            * Git tags are cached on developer machines forever and are never refreshed.

            * Maven non-snapshot versions are cached on developer machines and proxies forever and are never refreshed.

        * So even if the release is broken, do not reuse the same version number! Create a hotfix version.


* Define the next development version an adjust the sources accordingly:

    * Checkout to the main-branch or the branch which is the base for this release.

        ```shell
        $  ./droolsjbpm-build-bootstrap/script/git-all.sh checkout main
        ```

    * Define the next development version on the main branch.

        * There are only 1 acceptable pattern:

            * `major.minor.micro-SNAPSHOT`, for example `1.2.0-SNAPSHOT` or `1.2.1-SNAPSHOT`

    * Adjust the version in the poms, manifests and other eclipse stuff:

        ```shell
        $ ./droolsjbpm-build-bootstrap/script/release/update-version-all.sh 7.x.x-SNAPSHOT community
        ```

        * Commit those changes:

            ```shell
            $ ./droolsjbpm-build-bootstrap/script/git-all.sh add .

            $ ./droolsjbpm-build-bootstrap/script/git-all.sh commit -m "Set next development version: 7.x.x-SNAPSHOT"
            ```

        * Push all changes to the blessed repository:

            ```shell
            $ ./droolsjbpm-build-bootstrap/script/git-all.sh push origin main
            ```
    
* Release your staging repository on [nexus](https://repository.jboss.org/nexus) and push the tags to GitHub

    * Nexus: Button *Release*
    
    * locally: Checkout back to your local release branch.

        ```shell
        $ ./droolsjbpm-build-bootstrap/script/git-all.sh checkout r7.x.x.Final
        ```

        * Create the tag locally:

            ```shell
            $ ./droolsjbpm-build-bootstrap/script/release/git-all.sh -a 7.x.x.Final -m ·tagged 7.x.x.Final"
            ```

        * Push the local tag from the local release branch to the remote blessed repository.

            ```shell
            $ ./droolsjbpm-build-bootstrap/script/git-all.sh push <tag> | where <tag> is 7.x.x.Final    

* Go to [JIRA](https://issues.redhat.org) and for each of our JIRA projects (DROOLS, OPTAPLANNER, JBPM, APPFORMER):

    * Open menu item *Administration*, link *Manage versions*, release the version.

    * Create a new version if needed. There should be at least 2 unreleased non-FUTURE versions.

* Upload the zips, documentation and javadocs to filemgmt and update the website.

    * To prepare and upload everything what is needed (all needed binaries for the webs) in filemgmt.jboss.org please 
    run the scripts
    
    ```shell
    $ ./droolsjbpm-build-bootstrap/script/release/prepareUploadDir.sh
    $ ./droolsjbpm-build-bootstrap/script/release/09_createjBPM_installers.sh
    $ ./droolsjbpm-build-bootstrap/script/release/10_uploadBinariesToFilemgmt.sh
    ```
    
    * The uploading to filemgmt.jboss.org doesn't work for an arbitrary user because of permission issues. Righy now the script 10_uploadBinariesToFilemgmt.sh
    can only be executed from the server kie-releases (kie-releases.lab.eng.brq.redhat.com).
    
    * The symbolic links `latest` and `latestFinal` links on filemgmt.jboss.org are also uploaded and link to the version number specified in 10_uploadBinariesToFilemgmt.sh  
    
    * To get access to `filemgmt.jboss.org`, see preparation above.

    * Folder `download_jboss_org` should be uploaded to `filemgmt.jboss.org/downloads_htdocs/drools/release`
    which ends up at [download.jboss.org](http://download.jboss.org/drools/release/)

        * Update [the download webpage](http://www.jboss.org/drools/downloads) accordingly.

    * Folder `docs_jboss_org` should be uploaded to `filemgmt.jboss.org/docs_htdocs/drools/release`
    which ends up at [docs.jboss.org](http://download.docs.org/drools/release/)

        * Use `documentation_table.txt` to update [the documentation webpage](http://www.jboss.org/drools/documentation).

* Check the symbolic links `latest` and `latestFinal` links on filemgmt, if and only if there is no higher major or minor release was already released.

    * Wait 5 minutes and then check these URL's. Hit ctrl-F5 in your browser to do a hard refresh:

        * [http://download.jboss.org/drools/release/latest/](http://download.jboss.org/drools/release/latest/)

        * [http://download.jboss.org/drools/release/latestFinal/](http://download.jboss.org/drools/release/latestFinal/)

        * [http://docs.jboss.org/drools/release/latest/](http://docs.jboss.org/drools/release/latest/)

        * [http://docs.jboss.org/drools/release/latestFinal/](http://docs.jboss.org/drools/release/latestFinal/)
        
* The script for [uploading](https://github.com/kiegroup/droolsjbpm-build-bootstrap/blob/main/script/release/10_uploadBinariesToFilemgmt.sh) the binaries and docs should upload all needed stuff 
for the web-pages
    
     https://www.drools.org
     
     https://www.jbpm.org
     
     https:/www.optaplanner.org

    You can find the docs and binaries here:

     docs:
   
     https://filemgmgt.jboss.org/docs_htdocs/\<repository>\/release/$kieVersion
        
     and can be seen here

     https://docs.jboss.org/drools/release/&kieVersion
     https://docs.jboss.org/jbpm/release/&kieVersion
     https://docs.jboss.org/optaplanner/release/&kieVersion
        
     binaries:
   
     https://filemgmt.jboss.org/download_htdocs/<repository>/releases/$kieVersion
       
     Thes binaries can only be checked once the webs are upgraded.            

* If it's a Final, non-hotfix release: publish the XSD file(s), by copying each XSD file to its website.

    * The Drools XSD files are at http://www.drools.org/xsd/[http://www.drools.org/xsd/]
    
    * Go to the https://github.com/kiegroup/droolsjbpm-knowledge/blob/main/kie-api/src/main/resources/org/kie/api/kmodule.xsd[kmodule.xsd] file (on main) and switch to the release tag.
    
    * Copy the raw file to https://github.com/kiegroup/drools-website/tree/main/xsd[drools-website's `xsd` directory].
    
    * Rename it from `kmodule.xsd` to `kmodule_<major>_<minor>.xsd` so it includes its version (major and minor only, not hotfixes or quantifiers). For example for release `6.3.0.Final` it is renamed to `kmodule_6_3.xsd`. Do not overwrite an existing file as there should never be an existing file (because the XSD is only copied for Final, non-hotfix releases).
    
    * Publish drools.org
    
* Protect the new creaed branches on github against forced pushes
    
    - https://github.com/kiegroup/<rep>/settings/branches
    - choose the new branch 
    
    
Announcing the release
----------------------

* Create a blog entry on [the kiegroup blog](http://blog.athico.com/)

    * Include a direct link to the new and noteworthy section and to that blog entry in all other correspondence.

    * Twitter and Google+ the links.

        * Most people just want to read the new and noteworthy, so link that first.

    * Mail the links to the user list.

* If it's a Final, non-hotfix release:

    * Notify TheServerSide and Dzone's Daily Dose.


Building a Product Tag
======================
**This paragraph describes the building of a product tag**

The community code repositories under the @kiegroup account contains all the code released as part of the community projects for Drools and jBPM. Every time a new minor or major version is released,
a new community branch is created for that version. For instance, at the time of this writing, we have, for instance, branches **main, 7.5.x, 6.5.x**, etc for each minor/major version released and
the *main* branch for future releases. Red Hat also has a mirror private repository that is used as a base for the product releases. This mirror repository contains all the code from the community
repositories, plus a few product specific commits, comprising branding commits (changing names, for instance from Drools to BRMS), different icons/images, etc.

This new tag will usually be based on the HEAD of a specific community branch with the product specific commits applied on top of it.

Follows an instruction on how to do that. These instructions assume:

* You have a local clone of all Drools/jBPM repositories
* The clones have a remote repository reference to the @kiegroup repositories that we will name **origin**
* The clones have a remote repository reference to the @jboss-integration (> 6.5.x) or Gerrit (>7.5.x) (remote: **jboss-integration** OR **gerrit**)

Please follow the steps of this [document](https://docs.google.com/document/d/1V-1vCOEYF6Ed-n3blHLowGgHV6rhEmJG98pbsqaaRsU/edit#) to produce a tag for productization.

