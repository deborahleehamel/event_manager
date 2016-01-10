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
  if phone.length == 11 && phone[0] == 1
    phone.shift
  elsif phone.length == 11 && phone[0] !== 1
    phone.delete
  elsif phone.length < 10 || > 11
    phone.delete
  else
    phone
  end
end

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)

  # legislator_names = legislators.collect do |legislator|
  #   "#{legislator.first_name} #{legislator.last_name}"
  # end

  # legislator_names.join(", ")
end
  # puts "#{name} #{zipcode}"

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
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)
  # personal_letter = template+_letter.gsub('FIRST_NAME', name)
  # personal_letter.gsub!('LEGISLATORS', legislators)a
  save_thank_you_letters(id, form_letter)
  # puts form_letter
  # puts "#{name} #{zipcode} #{legislators}"
end

# if zipcode is exactly 5 digits, assume ok
# if zipcode is more than 5 digits, truncate it to the first 5 digits
# if zipcode is less than 5 digits, add zeros to the font until 5 digits


# contents = File.read "event_attendees.csv"
# puts contents
# lines = File.readlines "event_attendees.csv"
# lines.each_with_index do |line,index|
#   next if index == 0
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end
