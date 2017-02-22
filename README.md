[![Stories In Progress](https://badge.waffle.io/jesperrasmussen/octopress-flickr-generator.png?label=in+progress&title=In+Progress)](https://waffle.io/jesperrasmussen/octopress-flickr-generator)
octopress-flickr-generator
=======================

A page generator for allowing page generation based on sets from flickr.

This allows for automatic creation of a complete gallery, based on a users sets and collections on flickr.

Also, instead of providing a complete plug'n'play setup, this generator uses template files for rendering the set index as well as the actual set gallery, allowing for customization as you want.

## Additional features

One very special thing about the generator, is that it has a special "clever" way of listing the flickr sets.

It will per default make an index of your sets, sorted by the time of the newest image in each set. However, if a set is part of a collection, the generator will group these per default.

This allows for basic grouping, something I've been missing in most other plugins.

####Example

I've been on a vacation to Asia, and want a set for each city I've visited. Instead of simply having an index that lists the sets chronologically like so:

 * Tokyo
 * Beijing
 * My very cute cat
 * Calcutta

octopress-flickr-generator will, if you use Collections in flickr to gather the asian cities sets in a "Asia trip" collection, render the list like so:

 * Asia Trip
 	* Tokyo
 	* Beijing
 	* Calcutta
 * My very cute cat 


## Prerequirements

octopress-flickr-generator uses a few things, like flickraw and memoize for caching. To get these, add these to your Gemfile:

	gem 'flickraw'
	gem 'builder', '> 2.0.0'
	gem 'persistent_memoize'
	
After adding these, run `bundle install` in the octopress installation to fetch and install the needed gems.

##API setup

You'll need an API key and a secret wors from flickr to get the generator running. It's available [from flickr's API pages](http://www.flickr.com/services/developer/api/)

Once you have these, you may add the following to your _config.yml:

	flickr:
	  api_key: 'API key gotten from flickr's API services'
	  secret: 'The secret word gotten from flickr's API services'
	  user_id: 'The user id of the user whose sets you want'
	  thumb_size: 'n'
	  large_size: 'b'
	  dir: 'photos'
	  
The fields not obvious above, are as follows:

`user_id` This is your user id (NOT username). It's a bit hidden on flickr - [This service gets it easily for you](http://idgettr.com)  
`thumb_size` The flickr size of your thumbnails - a list is available [from flickr](http://www.flickr.com/services/api/misc.urls.html)  
`large_size` Same definition as `thumb_size`. This is the image you probably want to view in a gallery as it's a larger version of the image.  
`dir` The basedir of your gallery. Mine is ´photos´, causing all gallery URL's to start with `/photos`

##Setup

This is pretty simple. Copy or symlink the plugins from the `plugins` folder in the repo to your Octopress plugins folder. 

The `source/_layouts` folder should of course be in `source/_layouts` of your octopress installation, as this is where the generator will look for them.

I've included some simple examples which you will probably modify a lot to your needs.

When this is done, run the `rake generate` task as usual, and the gallery index should be generated.

##Beware - here may be dragons

It seems flickr's image sizes are not always available for all images. The generator should try another format if the requested does not exist. However, the size you get may not necessarily fit your template.

Also, I use flickr caching to avoid extensive flickr API calls every time generate is called. If you make changes to sets or photos after they have been indexed, you may want to clear `.flickr-cache` folder in your installation.

## Acknowledgements

flickrcaching and sizes (flickr_helpers.rb) based on the work of [Neil](https://raw.github.com/neilk/octopress-flickr)
