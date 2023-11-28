# EmlRipper
EmlRipper is a Ruby script for parsing .eml files, focusing on extracting attachments, analyzing headers, and identifying potential phishing threats. Key features include:

* Attachment Extraction: Retrieves attachments from .eml files, with overwrite control.
* Header Parsing: Extracts To, From, Subject, and Date headers.
  
  ![Headers](/assets/images/favicon/emlripper.png)
  
* Body Analysis: Converts HTML to text, lists URLs, and checks for phishing keywords.
  
  ![Body-Links](/assets/images/favicon/second-emlripper.png)
  
* Phishing Detection: Flags emails with predefined phishing keywords.

  ![Phish_Alert](/assets/images/favicon/phishing-detect.png)

Also trying out the detection of mostly used phishing keywords inside the email body and flagging them as potential (Indicators Of Phishing)IOPs.

```EmlRipper.rb [OPTIONS]```

### Options

* -s, --source PATH: Specifies the directory containing the .eml files from which attachments are to be extracted. If not provided, the default is the current working directory.

* -r, --recursive: Enables recursive search for .eml files within the source directory. This option does not require a value.

* -f, --files FILE: Allows specifying either a single .eml file or a list of .eml files for extracting attachments.

* -d, --destination PATH: Defines the directory where the attachments will be extracted. If not specified, attachments are extracted to the current working directory.

### Default Behavior

If neither --source nor --destination options are specified, the script defaults to using the current working directory (Dir.pwd) for both the source of .eml files and the destination for extracted attachments.

Requires Ruby environment and specific gems. Run ```bundle install``` in the tool directory to install the gems required.
