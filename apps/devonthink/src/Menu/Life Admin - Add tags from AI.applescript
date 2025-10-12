use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

tell application id "DNtp"
	--- Stash the delimiters so we don't mess em up
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ","
	
	set allTags to {"Taxes", "Finance", "Banking", "Paystub", "Income", "Insurance", "Health Insurance", "Dental Insurance", Â
		"Vision Insurance", "Life Insurance", "Disability Insurance", "Medical", "School", "Education", "Bills", "Receipts"}
	
	set allTagsString to allTags as string
	
	set aiPrompt to "You are classifying a personal document. Analyze the content and classify it into one or more of these categories: " & allTagsString & ". " & Â
		"" & linefeed & linefeed & Â
		"Examples of some documents that might show up for a given category:" & linefeed & Â
		"- Taxes: Tax returns, W-2s, 1099s, tax documents, IRS correspondence" & linefeed & Â
		"- Banking: Bank statements, account documents, wire transfers, deposits" & linefeed & Â
		"- Paystub: Paychecks, pay statements, salary information" & linefeed & Â
		"- Health insurance: Medical insurance cards, EOBs, health plan documents" & linefeed & Â
		"- Dental insurance: Dental plan documents, dental coverage information" & linefeed & Â
		"- Vision insurance: Vision plan documents, eye care coverage" & linefeed & Â
		"- Life insurance: Life insurance policies, beneficiary forms" & linefeed & Â
		"- Disability insurance: Disability coverage documents" & linefeed & Â
		"- Medical: Medical records, lab results, prescriptions, doctor visits" & linefeed & Â
		"- School: School documents, report cards, transcripts, tuition" & linefeed & Â
		"- Bills: Utility bills, credit card statements, invoices to be paid" & linefeed & Â
		"- Receipts: Purchase receipts, transaction confirmations" & linefeed & linefeed & Â
		linefeed & linefeed & Â
		"A document can belong to multiple categories if applicable (e.g., a medical bill could be both Medical and Bills). " & Â
		"Reply with ONLY the category names, comma-separated, with no spaces between the comma." & linefeed & linefeed & Â
		"**Examples:**" & linefeed & Â
		"-'Taxes,Banking'" & linefeed & Â
		"-'Medical" & linefeed & Â
		"-'Health insurance,Bills'." & Â
		linefeed & linefeed & Â
		"DO NOT create your own category names, only those that are approved" & linefeed & Â
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
