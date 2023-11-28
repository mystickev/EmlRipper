# EmlRipper
EmlRipper is a Ruby script for parsing .eml files, focusing on extracting attachments, analyzing headers, and identifying potential phishing threats. Key features include:

* Attachment Extraction: Retrieves attachments from .eml files, with overwrite control.
* Header Parsing: Extracts To, From, Subject, and Date headers.
* Body Analysis: Converts HTML to text, lists URLs, and checks for phishing keywords.
* Phishing Detection: Flags emails with predefined phishing keywords.

Also trying out the detection of mostly used phishing keywords inside the email body and flagging them as potential (indicators of phishing)IOPs

Requires Ruby environment and specific gems. Run ```bundle install``` in the tool directory to install the gems required.
