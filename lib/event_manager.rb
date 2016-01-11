require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "ae027c7f56dd40e1aa9c398881d85312"

# If the phone number is less than 10 digits assume that it is a bad number
# If the phone number is 10 digits assume that it is good
# If the phone number is 11 digits and the first number is 1, trim the 1 and use the first 10 digits
# If the phone number is 11 digits and the first number is not 1, then it is a bad number
# If the phone number is more than 11 digits assume that it is a bad number
def clean_phone_number(phone)
  if phone.length == 11 && (phone[0] == "1")
    phone.chars.drop(1).join
  elsif phone.to_s.length == 11 && (phone[0] != "1")
    "0000000000"
  elsif phone.to_s.length < 10
    "0000000000"
  elsif phone.to_s.length > 11
    "0000000000"
  else
     phone
  end
end

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end
puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, form_letter)
end
