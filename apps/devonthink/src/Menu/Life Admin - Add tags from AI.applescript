use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

tell application id "DNtp"
	--- Stash the delimiters so we don't mess em up
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ","
	
	set allTags to {"Taxes", "Finance", "Banking", "Paystub", "Income", "Insurance", "Health Insurance", "Dental Insurance", �
		"Vision Insurance", "Life Insurance", "Disability Insurance", "Medical", "School", "Education", "Bills", "Receipts"}
	
	set allTagsString to allTags as string
	
	set aiPrompt to "You are classifying a personal document. Analyze the content and classify it into one or more of these categories: " & allTagsString & ". " & �
		"" & linefeed & linefeed & �
		"Examples of some documents that might show up for a given category:" & linefeed & �
		"- Taxes: Tax returns, W-2s, 1099s, tax documents, IRS correspondence" & linefeed & �
		"- Banking: Bank statements, account documents, wire transfers, deposits" & linefeed & �
		"- Paystub: Paychecks, pay statements, salary information" & linefeed & �
		"- Health insurance: Medical insurance cards, EOBs, health plan documents" & linefeed & �
		"- Dental insurance: Dental plan documents, dental coverage information" & linefeed & �
		"- Vision insurance: Vision plan documents, eye care coverage" & linefeed & �
		"- Life insurance: Life insurance policies, beneficiary forms" & linefeed & �
		"- Disability insurance: Disability coverage documents" & linefeed & �
		"- Medical: Medical records, lab results, prescriptions, doctor visits" & linefeed & �
		"- School: School documents, report cards, transcripts, tuition" & linefeed & �
		"- Bills: Utility bills, credit card statements, invoices to be paid" & linefeed & �
		"- Receipts: Purchase receipts, transaction confirmations" & linefeed & linefeed & �
		linefeed & linefeed & �
		"A document can belong to multiple categories if applicable (e.g., a medical bill could be both Medical and Bills). " & �
		"Reply with ONLY the category names, comma-separated, with no spaces between the comma." & linefeed & linefeed & �
		"**Examples:**" & linefeed & �
		"-'Taxes,Banking'" & linefeed & �
		"-'Medical" & linefeed & �
		"-'Health insurance,Bills'." & �
		linefeed & linefeed & �
		"DO NOT create your own category names, only those that are approved" & linefeed & �
		"If there is no clear category for the document, return an empty string.  Eg, ''"
	
	
	--- Loop through all the records
	set selectedRecords to selected records
	if (count of selectedRecords) > 0 then
		repeat with theRecord in selectedRecords
			set recordName to name of theRecord
			
			log "Processing " & recordName
			
			--- What does the robot think this is?
			set aiResponseTagsString to get chat response for message aiPrompt record theRecord temperature 0
			set aiResponseTagsList to text items of aiResponseTagsString
			
			--- These tags are all nested under "Topic".  Prepend it accordingly
			set topicTagsList to {}
			set existingRecordTags to the tags of theRecord
			repeat with aiResponseTag in aiResponseTagsList
				set nestedTag to "Topic/" & aiResponseTag
				if nestedTag is in existingRecordTags then
					log recordName & " already has " & nestedTag
				else
					set the end of topicTagsList to nestedTag
				end if
			end repeat
			
			set currentRecordTags to the tags of theRecord
			set the tags of theRecord to currentRecordTags & topicTagsList
			
		end repeat
	else
		log "No records selected, giving up on classifying"
		display dialog "No record selected"
	end if
	
	--- Restore the original delimer
	set AppleScript's text item delimiters to oldDelimiters
	
end tell
