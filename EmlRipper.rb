#!/usr/bin/ruby

# EmlRipper.rb
#
# This script was created by Mystik to extract attachments from .eml files
#
# The script utilizes the Mail gem to parse .eml files from path||file
# Mail  is a library that provides a simple and elegant way to read, write and send emails.
# The .eml file format is a standard format for email messages, it's used
# to save emails on disk and to transfer them between different email
# clients and servers.

require 'bundler/inline'
$VERBOSE = nil

gemfile 'ripper.gemfile' do
  source "https://rubygems.org"
  gem 'mail'
  gem 'pathname'
  gem 'optparse'
  gem 'highline'
  gem 'fileutils'
  gem 'artii'
  gem 'nokogiri'
end
require 'highline/import'
require 'uri'

a = Artii::Base.new :font => 'slant'
puts a.asciify('EmlRipper by Mystik')


def load_phishing_keywords(file_path)
  keywords = Set.new
  if File.exist?(file_path)
    File.foreach(file_path) do |line|
      keywords.add(line.strip.downcase)
    end
  else
    puts "-" * 40
    puts "Phishing keywords file not found: #{file_path}"
    puts "-" * 40
  end
  keywords
end

def extractor(file, destination,phishing_keywords)
  puts "PROCESSING FILE #{file}"
  email_message = Mail.read(file)

  text_body, html_body = extract_body_text(email_message)

  body_to_use = text_body || html_body || "No text body available"

  check_for_phishing_keywords(body_to_use, phishing_keywords)


  # Parsing headers
  email_from = email_message.from.join(", ")
  email_to = email_message.to.join(", ")
  email_subject = email_message.subject || "No Subject"
  email_date = email_message.date || "No Date"

  # Printing headers in a structured format
  puts "\nEML Info - #{file}"
  puts "-" * 40
  puts "* From:    #{email_from}"
  puts "\n"
  puts "* To:      #{email_to}"
  puts "\n"
  puts "* Subject: #{email_subject}"
  puts "\n"
  puts "* Date:    #{email_date}"
  puts "\n"
  puts "-" * 40

   # Print email body
  puts "-" * 40
  puts "\nEmail Body:"
  puts "-" * 40
  puts body_to_use

  links = extract_links(body_to_use)
  puts "-" * 40
  puts "\nLinks Found in Email:"
  puts "-" * 40
  if links.empty?
    puts "No links found"
    puts "-" * 40
  else
    links.each { |link| puts link }
  end

  basepath = File.join(destination, strip_bad_chars(email_subject))
  attachments = email_message.attachments.reject { |a| a.inline? }
  if attachments.empty?
    puts "-" * 40
    puts 'ATTACHMENTS'
    puts "-" * 40
    puts '>> No attachments found.'
    return
  end
  attachments.each do |attachment|
    filename = attachment.filename
    puts ">> Attachment found: #{filename}"
    filepath = File.join(basepath, filename)
    if File.exist?(filepath)
      overwrite = ask(">> The file #{filename} already exists! Overwrite it (Y/n)? ") { |q| q.validate = /\A[yn]\Z/i }
      if overwrite.upcase == 'Y'
        File.open(filepath, 'w') { |f| f.write(attachment.body.decoded) }
        puts ">> #{filename} saved!"
      else
        puts '>> Skipping...'
      end
    else
      FileUtils.mkdir_p(basepath) unless File.directory?(basepath)
      File.open(filepath, 'w') { |f| f.write(attachment.body.decoded) }
      puts ">> #{filename} saved!"
    end
  end
end

def extract_body_text(email_message)
  if email_message.multipart?
    text_part = email_message.text_part ? email_message.text_part.body.decoded : nil
    html_part = email_message.html_part ? email_message.html_part.body.decoded : nil
  else
    text_part = email_message.body.decoded
    html_part = nil
  end

  if html_part
    html_to_text = Nokogiri::HTML(html_part).text
  end

  return text_part, html_to_text
end

def extract_links(text)
  return [] unless text
  text.scan(/https?:\/\/[^\s\n]+/).uniq
end


def check_for_phishing_keywords(text, keywords)
  found_keywords = keywords.select { |keyword| text.downcase.include?(keyword) }
  unless found_keywords.empty?
    puts "-" * 40
    puts "\nALERT: Likely phishing email. Phishing keywords detected: #{found_keywords.to_a.join(', ')}"
    puts "-" * 40

  end
end


def strip_bad_chars(name)
  illegal_chars = /[\/\\|\[\]\{\}:<>+=;,?!*"~#$%&@']/
  name.gsub(illegal_chars, '_')
end

def fetch_eml(path, recursively = false)
  path = Pathname.new(path)
  if recursively
    return Dir.glob(File.join(path.to_path, '**', '*.eml')).map { |f| Pathname.new(f) }
  else
    return Dir.glob(File.join(path.to_path, '*.eml')).map { |f| Pathname.new(f) }
  end
end

def find_eml(arg_value)
  file = Pathname.new(arg_value)
  if file.file? && file.extname == '.eml'
    return file
  else
    raise ArgumentError, "#{file} is not a valid EML file."
  end
end

def find_eml_path(arg_value)
  path = Pathname.new(arg_value)
  if path.directory?
    return path
  else
    raise ArgumentError, "#{path} is not a valid directory."
  end
end

def argument_parser
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = 'Usage: script.rb [OPTIONS]'
    opts.on('-s', '--source PATH', 'the directory containing the .eml files to extract attachments (default: current working directory)') do |v|
      options[:source] = v
    end
    opts.on('-r', '--recursive', 'allow recursive search for .eml files under SOURCE directory') do |v|
      options[:recursive] = v
    end
    opts.on('-f', '--files FILE', 'specify a .eml file or a list of .eml files to extract attachments') do |v|
      options[:files] = v
    end
    opts.on('-d', '--destination PATH', 'the directory to extract attachments to (default: current working directory)') do |v|
      options[:destination] = v
    end
  end
  parser.parse!
  options[:source] = Dir.pwd unless options[:source]
  options[:destination] = Dir.pwd unless options[:destination]
  options
end

def main
  phishing_keywords = load_phishing_keywords("phishing_keywords.txt")
  options = argument_parser
  if options[:files].nil? && options[:source].nil?
    puts "No files or source directory specified!"
    exit
  end
  eml_files = options[:files] ? [options[:files]] : fetch_eml(options[:source], options[:recursive])
  if eml_files.empty?
    puts 'No EML files found'
    exit
  end
  eml_files.each do |file|
    extractor(file, options[:destination],phishing_keywords)
  end
  puts 'Done.'
end

main()
