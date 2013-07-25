octopress-flickr-generator
=======================

A page generator for allowing page generation based on sets from flickr.

This allows for automatic creation of a complete gallery, based on a users sets and collections on flickr.

## Prerequirements

octopress-flickr-generator uses a few things, like flickraw and memoize for caching. To get these, add these to your Gemfile:

	gem 'flickraw'
	gem 'builder', '> 2.0.0'
	gem 'persistent_memoize'
	
After adding these, run `bundle install` in the octopress installation to fetch and install the needed gems.

##Setup

This is pretty simple. Copy or symlink the plugins from the `plugins` folder in the repo to your Octopress plugins folder.

## Acknowledgements

flickrcaching and sizes (flickr_helpers.rb) based on the work of [Neil](https://raw.github.com/neilk/octopress-flickr)