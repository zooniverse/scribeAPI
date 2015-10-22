# This script crawls certain known Emigrant Savings Bank items in the NYPL Repo,
# queries all of their captures, and dumps the result in a special intermediary 
# subjects csv (subjects_from_api.csv). The resulting CSV should be processed 
# by split_subjects_vertically because many images are too wide.

# Depends on ENV vars:
#   DC_API_KEY

require 'nypl_repo'
require 'csv'

client = NyplRepo::Client.new ENV['DC_API_KEY']
item_uuids = [
  "be6d6300-ecf4-0132-456e-58d385a7b928", # Book 1 (1 to 1,555) http://digitalcollections.nypl.org/items/df712aa0-00b1-0133-fbd7-58d385a7bbd0
  "bf0c1890-ecf4-0132-faa2-58d385a7b928", # Book 2 (1,556 to 2, 721) http://digitalcollections.nypl.org/items/c0c38370-015a-0133-065e-58d385a7bbd0
  "bfe9fbe0-ecf4-0132-7e52-58d385a7b928", # Book 3 (2,722 to 3,699) http://digitalcollections.nypl.org/items/5bb969d0-0241-0133-f196-58d385a7b928
  "c0921750-ecf4-0132-1737-58d385a7b928", # Book 4 (3,700 to 4,499) http://digitalcollections.nypl.org/items/109c0900-02e7-0133-03cf-58d385a7bbd0
  "c1374de0-ecf4-0132-73fc-58d385a7b928", # Book 5 (4,500 to 5,499) http://digitalcollections.nypl.org/items/e53b4fe0-02fc-0133-0e0d-58d385a7bbd0
  "c1f9fac0-ecf4-0132-9260-58d385a7b928", # Book 6 (5,500 to 6,403) http://digitalcollections.nypl.org/items/20aa00a0-0311-0133-9d30-58d385a7bbd0
  "c53c32d0-ecf4-0132-b51f-58d385a7b928", # Real Estate Loans No. 9 http://digitalcollections.nypl.org/items/6cf0ed60-23ef-0133-6b54-58d385a7b928
  "c5d23760-ecf4-0132-8bed-58d385a7b928", # Real Estate Loans No. 10 http://digitalcollections.nypl.org/items/59b0a100-23fd-0133-b24f-58d385a7bbd0
  "c6697fe0-ecf4-0132-b1fc-58d385a7b928", # Real Estate Loans No. 11 http://digitalcollections.nypl.org/items/cf0c3ee0-24bd-0133-5e2d-58d385a7b928
]


subjects = []
index = 0

item_uuids.each do |item_uuid|
  sleep 0.51
  captures = client.get_capture_items item_uuid

  puts "Got #{captures.size} captures for item #{item_uuid}"

  captures.each_with_index do |capture, i|
    subject = {
      order: (index += 1),
      file_path: "http://images.nypl.org/index.php?id=#{capture['imageID']}&t=v",
      thumbnail: "http://images.nypl.org/index.php?id=#{capture['imageID']}&t=r",
      capture_uuid: capture['uuid'],
      page_uri: "http://digitalcollections.nypl.org/items/#{capture['uuid']}",
      book_uri: "http://digitalcollections.nypl.org/items/#{captures.first['uuid']}"
    }
    subjects << subject
  end
end

out_path = "#{File.dirname(File.dirname(__FILE__))}/subjects/subjects_from_api.csv"
CSV.open(out_path, "wb") do |csv| 
  csv << subjects.first.keys

  subjects.each do |subject| 
    csv << subject.values
  end
end
puts "Wrote to #{out_path}. Ready to load."
