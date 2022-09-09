---
layout: post
title:  "Azure DevOps Pipelines; Editing Provisioned Wiki"
date:   2022-09-08 16:00:00 +0100
author: James
tags:
- azure
- devops
- pipelines
- "provisioned wiki"

category: code
---

<hr />

[TL;DR](#tldr)

If you have provisioned a project wiki in an Azure DevOps then you may have noticed that the first wiki you create has no visible git repository supporting it; in fact, you can have the Repos service disabled and this wiki will still work.

Whilst it's trivial to edit this wiki via the user interface, you might want to programmatically update it via an Azure DevOps pipeline and for that you will need a specific setup. This setup is discussed below, and whilst it is relatively simple, it is seemingly undocumented.

## Azure DevOps CLI

The [Az DevOps CLI](https://docs.microsoft.com/en-us/cli/azure/devops?view=azure-cli-latest){:target="_blank"} has all the commands you'll need to check and update the wiki. [This page](https://docs.microsoft.com/en-us/cli/azure/devops/wiki?view=azure-cli-latest){:target="_blank"} lists the commands available that interact with the wikis.

Running `az devops wiki list` using the System Access Token (with only default permissions) will return a list of available wikis. As can be seen below in a simple Azure pipeline script, an example project `UpdateWikiExample` has one wiki available called `UpdateWikiExample .wiki` of type `projectWiki`.

~~~ yaml
trigger: none
pr: none

steps:
- script: |
    az devops configure --defaults project=UpdateWikiExample
    az devops wiki list
  env:
    AZURE_DEVOPS_EXT_PAT: $(System.AccessToken)
~~~

~~~ json
[
  {
    "id": "9f66a54b-56e6-4597-b461-e80ab53713a2",
    "mappedPath": "/",
    "name": "UpdateWikiExample.wiki",
    "projectId": "0476ecfa-2360-4b7f-a620-f7a7f72f6507",
    "properties": null,
    "remoteUrl": "https://dev.azure.com/jameswithers/0476ecfa-2360-4b7f-a620-f7a7f72f6507/_wiki/wikis/9f66a54b-56e6-4597-b461-e80ab53713a2",
    "repositoryId": "9f66a54b-56e6-4597-b461-e80ab53713a2",
    "type": "projectWiki",
    "url": "https://dev.azure.com/jameswithers/0476ecfa-2360-4b7f-a620-f7a7f72f6507/_apis/wiki/wikis/9f66a54b-56e6-4597-b461-e80ab53713a2",
    "versions": [
      {
        "version": "wikiMaster",
        "versionOptions": null,
        "versionType": null
      }
    ]
  }
]
~~~

## Wiki Edits

Retrieving a list of wikis is one thing, but we want to be able to update the project wiki.

Expanding on the pipeline above we could add a command to create a new page.
~~~
az devops wiki page create --path NewPage --wiki "UpdateWikiExample.wiki" --comment "added a new page" --content "# New Wiki Page Created!"
~~~

However, upon running this pipeline now we get the error.
~~~
ERROR: TF401019: The Git repository with name or identifier 9f66a54b-56e6-4597-b461-e80ab53713a2 does not exist or you do not have permissions for the operation you are attempting.
~~~

This error would lead you to believe that the build service account in use (via the System Access Token) should have some specific contribution permissions provided to the project's wiki. Whilst this is indeed needed, and that configuration will be shown below, that is not what is needed here.

To fix this issue we need to provide this pipeline with authorisation to access the wiki resource. This can be done by adding and then subsequently approving a pipeline resource referencing the git repository that supports the wiki. The `name` reference can be confirmed from the output from the `list` command we ran previously.

~~~
resources:
  repositories:
  - repository: WikiGit
    type: git
    name: UpdateWikiExample.wiki
~~~

Adding the above and then rerunning the pipeline will prompt another error which shows the missing contribution permissions.

~~~
ERROR: The wiki page operation failed with message : User does not have write permissions for this wiki.
~~~

Fix the project's build service account permissions on the wiki by switching the `Contribute` setting to `Allow`.

<a alt="Wiki Permissions" data-lightbox="image-1" href="{{ site.baseurl }}/assets/img/2022-09-08-Az-DevOps-Pipelines-Edit-Provisioned-Wiki-1.png">
    ![Wiki Permissions]({{ site.baseurl }}/assets/img/2022-09-08-Az-DevOps-Pipelines-Edit-Provisioned-Wiki-1.png)
</a>

## TL;DR

Include the project wiki's (hidden) git repository as a pipeline resource and approve the use of it. Set the `Contribute` access level to `Allow` for the project's service account in the wiki's security settings.
