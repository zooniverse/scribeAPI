# Emigrant images generally have two pages. This script crawls subjects_from_api.csv,
# which is assumed to have uncropped subjects from the API. For each subject, it 
# checks the dimensions and splits it in two if if's found to be wide. It uploads
# the results to S3. At the end a new subjects csv is generated (group_only_one_group.csv),
# which contains all the same info as the original csv but references the cropped
# derivs and includes capture-level metadata about the crop.

# Depends on ENV vars:
#   S3_ID
#   S3_SECRET

require 'csv'
require 'tempfile'
require 'net/http'
require 'rmagick'
require "s3"

RECUT                   = true                # Set to true to re-upload even if the file already exists
DESKEW                  = true                # Set to true to attempt to deskew images before splitting
BUCKET_NAME             = 'scribe.nypl.org'   # S3 Bucket name
BUCKET_FOLDER           = 'emigrant'          # Folder within bucket to place uploaded files
SPLIT_OVERLAP           = 0.03                # When splitting pages cut each side so that it bleeds this 
                                              #   far into the other side. (content sometimes bleeds over
                                              #   midline)
S3_API_FAILURE_RETRY    = 3                   # S3 connection failures are common. Retry this many times

START_AT = ARGV[0].nil? ? nil : ARGV[0].to_i
STOP_AT = ARGV[1].nil? ? nil : ARGV[1].to_i

$in_path = "#{File.dirname(File.dirname(__FILE__))}/subjects/subjects_from_api.building.csv"
$out_path = "#{File.dirname(File.dirname(__FILE__))}/subjects/group_only_one_group.building.csv"

$s3 = S3::Service.new(access_key_id: ENV['S3_ID'], secret_access_key: ENV['S3_SECRET'])
$bucket = $s3.buckets.find BUCKET_NAME

# Saves img (IO Stream) to path (String)
# e.g. upload_img(<IO>, "folder/subfolder/filename.jpg")
def upload_image(img, path, retries_remaining = S3_API_FAILURE_RETRY)
  puts "  Uploading #{img.columns}x#{img.rows} image to #{path}"

  # If this image already uploaded, skip (unless we're recutting everything)
  if $existing_paths.include?(path) && ! RECUT
    puts "    Skipping cause already uploaded"
  
  else
    obj = $bucket.objects.build(path)
    obj.content_type = 'image/jpeg'
    obj.content = img.to_blob 
    obj.acl = :public_read
    begin
      obj.save

    rescue S3::Error::RequestTimeout => e
      if retries_remaining > 0
        sleep 10
        upload_image img, path, retries_remaining - 1
      else
        puts "FAILED to write to #{path} after #{S3_API_FAILURE_RETRY} retries. Aborting"
        exit
      end
    end
    sleep 0.25
  end
end

# Updates out_path csv with given subjects rows
def update_csv(rows)
  CSV.open($out_path, "wb") do |csv| 

    # `rows` is just an array of hashes; the first will be the headers
    csv << rows.first.keys

    rows.each do |row| 
      csv << row.values
    end
  end
end

# Detect best rotation angle by deskewing a sample of the image's middle
def deskew_angle(img)
  temp = Tempfile.new 'split-subjects-vertically'
  sample = img.clone
  # inset crop 10% from borders:
  sample_inset = 0.10
  sample.crop! img.columns * sample_inset, img.rows * sample_inset, img.columns - (img.columns * 2 * sample_inset), img.rows - (img.rows * 2 * sample_inset)
  sample.write temp.path
  sample.write "temp.sample.jpg"
  angle = `convert #{temp.path} -deskew 40 -format '%[deskew:angle]' info:`.to_f
  # If angle is greater than this, it's probably an error
  angle.abs >= 2 ? 0 : angle
end

# Upload default derivs for img, returning urls
def upload_derivs(img, filename)

  ret = {}

  # Full:
  full_path = "#{BUCKET_FOLDER}/full/#{filename}" # data['capture_uuid']}.#{suffix}.jpg"
  upload_image img, full_path
  ret['file_path'] = "https://s3.amazonaws.com/#{BUCKET_NAME}/#{full_path}"

  # Thumb (exactly 150px wide by however tall):
  img.change_geometry("150") { |cols, rows, img| img.resize!(cols, rows) }
  thumb_path = "#{BUCKET_FOLDER}/thumb/#{filename}"
  upload_image img, thumb_path
  ret['thumbnail'] = "https://s3.amazonaws.com/#{BUCKET_NAME}/#{thumb_path}"

  ret
end

$rows = []
$rows = CSV.read($out_path, headers: true).map { |r| r.to_h }
$headers = CSV.read($out_path).first

# Add row to csv
def add_row(row)

  # Delete row if it already exists
  $rows.delete_if { |r| r['file_path'] == row['file_path'] }
  $rows << row

  # rewrite csv:
  update_csv($rows)
end

# Crop given image 
def make_crop(img, row, name, coords)
  _row = row.clone

  # Perform crop:
  crop = img.crop coords[:x], coords[:y], coords[:w], coords[:h]

  # Add width, height to csv row:
  _row.merge! width: coords[:w], height: coords[:h]
  # Add source_ coordinates to csv row:
  source_coords = coords.inject({}) {|h, (k,v)| h["source_#{k}"] = v; h }
  _row.merge! source_coords
  # Add URLs to csv row:
  urls =  upload_derivs crop, "#{_row['capture_uuid']}.#{name}.jpg"
  _row.merge! urls

  add_row _row
end

# Perform appropriate crops:
def make_crops(img, row)
  # Cut it in two if it's wider than it is tall:
  if img.columns > img.rows
    puts "Splitting #{row['file_path']}"

    overlap = SPLIT_OVERLAP * img.columns

    coords = { x: 0, y: 0, w: img.columns / 2 + overlap, h: img.rows }
    make_crop img, row, 'left', coords
    
    coords = { x: img.columns / 2 - overlap, y: 0, w: img.columns / 2 + overlap, h: img.rows }
    make_crop img, row, 'right', coords

  else
    puts "Not splitting #{row['file_path']}"

    coords = { x: 0, y: 0, w: img.columns, h: img.rows }
    make_crop img, row, 'unsplit', coords
  end
end

# Load an rmagick image instance, safely returning nil if images.nypl returns "0"
def load_image(url)
  require 'open-uri'
  temp = Tempfile.new 'split-vertically'
  image = nil

  seems_legit = false
  open(temp.path, 'wb') do |file|
    file << open(url).read
    # Images server returns literally "0" if no image exists
    seems_legit = file.size > 1
  end
  sleep 0.25 # Let's try to be nice to the images server

  Magick::Image.read(temp.path).first if seems_legit
end

# Get list of existing paths in 
$existing_paths = $bucket.objects.select { |b| b.key.match /#{BUCKET_FOLDER}\// }.map { |b| b.key }

puts "Processing #{START_AT} - #{STOP_AT} in #{CSV.foreach($in_path, headers: true).size} line input"
CSV.foreach($in_path, headers: true) do |row| 
  next if ! START_AT.nil? && $. < START_AT
  break if ! STOP_AT.nil? && $. > STOP_AT

  puts "#{$.}: Processing #{row['file_path']}"
  row = row.to_h

  crops = {}

  # Load image from std url:
  img = load_image row['file_path']
  if img.nil? 
    puts "  Problem loading #{row['file_path']}; Skipping"
    next
  end

  # Perform automatic deskew?
  if DESKEW
    img.background_color = 'black'
    # Save source_rotation to csv row and rotate:
    img.rotate! (row['source_rotated'] = deskew_angle(img))
  end

  # Make crops:
  make_crops img, row

end

puts "Done"
