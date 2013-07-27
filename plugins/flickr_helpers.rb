class FlickrSizes 
  @@sizes = [    
    {code: "original_video", label: "Original Video", max: nil },
    {code: "mobile_mp4", label: "Mobile MP4", max: 480 },
    {code: "site_mp4", label: "Site MP4", max: 640 },
    {code: "video_player", label: "Video Player", max: 640 },
    {code: "o", label: "Original", max: nil },
    {code: "b", label: "Large", max: 1024 },
    # {code: "c", label: "Medium 800", max: 75 },  # FlickrRaw doesn't know about this size
    {code: "z", label: "Medium 640", max: 640 },
    {code: "__NONE__", label: "Medium", max: 500 },
    {code: "n", label: "Small 320", max: 320 },
    {code: "m", label: "Small", max: 240 },
    {code: "t", label: "Thumbnail", max: 100 },
    {code: "q", label: "Large Square", max: 150 },
    {code: "s", label: "Square", max: 75 }
  ]

  def self.sizes
    @@sizes
  end

  def self.getSourceAndDimensionsForSize(sizes, size)
    # try getting the size we wanted, then try getting ANY size, going from largest to smallest
    sizeCodesToTry = [ size ] + @@sizes.map{ |s| s[:code] }
    sizeInfo = nil
    for code in sizeCodesToTry
      sizeInfo = pickSize(sizes, code)
      if sizeInfo
        break
      end
    end
    if (sizeInfo.nil?)
      raise "could not get a size"
    end
    [ sizeInfo["source"], sizeInfo["width"], sizeInfo["height"] ]
  end

  def self.getSizeByCode(code) 
    @@sizes.select{ |s| s[:code] == code }[0]
  end

  def self.pickSize(sizes, desiredSizeCode)
    desiredSizeLabel = self.getSizeByCode(desiredSizeCode)[:label]
    sizes.select{ |item| item["label"] == desiredSizeLabel }[0]
  end

  def self.calculateDimensions(desiredSizeCode, width, height)
    width = width.to_i
    height = height.to_i
    size = self.getSizeByCode(desiredSizeCode)
    factor = 1
    unless size == nil or size[:max].nil?
      factor = size[:max].to_f / [width, height].max
    end
    return [width, height].map { |dim| (dim * factor).to_i }
  end
end

class FlickrCache
  def self.cacheFile(name)
    cache_folder     = File.expand_path "../.flickr-cache", File.dirname(__FILE__)
    FileUtils.mkdir_p cache_folder
    return "#{cache_folder}/#{name}"
  end
end

class FlickrApiCached
  def initialize 
    @photos = FlickrApiCachedPrefix.new(:photos)
    @photosets = FlickrApiCachedPrefix.new(:photosets)
    @collections = FlickrApiCachedPrefix.new(:collections)
  end

  def photos
    return @photos
  end

  def photosets
    return @photosets
  end

  def collections
    return @collections
  end
end

class FlickrApiCachedPrefix
  include PersistentMemoize

  def initialize(sym)
    @prefix = flickr.send(sym)
    memoize(:method_missing, FlickrCache.cacheFile("api_#{sym}"))
  end

  def method_missing(sym, *args, &block)
    @prefix.send sym, *args, &block
  end

end

def flickrCached; $flickrCached ||= FlickrApiCached.new end