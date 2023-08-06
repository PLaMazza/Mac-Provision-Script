#!/bin/zsh
# Created by: Peter La Mazza
# Created: 8/8/22

RegexAssetTag="No"

# Setting Computer Name 
computername=$( osascript -e "set theResponse to display dialog \"Please Enter Desired Computer Name\" default answer \"\" with title \"Configuring Computer\" with icon POSIX file (\"/private/var/CGC/win7.png\" as string) buttons {\"Cancel\", \"Continue\"} default button \"Continue\"" -e "set computername to text returned of (theResponse)" )
sleep .3

# Setting Asset Tag
AssetTag=$( osascript -e "set theResponse to display dialog \"Please Enter the Asset Tag\" default answer \"\" with title \"Configuring Computer\" with icon POSIX file (\"/private/var/CGC/win7.png\" as string) buttons {\"Cancel\", \"Continue\"} default button \"Continue\"" -e "set AssetTag to text returned of (theResponse)" )
sleep .3

# Confirming Asset Tag is a 6 diget character 
until [[ "$RegexAssetTag" == "Yes" ]]; do
    if [[ $AssetTag =~ ^[0-9]{6}$ ]]; then
		echo AssetTag Accepted 
        RegexAssetTag="Yes"
	else
    	AssetTag=$( osascript -e "set theResponse to display dialog \"Previous AssetTag Entered is NOT Valid Please Try Again\" default answer \"XXXXXX\" with title \"Configuring Computer\" with icon POSIX file (\"/private/var/CGC/win7.png\" as string) buttons {\"Cancel\", \"Continue\"} default button \"Continue\"" -e "set AssetTag to text returned of (theResponse)" )
		sleep .3
    fi
done

# Setting Bind
asCommand="Choose from list {\"CaliforniaStudent\", \"CaliforniaEmployee\", \"FloridaStudent\", \"FloridaEmployee\"} with prompt \"Choose the Desired OU\" with title \"Configuring Computer\""
Bind=$( /usr/bin/osascript -e "$asCommand" )
sleep .3

# Setting Department
asCommand="Choose from list {\"Student\", \"Employee\", \"Other\"} with prompt \" Choose a Department Listed Below\" with title \"Configuring Computer\""
Department=$( /usr/bin/osascript -e "$asCommand" )
sleep .3

# Display windo with informatino that was set and confirm settings 
Verify=$( osascript -e "display dialog \"Computer Name: $computername\nAsset Tag: $AssetTag\nBinding OU: $Bind\nDepartment: $Department\" with title \"Confirmation\" buttons {\"Cancel\",\"Confirm\"}")

Confirm=$( echo $Verify | sed 's/.*://')

if [[ $Confirm == "Confirm" ]]; then 
	# Setting All Configurations 
	sudo /usr/local/bin/jamf setComputername -name $computername
	sleep 10
	sudo /usr/local/bin/jamf policy -trigger $Bind
	sudo /usr/local/bin/jamf recon -assetTag $AssetTag -department $Department 
	nvram AssetTag=$AssetTag
    sudo exit 0 | shutdown -r now
else
	echo User Self Canceled 
	exit 1
fi

exit 0
