# User Guide

## Introduction

`begin` is a terminal command for running logic-less project templates. Templates are just [git](https://git-scm.com)
repositories whose files and directories are copied to the working directory when run. Directory names, file names, 
and file content can contain [Mustache](https://mustache.github.io/mustache.5.html) tags - the values of which are
prompted for in the terminal and substituted when the template is run.

{% include guide_example_01.ext %}

## Installing A Template

* Install a template with the ```begin install``` command, e.g:

  ```bash
  $ begin install path/to/template.git
  ```

* Once you have installed a template, you may run it...

## Running A Template

* Run a template with the ```begin new``` command, e.g:

  ```bash
  $ begin new template
  ```

## Template Structure

* A template is just a [Git](https://git-scm.com) repository


* A template can therefore contain any number of files and directories, and can be easily shared with others


* A template name can optionally start with `begin-`. This prefix is ignored and stripped by the command automatically, e.g:

  ```bash
  $ begin install path/to/begin-latex-document.git
  $ begin new latex-document
  ```

## Template Tags

* File names, directory names, and file content can contain [Mustache](https://mustache.github.io/mustache.5.html) tags


* Create a ```.begin.yml``` in your template repository to describe expected tags:

  ```yaml
  tags: !!omap
      title:
          label: 'Title'
      author:
          label: 'Author'
      sections:
          label: 'Sections'
          array: true
  ```


* The user will be prompted for expected tags upon running a template:

  ```
  $ begin new latex-document
  Title: My Amazing New Document
  Author: John Smith
  Sections (CTRL+D to stop): Introduction
  Sections (CTRL+D to stop): Background
  Sections (CTRL+D to stop): ^D
  Running template 'latex-document'...
  Template 'latex-document' successfully run
  ```

## Terminal Commands

* Run a template with ```begin new```

* List installed templates with ```begin list```

* Install a template with ```begin install```

* Uninstall a template with ```begin uninstall```

* Update templates with ```begin update```

* Get help with ```begin help```

* Print the command version with ```begin version```

