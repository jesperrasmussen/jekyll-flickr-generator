require "flickraw"
require "persistent_memoize"
require "time"

module Jekyll

  class FlickrImage
    def initialize (id, size)
      @id = id
      @size = size
    end

    def to_liquid 
      info = flickrCached.photos.getInfo(photo_id: @id)
      # get the dimensions
      @sizes = flickrCached.photos.getSizes(photo_id: @id)
      @src, @width, @height = FlickrSizes.getSourceAndDimensionsForSize(@sizes, @size)
      @src_large, @width_large, @height_large = FlickrSizes.getSourceAndDimensionsForSize(@sizes, flickr_size_large)
      @date = info['dates']['taken']
      @timestamp = Time.parse(@date).to_i

      if @desc.nil? or @desc.empty?
        @desc = info['description']
      end

      {
        "size" => @size,
        "src" => @src,
        "src_large" => @src_large,
        "secret" => info['secret'],
        "username" => info['owner']['username'],
        "page_url" => FlickRaw.url_photopage(info),
        "title" => info['title'],
        "date" => @date,
        "timestamp" => @timestamp,
        "description" => @desc,
      }
    end
  end

  class FlickrIndexPage < Page
    def initialize(site, base, dir, sets)
      @site = site
      @base = base
      @dir = dir.gsub("source/", "") 
      @name = "index.html"

      self.process(@name)
      self.read_yaml(File.join(base, "_layouts"), "flickr_index.html")
      self.data["title"] = site.config["flickr"]["title"] || "Photos"

      hashmap = {}

      sets.each do |set|
        category = set.data["category"]
        hashmap["#{category}"] = hashmap["#{category}"] || []
        hashmap["#{category}"].push(set.data)
      end
      self.data["sets"] = hashmap
    end
  end

  class FlickrSetPage < Page

    def initialize(site, base, setname, setid, dir)
      @site = site
      @base = base
      @dest_dir = setname.gsub("source/", "").downcase.gsub(" ", "-")
      @dir = "#{dir}/#{@dest_dir}"
      @name = "index.html"
      @setname = setname
      @photos = []

      @name = 'index.html'
      self.process(@name)
      
      photos = flickrCached.photosets.getPhotos(:photoset_id => setid)
      photos['photo'].each do |photo|
        flickrPhoto = FlickrImage.new(photo['id'], site.config['flickr']['thumb_size'])

        @photos.push(flickrPhoto.to_liquid())
      end

      #Calculates the taken time of set. If part of collection, unifies the time for sorting
      max = @photos.max_by { |photo| photo["timestamp"] }

      self.read_yaml(File.join(base, '_layouts'), 'flickr_set_index.html')
      self.data["photos"] = @photos
      self.data["path"] = "/#{@dir}"
      self.data["primary_image"] = FlickrImage.new(photos.primary, site.config['flickr']['thumb_size']).to_liquid
      self.data["date_taken"] = max["timestamp"]
      self.data["slug"] = @dest_dir
      self.data["title"] = setname
    end
  end

  class FlickrIndexGenerator < Generator
    safe true

    def generate(site)

      dir = site.config["flickr"]["dir"] || "photos"
      sets = []
      collections = Hash.new

      # Get collections from user
      user_collections = flickrCached.collections.getTree(:user_id => site.config['flickr']['user_id'])
      user_collections['collection'].each do |collection|
        activecollection = {
          :date => '',
          :sets => []
        }
        collection['set'].each do |set|
          activecollection[:sets].push(set.id)
        end
        collections["#{collection['title']}"] = activecollection
      end

      response = flickrCached.photosets.getList(:user_id => site.config['flickr']['user_id'])
      response['photoset'].each do |photoset|
        photosetid = photoset['id']
        setindex = FlickrSetPage.new(site, site.source, photoset.title, photosetid, dir)
        
        setindex.render(site.layouts, site.site_payload)
        setindex.write(site.dest)
        category = collections.select {|k,v| v[:sets].include?(photosetid)}.first

        setindex.data["category"] = category.nil? ? Time.at(setindex.data["date_taken"]).year : category[0]
        site.pages << setindex
        sets << setindex
      end

      sets = sets.group_by{|set| set.data['category'] ? set.data['category'] : set.data['date_taken']}.
        map{|k,v| v.sort_by{|set| -set.data['date_taken']}}.
        sort_by{|sets| -sets[0].data['date_taken']}.flatten

      flickr_index = FlickrIndexPage.new(site, site.source, '', sets)
      flickr_index.render(site.layouts, site.site_payload)
      flickr_index.write(site.dest)
      site.pages << flickr_index
    end
  end  
end

def configuration; $configuration = Jekyll.configuration({}) end
def flickr_size_large; $flickr_size_large = configuration['flickr']['large_size'] end
FlickRaw.api_key        = configuration['flickr']['api_key']
FlickRaw.shared_secret  = configuration['flickr']['secret']