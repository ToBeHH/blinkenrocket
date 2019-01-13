require "rubygems"
require "rmagick"
require "base64"
require "json"
include Magick

data = JSON.parse(Base64.decode64(ARGV[0].partition('=').last.gsub('%3D',"")))

puts "Creating image #{data['name'].gsub(' ','_')}.gif with #{data['animation']['length']} frames"

gif = ImageList.new

data['animation']['length'].times do |current_frame|
  image = Image.new(323, 323) { self.background_color = "black" }

  # Create canvas to draw on
  gc = Magick::Draw.new

  # create empty dots
  gc.stroke('#708091')
  gc.fill('#708091')
  gc.fill_opacity(1)

  8.times do |x|
  	8.times do |y|
  	  gc.circle(x*40+8+16, y*40+8+16, x*40+8,y*40+8+16)
  	end
  end

  # now add the dots
  gc.stroke('#ff0000')
  gc.fill('#ff0000')
  gc.fill_opacity(1)
  8.times do |x|
  	column = data['animation']['data'][current_frame*8 + x]
  	8.times do |y|
  	  if ((column & (128 >> y)) > 0)
  	    gc.circle(x*40+8+16, y*40+8+16, x*40+8,y*40+8+16)
  	  end
  	end
  end

  # finally add the drawing to the image
  gc.draw(image)

  # and add the image to the list of images
  gif << image
end

gif.delay = 100 / data['speed']
gif.ticks_per_second = 100
gif.iterations = data['repeat']

# write the file
gif.write("images/#{data['name'].gsub(' ','_')}.gif")
