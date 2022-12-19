CLS

# Load required modules
Import-Module Pode -MaximumVersion 2.99.99 -Force
Import-Module Pode.Web -Force
Import-Module Pode.Queues -Force

# Start Pode Server (4 Threads)
Start-PodeServer -Threads 4 -StatusPageExceptions Show {
	# Attempt to save the Queues/Stack state upon exit
	Register-PodeEvent -Type Terminate -Name 'QueuesStateSaveTerminate' -ScriptBlock {
		Send-PodeMessage -broadcast -from Pode -fromType Pode -expires $((get-date).AddSeconds(15)) -message 'Pode will be Terminating in 15 seconds!'
		Unregister-PodeService -service PodeService1 | Out-Null
		Unregister-PodeService -service PodeService2 | Out-Null
		Unregister-PodeService -service PodeService3 | Out-Null
		Save-PodeState -Path './QueuesState.json' -Include 'queues'
		Save-PodeState -Path './StacksState.json' -Include 'stacks'}
	Register-PodeEvent -Type Restart -Name 'QueuesStateSaveRestart' -ScriptBlock {
		Unregister-PodeService -service PodeService1 | Out-Null
		Unregister-PodeService -service PodeService2 | Out-Null
		Unregister-PodeService -service PodeService3 | Out-Null
		Save-PodeState -Path './QueuesState.json' -Include 'queues'
		Save-PodeState -Path './StacksState.json' -Include 'stacks'}
	Register-PodeEvent -Type Crash -Name 'QueuesStateSaveCrash' -ScriptBlock {
		Unregister-PodeService -service PodeService1 | Out-Null
		Unregister-PodeService -service PodeService2 | Out-Null
		Unregister-PodeService -service PodeService3 | Out-Null
		Save-PodeState -Path './QueuesState.json' -Include 'queues'
		Save-PodeState -Path './StacksState.json' -Include 'stacks'}
	Register-PodeEvent -Type Stop -Name 'QueuesStateSaveStop' -ScriptBlock {
		Unregister-PodeService -service PodeService1 | Out-Null
		Unregister-PodeService -service PodeService2 | Out-Null
		Unregister-PodeService -service PodeService3 | Out-Null
		Save-PodeState -Path './QueuesState.json' -Include 'queues'
		Save-PodeState -Path './StacksState.json' -Include 'stacks'}
	
	# Initilize Messaging Queues
	Initialize-PodeQueues -Force -importSavedUsers './QueuesState.json' | Out-Null
	Register-PodeService -service PodeService1 | Out-Null
	Register-PodeService -service PodeService2 | Out-Null
	Register-PodeService -service PodeService3 | Out-Null

	# Initilize Stacks
	Initialize-PodeStacks -Force | Out-Null
	Register-PodeStack -stack PodeGlobalStack -global | Out-Null
	Register-PodeStack -stack PodepersonalStack -personal | Out-Null

	# Add a simple endpoint
	Add-PodeEndpoint -Address localhost -Port 80 -Protocol Http
	New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

	# Enable sessions and authentication
	Enable-PodeSessionMiddleware -Secret 'schwifty' -Duration (10 * 60) -Extend

	New-PodeAuthScheme -Form | Add-PodeAuth -Name Example -SuccessUseOrigin -ScriptBlock {
		param($username, $password)

		# here you'd check a real user storage, this is just for example
		if ($username -eq 'morty' -and $password -eq 'pickle') {
			$User = @{ID ='M0R7Y302'
					Name = 'Morty'
					Type = 'Human'
					Groups = @('Developer')
					AvatarUrl = '/pode.web/images/icon.png'}
			Register-PodeUser -User 'Morty' -Welcome -Attributes $User | Out-Null
			return @{User = $User}}
		return @{Message = 'Invalid details supplied'}}

	# Set the use of templates
	Use-PodeWebTemplates -Title 'Pode Queues' -Logo '/pode.web/images/icon.png' -Theme Dark

	# Set login page 
	# -BackgroundImage '/images/galaxy.jpg'
	Set-PodeWebLoginPage -Authentication Example

	# Set Homepage top navigation links
	$link1 = New-PodeWebNavLink -Name 'Home' -Url '/' -Icon Home
	$div1 = New-PodeWebNavDivider
	$dd1 = New-PodeWebNavDropdown -Name 'Pode' -Icon Expand -Items @(
		New-PodeWebNavLink -Name 'Pode Project' -NewTab -Url 'https://github.com/Badgerati/Pode'
		New-PodeWebNavLink -Name 'Pode Docs' -NewTab -Url 'https://badgerati.github.io/Pode/'
		New-PodeWebNavDivider
		New-PodeWebNavLink -Name 'Pode.Web Project' -NewTab -Url 'https://github.com/Badgerati/Pode.Web'
		New-PodeWebNavLink -Name 'Pode.Web Docs' -NewTab -Url 'https://badgerati.github.io/Pode.Web/'
	)
	Set-PodeWebNavDefault -Items $link1, $div1, $dd1

	# Set the home page controls (just a simple paragraph) [note: homepage does not require auth in this example]
	$hero = New-PodeWebHero -Title 'Welcome!' -Message 'This is the home page for the queues.ps1 example' -Content @(
		New-PodeWebList -Items @(
			New-PodeWebListItem -Content @(
				New-PodeWebText -Value 'Queues (First In - First Out - FIFO):'
				New-PodeWebList -Items @(
					New-PodeWebListItem -Content @(
						New-PodeWebText -Value 'Pode Registered Services (Runspaces):'
						New-PodeWebList -Items @(
							New-PodeWebListItem -Content @(
								New-PodeWebText -Value 'Control'
								New-PodeWebList -Items @(
									New-PodeWebListItem -Content @(
										New-PodeWebText -Value 'Initialize; Terminate; Reboot; Run; Wait; Flush')))
							New-PodeWebListItem -Content @(
								New-PodeWebText -Value 'Messaging'
								New-PodeWebList -Items @(
									New-PodeWebListItem -Content @(
										New-PodeWebText -Value 'Pode <--> Runspace')
									New-PodeWebListItem -Content @(
										New-PodeWebText -Value 'Runspace <--> Runspace')
									New-PodeWebListItem -Content @(
										New-PodeWebText -Value 'Runspace <--> User')))))
					New-PodeWebListItem -Content @(
						New-PodeWebText -Value 'Pode Registered Users:'
						New-PodeWebList -Items @(
							New-PodeWebListItem -Content @(
								New-PodeWebText -Value 'Messaging'
								New-PodeWebList -Items @(
									New-PodeWebListItem -Content @(
										New-PodeWebText -Value 'Pode <--> User')
									New-PodeWebListItem -Content @(
										New-PodeWebText -Value 'Pode Broadcast --> All Users')
									New-PodeWebListItem -Content @(
										New-PodeWebText -Value 'Runspace <--> User')
									New-PodeWebListItem -Content @(
										New-PodeWebText -Value 'User <--> User')))))))
			New-PodeWebListItem -Content @(
				New-PodeWebText -Value 'Stacks (Last In - First Out - LIFO):'
				New-PodeWebList -Items @(
					New-PodeWebListItem -Content @(
						New-PodeWebText -Value 'Global - Accessable by all Runspaces/Pages')
					New-PodeWebListItem -Content @(
						New-PodeWebText -Value '"Personal" - Accessable only by the Runspace/Page that Created Them'))))
		New-PodeWebRaw -Value '<br><br>'
		New-PodeWebText -Value 'Here you will see examples for the Pode Quesues module.' -InParagraph -Alignment Center
		New-PodeWebParagraph -Alignment Center -Elements @(
			New-PodeWebButton -Name 'Repository' -Icon Link -Url 'https://github.com/Badgerati/Pode.Web' -NewTab
		)
	)
	Set-PodeWebHomePage -NoAuth -Layouts $hero -NoTitle -PassThru

	# Pode Services Table/Modal (output in a new table element) [note: requires auth]
	$serviceCommandModal = New-PodeWebModal -Name "Send Command to Pode Service:" -Icon 'application-import' -Id 'modal_command_svc' `
							-Content @(New-PodeWebSelect -Name 'Send' -Id 'serviceCommand' -Options Initialize, Terminate, Reboot, Run, Wait, Flush
							) -ScriptBlock {
								Show-PodeWebToast -Message "$($WebEvent.Data.Value) Command:  $($WebEvent.Data.Send) - Sent"
								"$($WebEvent.Data.Value) Command:  $($WebEvent.Data.Send) - Sent" | Write-PodeHost
								"Command:  $($WebEvent.Data.Send)" | Write-PodeHost
								foreach ($p in $($WebEvent.Data).GetEnumerator()) {
									"Key:  $($p.Key)  Value:  $($p.Value)" | Write-PodeHost}
#								Send-PodeServiceCommand -Service $WebEvent.Data.Value -Command $WebEvent.Data.Send | Write-PodeHost
								Sync-PodeWebTable -Name 'Pode Services'
								Hide-PodeWebModal}
	$helpCommandModal = New-PodeWebModal -Name 'Help Pode Services Command Help' -Icon 'help' -Content @(
		New-PodeWebText -Value 'HELP!')

	$podeServicesTable = New-PodeWebTable -Name 'Registered Pode Services' -DataColumn 'Pode Service' -AsCard -SimpleFilter -SimpleSort -Click -Paginate `
						-ScriptBlock {
	        					$initializeBtn =	New-PodeWebButton -Name 'Initialize' -Icon 'forwardburger' -IconOnly -ScriptBlock {
												Send-PodeServiceCommand -Service $WebEvent.Data.Value -Command 'Initialize' | Out-Null
												Show-PodeWebToast -Message "$($WebEvent.Data.Value) Initialize command sent"
												Sync-PodeWebTable -Id $ElementData.Parent.ID}
							$flushBtn = New-PodeWebButton -Name 'Flush' -Icon 'pail-remove-outline' -IconOnly -ScriptBlock {
											Send-PodeServiceCommand -Service $WebEvent.Data.Value -Command 'Flush' | Out-Null
											Show-PodeWebToast -Message "$($WebEvent.Data.Value) Flush command sent"
											Sync-PodeWebTable -Id $ElementData.Parent.ID}
							$terminateBtn = New-PodeWebButton -Name 'Terminate' -Icon 'stop-circle-outline' -IconOnly -ScriptBlock {
											Send-PodeServiceCommand -Service $WebEvent.Data.Value -Command 'Terminate' | Out-Null
											Show-PodeWebToast -Message "$($WebEvent.Data.Value) Terminate command sent"
											Sync-PodeWebTable -Id $ElementData.Parent.ID}
							$rebootBtn = New-PodeWebButton -Name 'Reboot' -Icon 'restart' -IconOnly -ScriptBlock {
										Send-PodeServiceCommand -Service $WebEvent.Data.Value -Command 'Reboot' | Out-Null
										Show-PodeWebToast -Message "$($WebEvent.Data.Value) Reboot command sent"
										Sync-PodeWebTable -Id $ElementData.Parent.ID}
							$runBtn = New-PodeWebButton -Name 'Run' -Icon 'play-circle-outline' -IconOnly -ScriptBlock {
										Send-PodeServiceCommand -Service $WebEvent.Data.Value -Command 'Run' | Out-Null
										Show-PodeWebToast -Message "$($WebEvent.Data.Value) Run command sent"
										Sync-PodeWebTable -Id $ElementData.Parent.ID}
							$waitBtn = New-PodeWebButton -Name 'Wait' -Icon 'clock-outline' -IconOnly -ScriptBlock {
										Send-PodeServiceCommand -Service $WebEvent.Data.Value -Command 'Wait' | Out-Null
										Show-PodeWebToast -Message "$($WebEvent.Data.Value) Wait command sent"
										Sync-PodeWebTable -Id $ElementData.Parent.ID}
							$messageBtn = New-PodeWebButton -Name 'Message' -Icon 'email-plus-outline' -IconOnly -ScriptBlock {
										Send-PodeMessage -Service $WebEvent.Data.Value -Message 'Hello' -From 'Pode' -FromType 'External' | Out-Null
										Show-PodeWebToast -Message "$($WebEvent.Data.Value) Message sent"
										Sync-PodeWebTable -Id $ElementData.Parent.ID}
							$filter = "*$($WebEvent.Data.Filter)*"
							$services = Get-PodeService
							if ($services) {
								foreach ($svc in $services.GetEnumerator()) {
									$key = $svc.Key; $val = $svc.Value
									if ($key -inotlike $filter) {continue}
									$btns = @($initializeBtn)
									$btns += $terminateBtn
									$btns += $rebootBtn
									$btns += $runBtn
									$btns += $waitBtn
									$btns += $flushBtn
									$btns += $messageBtn
									[ordered]@{
										'Pode Service'		= $key
										'Commands Queued'	= $val.Item('commands')
										'Inbox Messages'	= $val.Item('inbox')
										'Status'			= $val.Item('status')
										Actions 			= $btns}}}}
					$podeServicesTable | Add-PodeWebTableButton -Name 'Excel' -Icon 'chart-bar' -ScriptBlock {
						$path = Join-Path (Get-PodeServerPath) '.\storage\PodeServices.csv'
						$WebEvent.Data | Export-Csv -Path $path -NoTypeInformation
						Set-PodeResponseAttachment -Path '/download/PodeServices.csv'}

	Add-PodeWebPage -Name 'Pode Services' -Icon 'application' -Layouts $serviceCommandModal, $helpCommandModal, $podeServicesTable `
		-ScriptBlock {
			$serviceName = $WebEvent.Query['value']
			if ([string]::IsNullOrWhiteSpace($serviceName)) {return}
			$services = Get-Service -Name $serviceName | Out-String
			New-PodeWebCard -Name "$($serviceName) Details" -Content @(
				New-PodeWebCodeBlock -Value $services -NoHighlight)
		} -HelpScriptBlock {Show-PodeWebModal -Name 'Help Pode Services Command Help'}


	# Pode Users Table/Modal (output in a new table element) [note: requires auth]
	$podeUsersTable = New-PodeWebTable -Name 'Registered Pode Users' -DataColumn 'Pode User' -AsCard -SimpleFilter -SimpleSort -Click -Paginate `
						-Columns @(
							Initialize-PodeWebTableColumn -Key 'Pode User' -Alignment Left -Width 10
							Initialize-PodeWebTableColumn -Key 'Name' -Alignment Left -Width 10
							Initialize-PodeWebTableColumn -Key 'ID' -Alignment Left -Width 8
							Initialize-PodeWebTableColumn -Key 'Type' -Alignment Left -Width 8
							Initialize-PodeWebTableColumn -Key 'Groups' -Alignment Left -Width 24
							Initialize-PodeWebTableColumn -Key 'AvatarUrl' -Alignment Left -Width 20
							Initialize-PodeWebTableColumn -Key 'Inbox Messages' -Alignment Center -Width 10
							Initialize-PodeWebTableColumn -Key Actions -Alignment Center -Width 10
	   					) -ScriptBlock {
							$messageUserBtn = New-PodeWebButton -Name 'Message' -Icon 'email-plus-outline' -IconOnly -ScriptBlock {
										Send-PodeMessage -User $WebEvent.Data.Value -Message 'Hello' -From $WebEvent.Auth.User.Name -FromType 'User' | Out-Null
										Show-PodeWebToast -Message "$($WebEvent.Data.Value) Message sent"
										Sync-PodeWebTable -Id $ElementData.Parent.ID}
							$filter = "*$($WebEvent.Data.Filter)*"
							$users = Get-PodeUser
							if ($users) {
								foreach ($user in $users.GetEnumerator()) {
									$key = $user.Key; $val = $user.Value
									if ($key -inotlike $filter) {continue}
									$btns = @($messageUserBtn)
									$name = $val.attributes.Name
									$id = $val.attributes.ID
									$type = $val.attributes.Type
									$avatarUrl = $val.attributes.AvatarUrl
									[string]$groups = ''
									foreach ($group in $val.attributes.Groups) {
										if ($groups.Length -eq 0) {[string]$groups = $group
										} Else {[string]$groups = "$($groups) | $($group)"}}
									[ordered]@{
										'Pode User'		= $key
										'Name'			= $name
										'ID'				= $id
										'Type'			= $type
										'Groups'			= $groups
										'AvatarUrl'		= $avatarUrl
										'Inbox Messages'	= $val.Item('inbox')
										Actions 			= $btns}}}}
					$podeUsersTable | Add-PodeWebTableButton -Name 'Excel' -Icon 'chart-bar' -ScriptBlock {
						$path = Join-Path (Get-PodeServerPath) '.\storage\PodeUsers.csv'
						$WebEvent.Data | Export-Csv -Path $path -NoTypeInformation
						Set-PodeResponseAttachment -Path '/download/PodeUsers.csv'}

	Add-PodeWebPage -Name 'Pode Users' -Icon 'account-group-outline' -Layouts $podeUsersTable `
		-ScriptBlock {
			$userName = $WebEvent.Query['value']
			if ([string]::IsNullOrWhiteSpace($userName)) {return}
			$users = Get-Service -Name $userName | Out-String
			New-PodeWebCard -Name "$($userName) Details" -Content @(
				New-PodeWebCodeBlock -Value $users -NoHighlight)
		}

	$messagesTable = New-PodeWebTable -Name 'Messages' -DataColumn 'Pode User' -AsCard -SimpleFilter -SimpleSort -Click -Paginate `
						-Columns @(
							Initialize-PodeWebTableColumn -Key Timestamp -Alignment Left -Width 17%
							Initialize-PodeWebTableColumn -Key From -Alignment Left -Width 13%
							Initialize-PodeWebTableColumn -Key FromType -Alignment Left -Width 13%
							Initialize-PodeWebTableColumn -Key Message -Alignment Left -Width 40%
							Initialize-PodeWebTableColumn -Key Expires -Alignment Left -Width 17%
						) -ScriptBlock {
							$filter = "*$($WebEvent.Data.Filter)*"
							$message = $true
							do	{$message = Get-PodeMessage -User 'Morty'
								if ($message) {
									if ($message.expires) {$expires = $message.expires} else {$expires = 'N/A'}
									[ordered]@{
										Timestamp	= $message.timestamp
										From		= $message.from
										FromType	= $message.fromType
										Message	= $message.message
										Expires	= $expires}} else {$message = $false}
							} while ($message)}
					$messagesTable | Add-PodeWebTableButton -Name 'Excel' -Icon 'chart-bar' -ScriptBlock {
						$path = Join-Path (Get-PodeServerPath) '.\storage\PodeMessages.csv'
						$WebEvent.Data | Export-Csv -Path $path -NoTypeInformation
						Set-PodeResponseAttachment -Path '/download/PodeMessages.csv'}

	Add-PodeWebPage -Name Messages -Icon 'email-multiple-outline' -Layouts $messagesTable -Title 'Messages'
}