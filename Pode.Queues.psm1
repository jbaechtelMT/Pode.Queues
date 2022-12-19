	<#
	.Synopsis
		Adds Queues (First In - First Out - FIFO) support for Registered Service(s) (Runspace) & Registered User(s) to Pode.
			*	Pode Registered Services (Runspaces):
				*	Control
					*	Initialize; Terminate; Reboot; Run; Wait; Flush
				*	Messaging
					*	Pode <--> Runspace
					*	Runspace <--> Runspace
					*	Runspace <--> User
			*	Pode Registered Users:
				*	Messaging
					*	Pode <--> User
					*	Pode Broadcast --> All Users
					*	Runspace <--> User
					*	Runspace Broadcast --> All Users
					*	User <--> User
					*	User Broadcast --> All Users

		Adds Stack (Last In - First Out - LIFO) support for both Global & Personal Stacks to Pode.
			*	Global - Accessable by all Runspaces/Pages
			*	"Personal" - Accessable only by the Runspace/Page that Created Them

	.NOTES     
	    Name: 		Pode.Queues  
	    Author: 		Joe Baechtel   
	    DateCreated: 	18December2022
	#>

	###########################################################
	#                 Version and History                     #
	###########################################################

	$PodeQueuesModule_Version = "1.2022.12.18"									     	# Current Module Version Number

	#region Version History
	<#

	Version 1.2022.12.18	Joe Baechtel - Initial coding & release.

	#>
	#endregion Version History

	#region Queue Functions
		#region Initialize-PodeQueues
		<#
		.Synopsis
			Initializes Pode Queues.

		.NOTES     
		    Name:			Initialize-PodeQueues
		    Author:		Joe Baechtel

		.INPUT PARMS
			force				Optional		Forces "empty" Registered User/Service queuees

			importSavedUsers		Optional		Loads saved Users from specified file path.

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$results = Initialize-PodeQueues -force -importSavedUsers './QueuesState.json'
		#>
		function Initialize-PodeQueues {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[switch]$force,											# Force Initialization if Exists
					[Parameter(Mandatory=$false)]
						[string]$importSavedUsers=$false)								# Import	Saved Users from File (Path)	

			process	{try		{if (Get-Module -Name "Pode") {
								if (!(Get-PodeState -Name 'queues') -and !$force) {return $true}	# Already Initialized?
							} else {if (!$global:queues -and !$force) {return $true}}
							$events = Get-Event										# Get Events
							if (Test-PodeIsWindows) {								# Windows?
								foreach ($event in $events) {
									if (($event.SourceIdentifier).Substring(0,9) -eq "PodeUser_") {
										Remove-Event -SourceIdentifier $event.SourceIdentifier -Confirm:$false
									} elseif (($event.SourceIdentifier).Substring(0,12) -eq "PodeService_") {
										Remove-Event -SourceIdentifier $event.SourceIdentifier -Confirm:$false}}}
							if (Get-Module -Name "Pode") {$local:queues = [ordered]@{}		# Build Queues
								$local:queues.Add('services',[ordered]@{})				# Services Queue
								$local:queues.Add('users',[ordered]@{})					# Users Queue
								if ($importSavedUsers) {								# Import Saved User Messages?
									if (Test-Path -Path $importSavedUsers ) {			# Yes - Does File Exist?
										$local:savedMessages = Get-Content $importSavedUsers | ConvertFrom-Json
										foreach ($user in $savedMessages.queues.Value.users.psobject.properties.name) {
											$local:queues.Item('users').Add($user,[ordered]@{})
											$local:queues.Item('users').Item($user).Add('inbox',(New-Object System.Collections.Queue))	# Set-up Inbox Queue
											foreach ($message in $savedMessages.queues.Value.users."$($user)".inbox.SyncRoot) {
												$local:queues.Item('users').Item($user).Item('inbox').Enqueue($local:message)}	# Queue Message to Inbox
											$local:queues.Item('users').Item($user).Add('status',$savedMessages.queues.Value.users."$($user)".status)	# Get Status of User
											if ($savedMessages.queues.Value.users."$($user)".attributes) {	# Attributes?
												$local:queues.Item('users').Item($user).Add('attributes',$savedMessages.queues.Value.users."$($user)".attributes)}}}}
								Lock-PodeObject -ScriptBlock {						# Lock While Initializing Queues
									Set-PodeState -Name 'queues' -Scope Global $local:queues}	# Create Queues
							} else {$global:queues = [ordered]@{}						# Build Queues
								$global:queues.Add('services',[ordered]@{})				# Services Queue
								$global:queues.Add('users',[ordered]@{})				# Users Queue
								if ($importSavedUsers) {								# Import Saved User Messages?
									if (Test-Path -Path $importSavedUsers ) {			# Yes - Does File Exist?
										$local:savedMessages = Get-Content $importSavedUsers | ConvertFrom-Json
										foreach ($user in $savedMessages.queues.Value.users.psobject.properties.name) {
											$global:queues.Item('users').Add($user,[ordered]@{})
											$global:queues.Item('users').Item($user).Add('inbox',(New-Object System.Collections.Queue))	# Set-up Inbox Queue
											foreach ($message in $savedMessages.queues.Value.users."$($user)".inbox.SyncRoot) {
												$global:queues.Item('users').Item($user).Item('inbox').Enqueue($local:message)}	# Queue Message to Inbox
											$global:queues.Item('users').Item($user).Add('status',$savedMessages.queues.Value.users."$($user)".status)	# Get Status of User
											if ($savedMessages.queues.Value.users."$($user)".attributes) {	# Attributes?
												$global:queues.Item('users').Item($user).Add('attributes',$savedMessages.queues.Value.users."$($user)".attributes)}}}}}
							return $true}
					catch	{return $false}}
		}
		#endregion Initialize-PodeQueues

		#region Close-PodeQueues
		<#
		.Synopsis
			Forces Destruction of Pode Queues.

		.NOTES     
		    Name:			Close-PodeQueues
		    Author:		Joe Baechtel

		.INPUT PARMS
			force				REQUIRED		Forces Destruction of Pode Queues

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$results = Close-PodeQueues -force
		#>
		function Close-PodeQueues {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[switch]$force)											# Force Destruction of Pode Stacks

			process	{try		{if (Get-Module -Name "Pode") {
								if (!(Get-PodeState -Name 'queues')) {return $true}		# Queues Don't Exist?
								Lock-PodeObject -ScriptBlock {						# Lock While Destroying Queues
									Remove-PodeState -Name 'queues'					# Destroy Queues
							} else {if (!$global:queues) {return $true}					# Queues Don't Exist?
								Remove-Variable -Name queues -Scope Global}				# Destroy Queuess
							return $true}}
					catch	{return $false}}
		}
		#endregion Close-PodeQueues

		#region Clear-PodeMessages
		<#
		.Synopsis
			Clears (purges) a Registered User/Service (runspace) Message(s).

		.NOTES     
		    Name:			Clear-PodeMessages
		    Author:		Joe Baechtel

		.INPUT PARMS
			user					Optional		User Name for Message(s)

			service				Optional		Service Name for Message(s)

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Clear-PodeMessages -user Joe
		#>
		function Clear-PodeMessages {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[string]$user,												# User Name to Clear Messages For
					[Parameter(Mandatory=$false)]
						[string]$service)											# Service Name to Clear Messages For

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}

			process	{try		{Lock-PodeObject -ScriptBlock {							# Lock While Updating Queues
								$queues = (Get-PodeState -Name 'queues')				# Get Current Queues
								if ($user) {$users = $queues.Item('users')				# Type:  User?  Yes - Get Registered Users Hashtable
								} else {$services = $queues.Item('services')}			# No - Type Service - Get Registered Services Hashtable
								if ($user) {$users.Item($user).Item('inbox').Clear()		# Clear Messages From Inbox
									$queues.Item('users') = $users					# Save Empty Inbox
								} else {$services.Item($service).Item('inbox').Clear()		# Clear Messages From Inbox
									$queues.Item('services') = $services}				# Save Empty Inbox
								Set-PodeState -Name 'queues' -Scope Global -Value $queues}
							if (Test-PodeIsWindows) {								# Windows?
								if ($user) {$event = Get-PodeWindowsEvent -SourceIdentifier $("PodeUser_" + $user) -ErrorAction SilentlyContinue
									if ($event) {Remove-PodeWindowsEvent -SourceIdentifier $("PodeUser_" + $user) -Confirm:$false}
								} else {$event = Get-PodeWindowsEvent -SourceIdentifier $("PodeService_" + $service) -ErrorAction SilentlyContinue
									if ($event) {Remove-PodeWindowsEvent -SourceIdentifier $("PodeService_" + $service) -Confirm:$false}}}
							return $true}
					catch	{return $false}}
		}
		#endregion Clear-PodeMessages

		#region Get-PodeMessage
		<#
		.Synopsis
			Returns (gets) a Registered User/Service (runspace) Message(s).

		.NOTES     
		    Name:			Get-PodeMessage
		    Author:		Joe Baechtel

		.INPUT PARMS
			user					Optional		User Name for Message(s)

			service				Optional		Service Name for Message(s)

			peek					Optional		Peek:  Leave Message(s) on Stack - Just Looking

		.RETURNS
			Message(s)

		.EXAMPLES
			$message = Get-PodeMessage -user Joe -peek
		#>
		function Get-PodeMessage {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[string]$user,												# User Name for Message Receive
					[Parameter(Mandatory=$false)]
						[string]$service,											# Service Name for Message Receive
					[Parameter(Mandatory=$false)]
						[switch]$peek)												# Peek:  Leave Message on Stack - Just Looking

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if ($user) {if (Get-Module -Name "Pode") {									# Type:  User?
											$users = ((Get-PodeState -Name 'queues').Item('users'))		# Get Resistered Users Hashtable
										} else {$users = $global:queues.Item('users')}					# Get Resistered Users Hashtable
								if ($peek) {[PScustomObject]$message = $users.Item($user).Item('inbox').Peek()	# Just Looking?
								} else {[PScustomObject]$message = $users.Item($user).Item('inbox').Dequeue()}	# No - Remove Message
									if (Get-Module -Name "Pode") {
										Lock-PodeObject -ScriptBlock {								# Lock While Updating Queues
											$queues = Get-PodeState -Name 'queues'
											$queues.Item('users') = $users							# Update User's Messages
											Set-PodeState -Name 'queues' -Scope Global -Value $queues}		# Update State Variable
									} else {$global:queues.Item('users') = $users}						# Update User's Messages
									if (Test-PodeIsWindows) {										# Windows?
										if ($users.Item($user).Item('inbox').Count -le 0) {				# More Messages?
											$event = Get-Event -SourceIdentifier $("PodeUser_" + $user)
											if ($event) {Remove-Event -SourceIdentifier $("PodeUser_" + $user) -Confirm:$false}}}
							} else {if (Get-Module -Name "Pode") {										# No - Type Service
										$services = ((Get-PodeState -Name 'queues').Item('services'))		# Get Resistered Services Hashtable
									} else {$services = $global:queues.Item('services')}					# Get Resistered Services Hashtable
								if ($peek) {$message = $services.Item($service).Item('inbox').Peek()			# Just Looking?
								} else {$message = $services.Item($service).Item('inbox').Dequeue()
									if (Get-Module -Name "Pode") {
										Lock-PodeObject -ScriptBlock {								# Lock While Updating Queues
											$queues = Get-PodeState -Name 'queues'
											$queues.Item('services') = $services						# Update Service's Messages
											Set-PodeState -Name 'queues' -Scope Global -Value $queues}		# Update State Variable
									} else {$global:queues.Item('services') = $services}}					# Update Service's Messages
								if (Test-PodeIsWindows) {											# Windows?
									if ($services.Item($service).Item('inbox').Count -gt 0) {				# More Messages?
										try		{$event = Get-Event -SourceIdentifier $("PodeService_" + $service) -ErrorAction SilentlyContinue}
										catch	{$event = $false}
										if ($event) {Remove-Event -SourceIdentifier $("PodeService_" + $service) -Confirm:$false}}}}
							if ($message.expires) {$now = (Get-Date).DateTime				# Message Has Expired?
								if (($message.expires).DateTime -le $now) {$message = $false}}	# Yes - Show it Has
							return [PScustomObject]$message}							# Return Message if it Exists
					catch	{return $false}}
		}
		#endregion Get-PodeMessage

		#region Get-PodeMessageCount
		<#
		.Synopsis
			Returns (gets) a Count of Registered User/Service (runspace) Message(s) .

		.NOTES     
		    Name:			Get-PodeMessageCount
		    Author:		Joe Baechtel

		.INPUT PARMS
			user					Optional		User Name for Message(s)

			service				Optional		Service Name for Message(s)

		.RETURNS
			Message(s)

		.EXAMPLES
			$count = Get-PodeMessageCount -user Joe
		#>
		function Get-PodeMessageCount {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[string]$user,												# User Name for Message Receive
					[Parameter(Mandatory=$false)]
						[string]$service)											# Service Name for Message Receive

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}

			process	{try		{Lock-PodeObject -ScriptBlock {							# Lock While Updating Queues
								$queues = (Get-PodeState -Name 'queues')}				# Get Current Queues
							if ($user) {$users = $queues.Item('users')					# Type:  User?  Yes - Get Registered Users Hashtable
								return $users.Item($user).Item('inbox').Count			# Return Inbox Message Count
							} else {$services = $queues.Item('services')					# No - Type Service - Get Registered Services Hashtable
								return $services.Item($service).Item('inbox').Count}}		# Return Inbox Message Count
					catch	{return $false}}
		}
		#endregion Get-PodeMessageCount

		#region Get-PodeService
		<#
		.Synopsis
			Returns (gets) a Registered Service (runspace) object.

		.NOTES     
		    Name:			Get-PodeService
		    Author:		Joe Baechtel

		.INPUT PARMS
			service				Optional		Service Name to Get.  If not supplied, returns all Registered Services.

		.RETURNS
			Object							Service

		.EXAMPLES
			$service = Get-PodeService -service Service1
		#>
		function Get-PodeService{
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[string]$service)											# Service Name to Get

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$services = ((Get-PodeState -Name 'queues').Item('services'))	# Get Resistered Services Hashtable
							} else {$services = $global:queues.Item('services')}			# Get Resistered Services Hashtable
							$hashtable = [ordered]@{}
							if ($service) {if ($services.Item($service)) {				# Process Single Registered Service
											$hashtable.Add('commands',$services.Item($service).Item('commands').Count)
											$hashtable.Add('inbox',$services.Item($service).Item('inbox').Count)
											$hashtable.Add('status',$services.Item($service).Item('status'))
											return [ordered]@{"$($service)"=$hashtable}
										} else {return $false}
							} else {foreach ($kvp in $services.GetEnumerator()) {$temp = [ordered]@{}	# Process All Registered Services
										$service = $kvp.Key; $val = $kvp.Value			# Get Registered Service
										$temp.Add('commands',$services.Item($service).Item('commands').Count)
										$temp.Add('inbox',$services.Item($service).Item('inbox').Count)
										$temp.Add('status',$services.Item($service).Item('status'))
										$hashtable.Add("$($service)",$temp)}
								if ($hashtable.Count -ge 1) {return $hashtable} else {return $false}}}
					catch	{return $false}}
		}
		#endregion Get-PodeService

		#region Get-PodeServiceCommand
		<#
		.Synopsis
			Returns (gets) a Registered Service (runspace) Command.

		.NOTES     
		    Name:			Get-PodeServiceCommand
		    Author:		Joe Baechtel

		.INPUT PARMS
			service				REQUIRED		Service Name for Queue Command

			peek					Optional		Peek:  Leave Command on Stack - Just Looking

		.RETURNS
			Command							Service Command

		.EXAMPLES
			$command = Get-PodeServiceCommand -service Service1 -peek
		#>
		function Get-PodeServiceCommand {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$service,											# Service Name for Queue Command
					[Parameter(Mandatory=$false)]
						[switch]$peek)												# Peek:  Leave Command on Stack - Just Looking

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$services = ((Get-PodeState -Name 'queues').Item('services'))	# Get Resistered Services Hashtable
							} else {$services = $global:queues.Item('services')}			# Get Resistered Services Hashtable
							if ($peek) {$command = $services.Item($service).Item('commands').Peek()	# Just Looking?
							} else {$command = $services.Item($service).Item('commands').Dequeue()}
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Queues
									$queues = Get-PodeState -Name 'queues'
									$queues.Item('services') = $services				# Update Service Queue
									Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
							} else {$global:queues.Item('services') = $services}			# Update Service Queue
							return $command}										# Return Command if it Exists
					catch	{return $false}}
		}
		#endregion Get-PodeServiceCommand

		#region Get-PodeServiceCommandsPendingCount
		<#
		.Synopsis
			Returns (gets) a Count of Registered Service (runspace) Commands pending.

		.NOTES     
		    Name:			Get-PodeServiceCommandsPendingCount
		    Author:		Joe Baechtel

		.INPUT PARMS
			service				REQUIRED		Service Name for Queue Commands

		.RETURNS
			Command							Service Command

		.EXAMPLES
			$count = Get-PodeServiceCommandsPendingCount -service Service1
		#>
		function Get-PodeServiceCommandsPendingCount {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$service)											# Service Name for Pending Commands Count

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}

			process	{try		{if (Get-Module -Name "Pode") {
								$services = ((Get-PodeState -Name 'queues').Item('services'))	# Get Resistered Services Hashtable
							} else {$services = $global:queues.Item('services')}			# Get Resistered Services Hashtable
							return $services.Item($service).Item('commands').Count}		# Return Pending Commands Count
					catch	{return $false}}
		}
		#endregion Get-PodeServiceCommandsPendingCount

		#region Get-PodeServiceStatus
		<#
		.Synopsis
			Returns (gets) a Registered Service (runspace) Status.

		.NOTES     
		    Name:			Get-PodeServiceStatus
		    Author:		Joe Baechtel

		.INPUT PARMS
			service				REQUIRED		Service Name for Queue Command

		.RETURNS
			Status							Service Status

		.EXAMPLES
			$status = Get-PodeServiceStatus -service Service1
		#>
		function Get-PodeServiceStatus {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$service)											# Service Name for Queue Command

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$services = ((Get-PodeState -Name 'queues').Item('services'))	# Get Resistered Services Hashtable
							} else {$services = $global:queues.Item('services')}			# Get Resistered Services Hashtable
							$status = $services.Item($service).Item('status')				# Get Status
							return $status}										# Return Status
					catch	{return $false}}
		}
		#endregion Get-PodeServiceStatus

		#region Get-PodeUser
		<#
		.Synopsis
			Returns (gets) a Registered User object.

		.NOTES     
		    Name:			Get-PodeUser
		    Author:		Joe Baechtel

		.INPUT PARMS
			user					REQUIRED		User Name to Get

		.RETURNS
			Object							User

		.EXAMPLES
			$user = Get-PodeUser -user Joe
		#>
		function Get-PodeUser{
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[string]$user)												# User Name to Get

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$users = ((Get-PodeState -Name 'queues').Item('users'))	# Get Resistered Users Hashtable
							} else {$users = $global:queues.Item('users')}				# Get Resistered Users Hashtable
							$hashtable = [ordered]@{}
							if ($user) {if ($users.Item($user)) {						# Process Single Registered User
											$hashtable.Add('inbox',$users.Item($user).Item('inbox').Count)
											if ($users.Item($user).Item('attributes')) {
												$hashtable.Add('attributes',$users.Item($user).Item('attributes'))}
											return [ordered]@{"$($user)"=$hashtable}
										} else {return $false}
							} else {foreach ($kvp in $users.GetEnumerator()) {$temp = [ordered]@{}	# Process All Registered Users
										$user = $kvp.Key; $val = $kvp.Value			# Get Registered User
										$temp.Add('inbox',$users.Item($user).Item('inbox').Count)
										if ($users.Item($user).Item('attributes')) {
											$temp.Add('attributes',$users.Item($user).Item('attributes'))}
										$hashtable.Add("$($user)",$temp)}
								if ($hashtable.Count -ge 1) {return $hashtable} else {return $false}}}
					catch	{return $false}}
		}
		#endregion Get-PodeUser

		#region Get-PodeWindowsEvent
		<#
		.Synopsis
			Returns (gets) a Windows Event object.

		.NOTES     
		    Name: 		Get-PodeWindowsEvent
		    Author: 		Joe Baechtel

		.INPUT PARMS
			sourceIdentifier		Required		Specifies source identifiers for which this cmdlet gets events

			eventIdentifier		Optional		Specifies the event identifiers for which this cmdlet gets events

		.RETURNS
			Event Object						From Get-Event

		.EXAMPLES
			$event = Get-PodeWindowsEvent -sourceIdentifier $Source -Force
		#>
		function Get-PodeWindowsEvent {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[string]$sourceIdentifier,									# Specifies source identifiers for which this cmdlet gets events.
					[Parameter(Mandatory=$false)]
						[int32]$eventIdentifier)										# Specifies the event identifiers for which this cmdlet gets events.

			process	{try		{if (Test-PodeIsWindows) {$arguments = [ordered]@{}			# Windows?  Yes - Arguments Hashtable
								if ($sourceIdentifier) {$arguments.Add('SourceIdentifier',$sourceIdentifier)}
								if ($eventIdentifier) {$arguments.Add('EventIdentifier',$eventIdentifier)}
								$result = Get-Event @Arguments $arguments				# Get-Event
								return $result
							} else {return $false}}
					catch	{return $false}}
		}
		#endregion Get-PodeWindowsEvent

		#region Get-PodeWindowsEventSubscriber
		<#
		.Synopsis
			Returns (gets) a Windows Event Subscriber object.

		.NOTES     
		    Name: 		Get-PodeWindowsEventSubscriber
		    Author: 		Joe Baechtel

		.INPUT PARMS
			sourceIdentifier		Required		Specifies source identifiers for which this cmdlet gets events

			eventIdentifier		Optional		Specifies the event identifiers for which this cmdlet gets events

			force				Optional		Force

		.RETURNS
			Subscriber Object					From Get-EventSubscriber

		.EXAMPLES
			$subscriber = Get-PodeWindowsEventSubscriber -sourceIdentifier $Source -Force
		#>
		function Get-PodeWindowsEventSubscriber {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[string]$sourceIdentifier,									# Specifies source identifiers for which this cmdlet gets events
					[Parameter(Mandatory=$false)]
						[int32]$eventIdentifier,										# Specifies the event identifiers for which this cmdlet gets events
					[Parameter(Mandatory=$false)]
						[switch]$force=$false)										# Force

			process	{try		{if (Test-PodeIsWindows) {$arguments = [ordered]@{}			# Windows?  Yes - Arguments Hashtable
								if ($sourceIdentifier) {$arguments.Add('SourceIdentifier',$sourceIdentifier)}
								if ($eventIdentifier) {$arguments.Add('EventIdentifier',$eventIdentifier)}
								if ($force) {$arguments.Add('Force',$force)}
								$result = Get-EventSubscriber @Arguments $arguments		# Get-EventSubscriber
								return $result
							} else {return $false}}
					catch	{return $false}}
		}
		#endregion Get-PodeWindowsEventSubscriber

		#region New-PodeWindowsEvent
		<#
		.Synopsis
			Raises (creates) a Windows Event.

		.NOTES     
		    Name:			New-PodeWindowsEvent
		    Author:		Joe Baechtel

		.INPUT PARMS
			sourceIdentifier		Required		Specifies a name for the new event

			sender				Optional		Specifies the object that raises the event. The default is the PowerShell engine.

			eventArguments			Optional		Specifies an object that contains options for the event

			messageData			Optional		Specifies additional data associated with the event

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result =  New-PodeWindowsEvent -sourceIdentifier $Source -sender Service1
		#>
		function New-PodeWindowsEvent {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$sourceIdentifier,									# Specifies a name for the new event.
					[Parameter(Mandatory=$false)]
						[PSObject]$sender,											# Specifies the object that raises the event. The default is the PowerShell engine.
					[Parameter(Mandatory=$false)]
						[PSObject]$eventArguments,									# Specifies an object that contains options for the event.
					[Parameter(Mandatory=$false)]
						[PSObject]$messageData)										# Specifies additional data associated with the event.

			process	{try		{if (Test-PodeIsWindows) {$arguments = [ordered]@{}			# Windows?  Yes - Arguments Hashtable
								if ($sourceIdentifier) {$arguments.Add('SourceIdentifier',$sourceIdentifier)}
								if ($sender) {$arguments.Add('Sender',$sender)}
								if ($eventArguments) {$arguments.Add('EventArguments',$eventArguments)}
								if ($messageData) {$arguments.Add('MessageData',$messageData)}
								$result = New-Event @Arguments $arguments				# New-Event
								return $result
							} else {return $false}}
					catch	{return $false}}
		}
		#endregion New-PodeWindowsEvent

		#region Register-PodeEventHeartbeat
		<#
		.Synopsis
			Registers a Heartbeat (event) timer.

		.NOTES     
		    Name: 		Register-PodeEventHeartbeat
		    Author: 		Joe Baechtel

		.INPUT PARMS
			heartbeatName			Optional		Heartbeat Name for Heartbeat Variable (default = heartbeat)

			scope				Optional		Scope for Heartbeat Variable (default = Script)

			interval				Optional		Heartbeat Interval (ms) (default = 1000)

			autoReset				Optional		Auto Reset After Heartbeat Interval Expiration (default - $true)

			autoStartHeartbeat		Optional		Auto Start/Enable Heartbeat Timer Now

			scriptBlock			REQUIRED		ScriptBlock to Run When Heartbeat Interval Expires

		.RETURNS
			Hashtable							Heartbeat Event timer object

		.EXAMPLES
			$heartbeatObject = Register-PodeEventHeartbeat -scope Global -scriptBlock {Do Something Every 1000 ms Here}
		#>
		function Register-PodeEventHeartbeat {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)][Alias("heartbeat","name","variable")]
						[string]$heartbeatName='heartbeat',							# Heartbeat Name for Heartbeat Variable (default = heartbeat)
					[Parameter(Mandatory=$false)][ValidateSet("Script","Global")]
						[string]$scope='script',										# Scope for Heartbeat Variable (default = Script)
					[Parameter(Mandatory=$false)]
						[int]$interval=1000,										# Heartbeat Interval (ms) (default = 1000)
					[Parameter(Mandatory=$false)]
						[switch]$autoReset=$true,									# Auto Reset After Heartbeat Interval Expiration (default - $true)
					[Parameter(Mandatory=$false)][Alias("enable")]
						[switch]$autoStartHeartbeat=$true,								# Auto Start/Enable Heartbeat Timer Now
					[Parameter(Mandatory=$true)]
						[scriptblock]$scriptBlock)									# ScriptBlock to Run When Heartbeat Interval Expires

			begin	{If (!$autoReset) {$autoReset = $false}
					$hashtable = [ordered]@{}}

			process	{$timer = $(New-Object System.Timers.Timer)							# Initialize Heartbeat Timer
					$hashtable.Add('Heartbeat Name',$heartbeatName)
					$hashtable.Add('Scope',$scope)
					$timer.Interval = $interval
					$hashtable.Add('Interval',"$($interval) (ms)")
					If ($autoReset) {$timer.AutoReset = $true; $hashtable.Add('AutoReset',$true)
					} Else {$timer.AutoReset = $false; $hashtable.Add('AutoReset',$false)}
					If ($autoStartHeartbeat) {$timer.Enabled = $true; $hashtable.Add('Enabled',$true)
					} Else {$hashtable.Add('Enabled',$false)}
					$event = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action $scriptBlock
					$hashtable.Add('Event',$event)
					If (Test-Path variable:$('Global'):$('heartbeat')) {Set-Variable -Name $heartbeatName -Scope $scope -Value $timer
					} Else {New-Variable -Name $heartbeatName -Scope $scope -Value $timer}}

			end		{return $hashtable}
		}
		#endregion Register-PodeEventHeartbeat

		#region Register-PodeService
		<#
		.Synopsis
			Registers a Service (runspace).

		.NOTES     
		    Name: 		Register-PodeService
		    Author: 		Joe Baechtel

		.INPUT PARMS
			service				REQUIRED		Service Name to Resister

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Register-PodeService -service Service1
		#>
		function Register-PodeService {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$service)											# Service Name to Resister

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$services = ((Get-PodeState -Name 'queues').Item('services'))	# Get Resistered Services Hashtable
							} else {$services = $global:queues.Item('services')}			# Get Resistered Services Hashtable
							$newService = [ordered]@{}
							$newService.Add('commands',(New-Object System.Collections.Queue))	# Set-up Commands Queue
							$newService.'commands'.Enqueue('Initialize')
							$newService.Add('inbox',(New-Object System.Collections.Queue))	# Set-up Inbox Queue
							$newService.Add('status',[string]'Registered')				# Set-up Status Flag
							if ($services.Item($service)) {$services.Item($service) = $newService	# Is Service Already Registered?  Yes- Reset It
							} else {$services.Add($service,$newService)}					# No - Create It
							if (Test-PodeIsWindows) {								# Windows?
								$event = Get-Event -SourceIdentifier $("PodeService_" + $service) -ErrorAction SilentlyContinue
								if (!$event) {New-Event -SourceIdentifier $("PodeService_" + $service) -Sender Pode -MessageData "New Command"}}
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Queues
									$queues = Get-PodeState -Name 'queues'
									$queues.Item('services') = $services				# Register New Service
									Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
							} else {$global:queues.Item('services') = $services}			# Register New Service
							return $true}
					catch	{return $false}}
		}
		#endregion Register-PodeService

		#region Register-PodeUser
		<#
		.Synopsis
			Registers a User.

		.NOTES     
		    Name:			Register-PodeUser
		    Author:		Joe Baechtel

		.INPUT PARMS
			user					REQUIRED		User Name to Resister

			attributes			Optional		User Attributes

			welcome				Optional		Send "Welecome" message to User

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$attributes = @{
						ID ='M0R7Y302'
						Name = 'Morty'
						Type = 'Human'
						Groups = @('Developer')
						AvatarUrl = '/pode.web/images/icon.png'}
			$result = Register-PodeUse -user Joe -attributes $attributes -welcome
		#>
		function Register-PodeUser {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$user,												# User Name to Resister
					[Parameter(Mandatory=$false)]
						[hashtable]$attributes,										# User's Attributes
					[Parameter(Mandatory=$false)]	
						[switch]$welcome=$true)										# Send Welcome Message

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$users = ((Get-PodeState -Name 'queues').Item('users'))	# Get Resistered Users Hashtable
							} else {$users = $global:queues.Item('users')}				# Get Resistered Users Hashtable
							if ($users.Item($user)) {$newUser = $users.Item($user)			# Is User Already Registered?  Yes - Get User
								if ($welcome) {$newMessage = [ordered]@{}
									$timestamp = $(Get-Date -Format "yyyy/dd/MM HH:mm:ss.fff")
									$newMessage.Add('timestamp',$timestamp)				# Timestamp
									$newMessage.Add('message','Welcome!')				# Welcome Message
									$newMessage.Add('from','Pode')					# Message Sent From Pode
									$newMessage.Add('fromType','Pode')					# Message From Type (User; Service; Pode; External)
									$newUser.'inbox'.Enqueue($newMessage)}				# Queue Welcome Message
								$newUser.Item('status') = [string]'Registered'			# Update Status Flag
								if ($attributes) {									# User's Attributes?
									if (!$newUser.Item('attributes')) {$newUser.Add('attributes',$attributes)
									} else {$newUser.Item('attributes') = $attributes}}
								$users.Item($user) = $newUser							# Update Existing User
							} else {$newUser = [ordered]@{}							# No - Create New User
								$newUser.Add('inbox',(New-Object System.Collections.Queue))	# Set-up Inbox Queue
								if ($welcome) {$newMessage = [ordered]@{}
									$timestamp = $(Get-Date -Format "yyyy/dd/MM HH:mm:ss.fff")
									$newMessage.Add('timestamp',$timestamp)				# Timestamp
									$newMessage.Add('message','Welcome!')				# Welcome Message
									$newMessage.Add('from','Pode')					# Message Sent From Pode
									$newMessage.Add('fromType','Pode')					# Message From Type (User; Service; Pode; External)
									$newUser.'inbox'.Enqueue($newMessage)}				# Queue Welcome Message
								$newUser.Add('status',[string]'Registered')				# Set-up Status Flag
								if ($attributes) {$newUser.Add('attributes',$attributes)}	# User's Attributes?
								$users.Add($user,$newUser)}							# Add New User
							if (Test-PodeIsWindows) {								# Windows?
								$event = Get-Event -SourceIdentifier $("PodeUser_" + $user) -ErrorAction SilentlyContinue
								if (!$event) {New-Event -SourceIdentifier $("PodeUser_" + $user) -Sender Pode -MessageData "New Message"}}
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Queues
									$queues = Get-PodeState -Name 'queues'
									$queues.Item('users') = $users					# Register New User
									Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
							} else {$global:queues.Item('users') = $users}				# Register New User
							return $true}
					catch	{return $false}}
		}
		#endregion Register-PodeUser

		#region Register-PodeWindowsEvent
		<#
		.Synopsis
			Registers a registered Windows Event subscription.

		.NOTES     
		    Name: 		Register-PodeWindowsEvent
		    Author: 		Joe Baechtel

		.INPUT PARMS
			sourceIdentifier		Required		Source identifier of the event to which you are subscribing

			action				Optional		Specifies commands to handle the events

			forward				Optional		Send events for this subscription to the session on the local computer

			messageData			Optional		Additional data associated with the event

			supportEvent			Optional		Hide the event subscription

			$maxTriggerCount		Optional		pecifies the maximum number of times that the action is executed for the event subscription

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Register-PodeWindowsEvent -sourceIdentifier $Source -actions {Do Something Here When Event Triggers}
		#>
		function Register-PodeWindowsEvent {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$sourceIdentifier,									# Source identifier of the event to which you are subscribing
					[Parameter(Mandatory=$false)]
						[scriptblock]$action,										# Specifies commands to handle the events
					[Parameter(Mandatory=$false)]
						[switch]$forward=$false,										# Send events for this subscription to the session on the local computer
					[Parameter(Mandatory=$false)]
						[PSObject]$messageData,										# Additional data associated with the event
					[Parameter(Mandatory=$false)]
						[switch]$supportEvent=$false,									# Hide the event subscription
					[Parameter(Mandatory=$false)]
						[int32]$maxTriggerCount)										# Specifies the maximum number of times that the action is executed for the event subscription

			process	{try		{if (Test-PodeIsWindows) {$arguments = [ordered]@{}			# Windows?  Yes - Arguments Hashtable
								$arguments.Add('SourceIdentifier',$sourceIdentifier)
								if ($action) {$arguments.Add('Action',$action)}
								if ($forward) {$arguments.Add('Forward',$forward)}
								if ($messageData) {$arguments.Add('MessageData',$messageData)}
								if ($supportEvent) {$arguments.Add('SupportEvent',$supportEvent)}
								if ($maxTriggerCount) {$arguments.Add('MaxTriggerCount',$maxTriggerCount)}
								$result = Register-EngineEvent @Arguments $arguments		# Register-EngineEvent
								return $result
							} else {return $false}}
					catch	{return $false}}
		}
		#endregion Register-PodeWindowsEvent

		#region Send-PodeMessage
		<#
		.Synopsis
			Sends a Message to a Registered User/Service (runspace).

		.NOTES     
		    Name:			Send-PodeMessage
		    Author:		Joe Baechtel

		.INPUT PARMS
			user					Optional		User Name to Send Message To

			broadcast				Optional		Broadcasts Message to ALL Registered Users

			service				Optional		Service Name to Send Message To

			message				REQUIRED		Message to be Sent

			from					REQUIRED		Message Sent From

			fromType				REQUIRED		Message From Type:  User; Service; External; Pode

			expires				Optional		Message Expires Date/Time

		.RETURNS
			Message(s)

		.EXAMPLES
			$user = "Joe"
			$result = Send-PodeMessage -user $user -message "Welcome $($user), glad you are back! -from Pode -fromType Pode -expires $((get-date).AddHours(2))
		#>
		function Send-PodeMessage {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[string]$user,												# User Name to Send Message To
					[Parameter(Mandatory=$false)]
						[switch]$broadcast,											# Broadcasts Message to ALL Registered Users
					[Parameter(Mandatory=$false)]
						[string]$service,											# Service Name to Send Message To
					[Parameter(Mandatory=$true)]
						$message,													# Message
					[Parameter(Mandatory=$true)]
						[string]$from,												# Message Sent From
					[Parameter(Mandatory=$true)]
						[string]$fromType,											# Message From Type:  User; Service; External
					[Parameter(Mandatory=$false)]
						[datetime]$expires)											# Message Expires Date/Time (Optional)

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if ($user) {if (Get-Module -Name "Pode") {							# Type:  User?
											$users = ((Get-PodeState -Name 'queues').Item('users'))	# Get Resistered Users Hashtable
										} else {$users = $global:queues.Item('users')}			# Get Resistered Users Hashtable
							} else {if (Get-Module -Name "Pode") {								# No - Type Service
										$services = ((Get-PodeState -Name 'queues').Item('services'))	# Get Resistered Services Hashtable
									} else {$services = $global:queues.Item('services')}}			# Get Resistered Services Hashtable
							[PScustomObject]$newMessage = [PSCustomObject]@{}						# New Message Custom Object
							$timestamp = $(Get-Date -Format "yyyy/dd/MM HH:mm:ss.fff")
							Add-Member -InputObject $newMessage -MemberType NoteProperty -Name 'timestamp' -Value $timestamp	# Timestamp
							Add-Member -InputObject $newMessage -MemberType NoteProperty -Name 'message' -Value $message		# Message
							Add-Member -InputObject $newMessage -MemberType NoteProperty -Name 'from' -Value $from			# Message Sent From
							Add-Member -InputObject $newMessage -MemberType NoteProperty -Name 'fromType' -Value $fromType		# Message From Type (User; Service; Pode; External)
							if ($expires) {Add-Member -InputObject $newMessage -MemberType NoteProperty -Name 'expires' -Value $expires}	# Message Expires Date/Time (Optional)
							if ($broadcast) {foreach ($user in $users.GetEnumerator()) {$user = $user.Key	# Process Users
											$users.Item($user).Item('inbox').Enqueue($local:newMessage)	# Queue Message to Inbox
											if (Get-Module -Name "Pode") {
														Lock-PodeObject -ScriptBlock {			# Lock While Updating Queues
															$queues = Get-PodeState -Name 'queues'
															$queues.Item('users') = $users		# Update User
															Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
													} else {$global:queues.Item('users') = $users}}	# Update User
							} elseif ($user) {$users.Item($user).Item('inbox').Enqueue($local:newMessage)	# Queue Message to Inbox
								if (Get-Module -Name "Pode") {
											Lock-PodeObject -ScriptBlock {					# Lock While Updating Queues
												$queues = Get-PodeState -Name 'queues'
												$queues.Item('users') = $users				# Update User
												Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
										} else {$global:queues.Item('users') = $users}			# Update User
							} elseif ($service)  {$services.Item($service).Item('inbox').Enqueue($local:newMessage)	# Queue Message to Inbox
								if (Get-Module -Name "Pode") {
									Lock-PodeObject -ScriptBlock {							# Lock While Updating Queues
										$queues = Get-PodeState -Name 'queues'
										$queues.Item('services') = $services					# Update Services
										Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
								} else {$global:queues.Item('services') = $services}				# Update Services
							} else {return $false}
							if (Test-PodeIsWindows) {										# Windows?
								if ($user) {try		{$event = Get-Event -SourceIdentifier $("PodeUser_" + $user) -ErrorAction SilentlyContinue}
											catch	{$event = $false}
									if (!$event) {New-Event -SourceIdentifier $("PodeUser_" + $user) -Sender Pode -MessageData "New Message"}
								} else {try		{$event = Get-Event -SourceIdentifier $("PodeService_" + $service) -ErrorAction SilentlyContinue}
										catch	{$event = $false}
									if (!$event) {New-Event -SourceIdentifier $("PodeService_" + $service) -Sender Pode -MessageData "New Message"}}}
							return [PScustomObject]$newMessage}						# Return Message
					catch	{return $false}}
		}
		#endregion Send-PodeMessage

		#region Send-PodeServiceCommand
		<#
		.Synopsis
			Sends a Command to a registered Service.

		.NOTES     
		    Name: 		Send-PodeServiceCommand
		    Author: 		Joe Baechtel

		.INPUT PARMS
			service				REQUIRED		Service Name to Send Command To

			command				REQUIRED		Command

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Send-PodeServiceCommand -service Service1 -command Terminate
		#>
		function Send-PodeServiceCommand {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$service,											# Service Name to Send Command To
					[Parameter(Mandatory=$true)]
						[string]$command)											# Command

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$services = ((Get-PodeState -Name 'queues').Item('services'))	# Get Resistered Services Hashtable
							} else {$services = $global:queues.Item('services')}			# Get Resistered Services Hashtable
							$services.Item($service).Item('commands').Enqueue($command)		# Queue Command
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Queues
									$queues = Get-PodeState -Name 'queues'
									$queues.Item('services') = $services				# Register New Service
									Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
							} else {$global:queues.Item('services') = $services}			# Register New Service
							return $true}
					catch	{return $false}}
		}
		#endregion Send-PodeServiceCommand

		#region Set-PodeServiceStatus
		<#
		.Synopsis
			Sets a Registered Service's status.

		.NOTES     
		    Name: 		Set-PodeServiceStatus
		    Author: 		Joe Baechtel

		.INPUT PARMS
			service				REQUIRED		Service Name to Send Command To

			status				REQUIRED		Status

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Set-PodeServiceStatus -service Service1 -status Running
		#>
		function Set-PodeServiceStatus {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$service,											# Service Name to Set Status For
					[Parameter(Mandatory=$true)]
						[string]$status)											# Status

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$services = ((Get-PodeState -Name 'queues').Item('services'))	# Get Resistered Services Hashtable
							} else {$services = $global:queues.Item('services')}			# Get Resistered Services Hashtable
							$services.Item($service).Item('status') = $status				# Set Status
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Queues
									$queues = Get-PodeState -Name 'queues'
									$queues.Item('services') = $services				# Register New Service
									Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
							} else {$global:queues.Item('services') = $services}			# Register New Service
							return $true}
					catch	{return $false}}
		}
		#endregion Set-PodeServiceStatus

		#region Start-PodeEventHeartbeat
		<#
		.Synopsis
			Starts/Enables a Heartbeat (event) timer.

		.NOTES     
		    Name: 		Start-PodeEventHeartbeat
		    Author: 		Joe Baechtel

		.INPUT PARMS
			$heartbeatEvent		REQUIRED		Heartbeat Event Object (from Register-PodeEventHeartbeat)

		.RETURNS
			Hashtable							Heartbeat Event timer object

		.EXAMPLES
			$heartbeatObject = Start-PodeEventHeartbeat -heartbeatEvent $heartbeatObject
		#>
		function Start-PodeEventHeartbeat {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)][Alias("heartbeat")]
						[hashtable]$heartbeatEvent)									# Heartbeat Event (from Register-PodeEventHeartbeat)

			process	{try		{$timer = $(Get-Variable -Name $heartbeatEvent.Item("Heartbeat Name") -Scope $heartbeatEvent.Item("Scope")).Value	# Get Timer Event
							$timer.Enabled = $true									# Enable Timer Event
							Set-Variable -Name $heartbeatEvent.Item("Heartbeat Name") -Scope $heartbeatEvent.Item("Scope") -Value $timer
							$heartbeatEvent.Item("Enabled") = $true}					# Indicate Timer Event Has Started (Enabled)
					catch	{$heartbeatEvent.Item("Enabled") = $false}}					# Indicate Timer Event Failed to Start (Disabled)

			end		{return $heartbeatEvent}											# Return Results
		}
		#endregion Start-PodeEventHeartbeat

		#region Stop-PodeEventHeartbeat
		<#
		.Synopsis
			Stops/Disables a Heartbeat (event) timer.

		.NOTES     
		    Name: 		Stop-PodeEventHeartbeat
		    Author: 		Joe Baechtel

		.INPUT PARMS
			$heartbeatEvent		REQUIRED		Heartbeat Event Object (from Register-PodeEventHeartbeat)

		.RETURNS
			Hashtable							Heartbeat Event timer object

		.EXAMPLES
			$heartbeatObject = Stop-PodeEventHeartbeat -heartbeatEvent $heartbeatObject
		#>
		function Stop-PodeEventHeartbeat {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)][Alias("heartbeat")]
						[hashtable]$heartbeatEvent)									# Heartbeat Event Object (from Register-PodeEventHeartbeat)

			begin	{$hashtable = [ordered]@{}}

			process	{try		{$timer = $(Get-Variable -Name $heartbeatEvent.Item("Heartbeat Name") -Scope $heartbeatEvent.Item("Scope")).Value	# Get Timer Event
							$timer.Enabled = $false									# Disable Timer Event
							Set-Variable -Name $heartbeatEvent.Item("Heartbeat Name") -Scope $heartbeatEvent.Item("Scope") -Value $timer
							$heartbeatEvent.Item("Enabled") = $false}					# Indicate Timer Event Has Stoped (Disabled)
					catch	{$heartbeatEvent.Item("Enabled") = $true}}					# Indicate Timer Event Failed to Stop (Enabled)

			end		{return $heartbeatEvent}											# Return Results
		}
		#endregion Stop-PodeEventHeartbeat

		#region Test-PodeIsWindows
		<#
		.Synopsis
			Helper function.  Tests if running in Windows environment.

		.NOTES     
		    Name: 		Test-PodeIsWindows
		    Author: 		Joe Baechtel

		.INPUT PARMS
			N/A

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Test-PodeIsWindows
		#>
		function Test-PodeIsWindows {
			process	{try		{$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
							return $true}
					catch	{return $false}}
		}
		#endregion Test-PodeIsWindows

		#region Unregister-PodeEventHeartbeat
		<#
		.Synopsis
			Unregisters (removes) a registered Heartbeat (event) timer.

		.NOTES     
		    Name: 		Unregister-PodeEventHeartbeat
		    Author: 		Joe Baechtel

		.INPUT PARMS
			eventObject			REQUIRED		Heartbeat Event Object (From Register-Envent)

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Unregister-PodeService Service1
		#>
		function Unregister-PodeEventHeartbeat {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)][Alias("heartbeat","event","object")]
						$eventObject)												# Heartbeat Event Object (From Register-Envent)

			begin	{$hashtable = [ordered]@{}}

			process	{$hashtable.Add('Heartbeat Name',$heartbeatEvent.Item("Heartbeat Name"))
					try		{$result = Unregister-Event -SourceIdentifier $($eventObject.Event.Name) -Confirm:$false -Force
							$hashtable.Add('Unregistered',$true)
							If (Test-Path variable:$($eventObject.Scope):$($eventObject.'Heartbeat Name')) {
								Remove-Variable -Name $($eventObject.'Heartbeat Name') -Scope $($eventObject.Scope)}}
					catch	{hashtable.Add('Unregistered',$false)
							hashtable.Add('Error','Unregister-Event:  FAILED!')}}

			end		{return $hashtable}
		}
		#endregion Unregister-PodeEventHeartbeat

		#region Unregister-PodeService
		<#
		.Synopsis
			Unregisters (removes) a registered Service (runspace).

		.NOTES     
		    Name: 		Unregister-PodeService
		    Author: 		Joe Baechtel

		.INPUT PARMS
			service				REQUIRED		Service Name to Unresister

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Unregister-PodeService -service Service1
		#>
		function Unregister-PodeService {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$service)											# Service Name to Unresister

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$services = ((Get-PodeState -Name 'queues').Item('services'))	# Get Resistered Services Hashtable
							} else {$services = $global:queues.Item('services')}			# Get Resistered Services Hashtable
							if ($services.Item($service)) {$services.Remove($service)}		# Is Service Registered?  Yes- Remove It
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Queues
									$queues = Get-PodeState -Name 'queues'
									$queues.Item('services') = $services				# Unegister Service
									Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
							} else {$global:queues.Item('services') = $services}			# Unregister Service
							return $true}
					catch	{return $false}}
		}
		#endregion Unregister-PodeService

		#region Unregister-PodeUser
		<#
		.Synopsis
			Unregisters (removes) a registered User.

		.NOTES     
		    Name:			Unregister-PodeUse
		    Author:		Joe Baechtel

		.INPUT PARMS
			user					REQUIRED		User Name to Unresister

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Unregister-PodeUse -user Joe
		#>
		function Unregister-PodeUser {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$user)												# User Name to Unresister

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Queues?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Queues?

			process	{try		{if (Get-Module -Name "Pode") {
								$users = ((Get-PodeState -Name 'queues').Item('users'))	# Get Resistered Users Hashtable
							} else {$users = $global:queues.Item('users')}				# Get Resistered Users Hashtable
							if ($users.Item($user)) {$users.Remove($user)}				# Is User Registered?  Yes- Reset It
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Queues
									$queues = Get-PodeState -Name 'queues'
									$queues.Item('users') = $users					# Unregister User
									Set-PodeState -Name 'queues' -Scope Global -Value $queues}	# Update State Variable
							} else {$global:queues.Item('users') = $users}				# Unregister User
							return $true}
					catch	{return $false}}
		}
		#endregion Unregister-PodeUser

		#region Unregister-PodeWindowsEvent
		<#
		.Synopsis
			Unregisters (removes) a registered Windows Event subscription.

		.NOTES     
		    Name: 		Unregister-PodeWindowsEvent
		    Author: 		Joe Baechtel

		.INPUT PARMS
			sourceIdentifier		Optional		Specifies the source identifier for which this cmdlet deletes events from

			eventIdentifier		Optional		Specifies the event identifier for which the cmdlet deletes

			whatIf				Optional		Shows what would happen if the cmdlet runs

			confirm				Optional		Prompts you for confirmation before running the cmdlet

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Unregister-PodeWindowsEvent -eventIdentifier $EventID
		#>
		function Unregister-PodeWindowsEvent {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[string]$sourceIdentifier,									# Specifies the source identifier for which this cmdlet deletes events from.
					[Parameter(Mandatory=$false)]
						[int32]$eventIdentifier,										# Specifies the event identifier for which the cmdlet deletes.
					[Parameter(Mandatory=$false)]
						[switch]$whatIf=$false,										# Shows what would happen if the cmdlet runs.
					[Parameter(Mandatory=$false)]
						[switch]$confirm=$false)										# Prompts you for confirmation before running the cmdlet.

			process	{try		{if (Test-PodeIsWindows) {$arguments = [ordered]@{}			# Windows?  Yes - Arguments Hashtable
								if ($sourceIdentifier) {$arguments.Add('SourceIdentifier',$sourceIdentifier)}
								if ($eventIdentifier) {$arguments.Add('EventIdentifier',$eventIdentifier)}
								if ($whatIf) {$arguments.Add('WhatIf',$whatIf)}
								if ($confirm) {$arguments.Add('Confirm',$confirm)}
								$result = Unregister-Event @Arguments $arguments			# Unregister-Event
								return $result
							} else {return $false}}
					catch	{return $false}}
		}
		#endregion Unregister-PodeWindowsEvent
	#endregion Queue Functions

	#region Stack Functions
		#region Initialize-PodeStacks
		<#
		.Synopsis
			Initializes Pode Stacks.

		.NOTES     
		    Name:			Initialize-PodeStacks
		    Author:		Joe Baechtel

		.INPUT PARMS
			force				Optional		Forces "empty" Registered Global/Personal stacks

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$results = Initialize-PodeStacks -force
		#>
		function Initialize-PodeStacks {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$false)]
						[switch]$force)											# Force Initialization if Exists

			process	{try		{if (Get-Module -Name "Pode") {
								if (!(Get-PodeState -Name 'stacks') -and !$force) {return $true}	# Already Initialized?
								$local:stacks = [ordered]@{}							# Build Stacks
								$local:stacks.Add('global',[ordered]@{})				# Global Stack
								$local:stacks.Add('personal',[ordered]@{})				# Personal Stack
								Lock-PodeObject -ScriptBlock {						# Lock While Initializing Stacks
									Set-PodeState -Name 'stacks' -Scope Global $local:stacks	# Create Stacks
							} else {if (!$global:stacks -and !$force) {return $true}		# Already Initialized?
								$global:stacks = [ordered]@{}							# Build Stacks
								$global:stacks.Add('globals',[ordered]@{})				# Global Stack
								$global:stacks.Add('personal',[ordered]@{})}				# Personal Stack
							return $true}}
					catch	{return $false}}
		}
		#endregion Initialize-PodeStacks

		#region Close-PodeStacks
		<#
		.Synopsis
			Forces Destruction of Pode Stacks.

		.NOTES     
		    Name:			Close-PodeStacks
		    Author:		Joe Baechtel

		.INPUT PARMS
			force				REQUIRED		Forces Destruction of Pode Stacks

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$results = Close-PodeStacks -force
		#>
		function Close-PodeStacks {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[switch]$force)											# Force Destruction of Pode Stacks

			process	{try		{if (Get-Module -Name "Pode") {
								if (!(Get-PodeState -Name 'stacks')) {return $true}		# Stacks Don't Exist?
								Lock-PodeObject -ScriptBlock {						# Lock While Destroying Queues
									Remove-PodeState -Name 'stacks'					# Destroy Stacks
							} else {if (!$global:stacks) {return $true}					# Stacks Don't Exist?
								Remove-Variable -Name stacks -Scope Global}				# Destroy Stacks
							return $true}}
					catch	{return $false}}
		}
		#endregion Close-PodeStacks

		#region Pop-PodeStack
		<#
		.Synopsis
			Removes (gets) an object off a Registered Stack.

		.NOTES     
		    Name: 		Pop-PodeStack
		    Author: 		Joe Baechtel

		.INPUT PARMS
			stack				REQUIRED		Stack Name to Resister

			global				Optional		Global Stack Flag - Default = $true

			personal				Optional		Personal Stack Flag

			peek					Optional		Peek:  Leave Message(s) on Stack - Just Looking

		.RETURNS
			Object							From Stack

		.EXAMPLES
			$object = Pop-PodeStack -stack Stack1 -global
		#>
		function Pop-PodeStack {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$stack,											# Stack Name to Resister
					[Parameter(Mandatory=$false)]
						[switch]$global=$true,										# Global Stack - Default = $true
					[Parameter(Mandatory=$false)]
						[switch]$personal,											# Personal Stack
					[Parameter(Mandatory=$false)]
						[switch]$peek)												# Peek:  Leave Object on Stack - Just Looking

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'stacks')) {return $false}				# Need to Initilize Stacks?
					} else {if (!$global:stacks) {return $false}}						# Need to Initilize Stacks?
					if ($personal) {$global = $false}}

			process	{try		{if (Get-Module -Name "Pode") {$stacks = (Get-PodeState -Name 'stacks')	# Get Resistered Stacks Hashtable
							} else {$stacks = $global:stacks.Item('stacks')}				# Get Resistered Stacks Hashtable
							if ($personal) {try		{if ($peek) {$object = $stacks.Item('personal').Item($stack).Peek()	# Peek at Object?
												} else {$object = $stacks.Item('personal').Item($stack).Pop()}}		# Get Object
										catch	{return $false}					# Nothing Found
							} else {	try		{if ($peek) {$object = $stacks.Item('global').Peek()	# Peek at Object?
											} else {$object = $stacks.Item('global').Pop()}}		# Get Object
									catch	{return $false}}						# Nothing Found
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Stacks
									Set-PodeState -Name 'stacks' -Scope Global -Value $stacks}	# Update State Variable
							} else {$global:stacks = $stacks}							# Update Stacks Variable
							return $object}
					catch	{return $false}}
		}
		#endregion Pop-PodeStack

		#region Push-PodeStack
		<#
		.Synopsis
			Adds (pushs) an object onto a Registered Stack.

		.NOTES     
		    Name: 		Push-PodeStack
		    Author: 		Joe Baechtel

		.INPUT PARMS
			stack				REQUIRED		Stack Name to Resister

			global				Optional		Global Stack Flag - Default = $true

			personal				Optional		Personal Stack Flag

			object				REQUIREDl		Object to Push onto Stack

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Push-PodeStack -stack Stack1 -global -object "Hello!"
		#>
		function Push-PodeStack {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$stack,											# Stack Name to Resister
					[Parameter(Mandatory=$false)]
						[switch]$global=$true,										# Global Stack - Default = $true
					[Parameter(Mandatory=$false)]
						[switch]$personal,											# Personal Stack
					[Parameter(Mandatory=$false)]
						$object)													# Object to Push onto Stack

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'stacks')) {return $false}				# Need to Initilize Stacks?
					} else {if (!$global:stacks) {return $false}}						# Need to Initilize Stacks?
					if ($personal) {$global = $false}}

			process	{try		{if (Get-Module -Name "Pode") {$stacks = (Get-PodeState -Name 'stacks')		# Get Resistered Stacks Hashtable
							} else {$stacks = $global:stacks.Item('stacks')}							# Get Resistered Stacks Hashtable
							if ($personal) {try		{$stacks.Item('personal').Item($stack).Push($object)}	# Push Object onto Stack
										catch	{return $false}								# Nothing Found
							} else {	try		{$stacks.Item('global').Item($stack).Push($object)}		# Push Object onto Stack
									catch	{return $false}}									# Nothing Found
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Stacks
									Set-PodeState -Name 'stacks' -Scope Global -Value $stacks}	# Update State Variable
							} else {$global:stacks = $stacks}							# Update Stacks Variable
							return $true}
					catch	{return $false}}
		}
		#endregion Push-PodeStack

		#region Register-PodeStack
		<#
		.Synopsis
			Registers a Stack.

		.NOTES     
		    Name: 		Register-PodeStack
		    Author: 		Joe Baechtel

		.INPUT PARMS
			stack				REQUIRED		Stack Name to Resister

			global				Optional		Global Stack Flag - Default = $true

			personal				Optional		Personal Stack Flag

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Register-PodeStack -stack Stack1 -global
		#>
		function Register-PodeStack {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$stack,											# Stack Name to Resister
					[Parameter(Mandatory=$false)]
						[switch]$global=$true,										# Global Stack - Default = $true
					[Parameter(Mandatory=$false)]
						[switch]$personal)											# Personal Stack

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'stacks')) {return $false}				# Need to Initilize Stacks?
					} else {if (!$global:stacks) {return $false}}						# Need to Initilize Stacks?
					if ($personal) {$global = $false}}

			process	{try		{if (Get-Module -Name "Pode") {$stacks = (Get-PodeState -Name 'stacks')	# Get Resistered Stacks Hashtable
							} else {$stacks = $global:stacks.Item('stacks')}				# Get Resistered Stacks Hashtable
							if ($personal) {$newStack = $stacks.Item('personal')			# Get personal Stacks?
								if (!$newStack.Item($stack)) {$newStack.Add($stack,(New-Object System.Collections.Stack))	# Set-up New Stack
								} else {$newStack.Item($stack) = New-Object System.Collections.Stack}					# Clear Existing Stack
								$stacks.Item('personal') = $newStack					# Update Stack
							} else {$newStack = $newStack.Item('global')					# Get Global Stacks
								if (!$newStack.Item($stack)) {$newStack.Add($stack,(New-Object System.Collections.Stack))	# Set-up New Stack
								} else {$newStack.Item($stack) = New-Object System.Collections.Stack}					# Clear Existing Stack
								$stacks.Item('global') = $newStack}					# Update Stack
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Stacks
									Set-PodeState -Name 'stacks' -Scope Global -Value $stacks}	# Update State Variable
							} else {$global:stacks = $stacks}							# Register New Stack
							return $true}
					catch	{return $false}}
		}
		#endregion Register-PodeStack

		#region Unregister-PodeStack
		<#
		.Synopsis
			Unregisters (removes) a registered Stack.

		.NOTES     
		    Name: 		Unregister-PodeStack
		    Author: 		Joe Baechtel

		.INPUT PARMS
			stack				REQUIRED		Stack Name to Unresister

			global				Optional		Global Stack Flag - Default = $true

			personal				Optional		Personal Stack Flag

		.RETURNS
			Boolean							True/False

		.EXAMPLES
			$result = Unregister-PodeStack -stack Stack1 -global
		#>
		function Unregister-PodeStack {
			[CmdletBinding()]

			param	([Parameter(Mandatory=$true)]
						[string]$stack,											# Stack Name to Unresister
					[Parameter(Mandatory=$false)]
						[switch]$global=$true,										# Global Stack - Default = $true
					[Parameter(Mandatory=$false)]
						[switch]$personal)											# Personal Stack

			begin	{if (Get-Module -Name "Pode") {
						if (!(Test-PodeState -Name 'queues')) {return $false}				# Need to Initilize Stacks?
					} else {if (!$global:queues) {return $false}}}						# Need to Initilize Stacks?

			process	{try		{if (Get-Module -Name "Pode") {$stacks = (Get-PodeState -Name 'stacks')	# Get Resistered Stacks Hashtable
							} else {$stacks = $global:stacks.Item('stacks')}				# Get Resistered Stacks Hashtable
							if ($personal) {$newStack = $stacks.Item('personal')			# Get personal Stacks?
								if (!$newStack.Item($stack)) {return $true}				# Stack Didn't Exist - Abondon Ship!
								$stacks.Item('personal').Remove($stack)					# Update Stack
							} else {$newStack = $newStack.Item('global')					# Get Global Stacks
								if (!$newStack.Item($stack)) {return $true}				# Stack Didn't Exist - Abondon Ship!
								$stacks.Item('global').Remove($stack)}					# Update Stack
							if (Get-Module -Name "Pode") {
								Lock-PodeObject -ScriptBlock {						# Lock While Updating Stacks
									Set-PodeState -Name 'stacks' -Scope Global -Value $stacks}	# Update State Variable
							} else {$global:stacks = $stacks}							# Register New Stack
							return $true}
					catch	{return $false}}
		}
		#endregion Unregister-PodeStack
	#endregion Stack Functions
