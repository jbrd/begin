# begin

A terminal command for beginning new projects quickly.

## Installation

To install on your system, obtain the Ruby gem with:

    $ gem install begin_cli


## Overview

### Running A Template

* Run a template with the ```begin new``` command, e.g:

  ```bash
  $ begin new cpp-project
  ```

### Template Structure

* A template is just a [Git](https://git-scm.com) repository


* A template can therefore contain any number of files and directories, and can be easily shared with others


* Use the ```begin install``` command to install a template


* A template name can optionally start with `begin-`. This prefix is ignored and stripped by the command automatically, e.g:

  ```bash
  $ begin install http://git-repo/begin-latex-document.git
  $ begin new latex-document
  ```

### Template Variables

* File names, directory names, and file content can contain [Mustache](https://mustache.github.io/mustache.5.html) tags


* Create a ```.begin.yml``` in your template repository to describe expected tags:

  ```
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

### Terminal Commands

* Run a template with ```begin new```
* List installed templates with ```begin list```
* Install a template with ```begin install```
* Uninstall a template with ```begin uninstall```
* Update templates with ```begin update```
* Get help with ```begin help```
* Print the command version with ```begin version```


## Development

* After checking out the repo, run ```bundle install --path vendor/bundle``` to install dependencies
* Run ```bundle exec begin``` to use the gem in this directory, ignoring other installed copies of this gem
* Run ```bundle exec rubocop``` to ensure the code conforms to style guidelines
* To package this gem from source, run ```bundle exec rake install```
* To release a new version, update the version number in `version.rb`, and then run ```bundle exec rake release```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jbrd/begin. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## Contributors

* James Bird (jbrd)


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

