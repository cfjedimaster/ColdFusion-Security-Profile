
<cfset runtime = createObject("component","CFIDE.adminapi.runtime")>
<cfset debug = createObject("component","CFIDE.adminapi.debugging")>
<cfset security = createObject("component","CFIDE.adminapi.security")>
<cfset datasource = createObject("component","CFIDE.adminapi.datasource")>


<cfset settings = {}>
<cfset settings.useUUIDForCFToken = runtime.getScopeProperty("UUIDCFToken")>
<cfset settings.disableInternalJava = runtime.getRuntimeProperty("DisableServiceFactory")>
<cfset settings.enableGlobalScriptProtect = runtime.getRuntimeProperty("GlobalScriptProtect")>
<cfset settings.maxPostSize = runtime.getRuntimeProperty("PostSizeLimit")>
<cfset settings.missingTemplateHandler = runtime.getRuntimeProperty("MissingTemplateHandler")>
<cfset settings.siteErrorHandler = runtime.getRuntimeProperty("SiteWideErrorHandler")>
<cfset settings.requestQueueTimeoutPage = runtime.getRuntimeProperty("RequestQueueTimeoutPage")>
<cfset settings.cookieTimeout = runtime.getRuntimeProperty("SessionCookieTimeout")>
<cfset settings.disableUpdateInternalCookies = runtime.getRuntimeProperty("CFInternalCookieDisableUpdate")>
<!--- cant do the 2 web socket ones --->

<!--- hecking allowed sql against all DSNs --->
<cfset badOpList = "create,drop,alter,grant,revoke,storedproc">
<cfset dsns = datasource.getDatasources()>
<cfset settings.baddsns = {}>
<cfloop item="dsn" collection="#dsns#">
	<cfset thisDSN = dsns[dsn]>
	<cfloop index="op" list="#badOpList#">
		<cfif thisDsn[op]>
			<cfif not structKeyExists(settings.baddsns, dsn)>
				<cfset settings.baddsns[dsn] = "">
			</cfif>
			<cfset settings.baddsns[dsn] = listAppend(settings.baddsns[dsn], op)>
		</cfif>
	</cfloop>
</cfloop>

<cfset settings.enableRobustExceptions = debug.getDebugProperty("enableRobustExceptions")>
<cfset settings.enableCFSTAT = debug.getDebugProperty("enableCFSTAT")>
<!--- we want to require username/password, this is in a bad state if isLoginUserIdRequired=false OR getUserAdminPassword=false --->
<cfset settings.badLoginRequirements = (!security.isLoginUserIdRequired() || !security.getUseAdminPassword())>
<cfset settings.rdsEnabled = security.getEnableRDS()>
<!--- ditto RDS setting --->
<cfset settings.badRDSRequirements = (security.getUseSingleRDSPassword() || !security.getUseRDSPassword())>
<cfset settings.enableSandBoxSecurity = security.getEnableSandboxSecurity()>
<cfset settings.allowedIps = security.getAllowedIpList()>

<cfset cookie.CFADMIN_LASTPAGE_ADMIN = cgi.SCRIPT_NAME>

<cfinclude template="../header.cfm">

<style>
table.profileReport {
	border-collapse: collapse;
	width: 90%;
}
table.profileReport,  table.profileReport th, table.profileReport td {
border: 1px solid black;
}
table.profileReport tr.good {
	background-color: #bbedbb;
}
table.profileReport tr.bad {
	background-color: #f2b297;
}
table.profileReport td a {
	color: black;
	text-decoration:underline;
}
table.profileReport thead {
	background-color: #e2e6e7;
}
table.profileReport th, table.profileReport td {
	padding: 5px;
}
</style>

<h2 class="pageHeader">Security Profile</h2>

<p>
The following table lists ColdFusion Server security settings and recommended values. This should
not be considered a 100% full-proof checklist for locking down your server. Rather, it is quick
guide to the most common security settings and their best values.
</p>

<!---
<cfdump var="#settings#" expand="false">
--->

<table class="profileReport">
	<thead>
		<tr>
			<th>Setting</th>
			<th>Current Value</th>
			<th>Recommended Value</th>
		</tr>
	</thead>
	<cfoutput>
	<tbody>
		<tr class="<cfif settings.useUUIDForCFToken>good<cfelse>bad</cfif>">
			<td><a href="../settings/server_settings.cfm">Use UUID for cftoken</a></td>
			<td><cfif settings.useUUIDForCFToken>Enabled<cfelse>Disabled</cfif></td>
			<td>Enabled</td>
		</tr>
		<tr class="<cfif settings.disableInternalJava>good<cfelse>bad</cfif>">
			<td><a href="../settings/server_settings.cfm">Disable access to internal ColdFusion Java components</a></td>
			<td><cfif settings.disableInternalJava>Enabled<cfelse>Disabled</cfif></td>
			<td>Enabled</td>
		</tr>
		<tr class="<cfif settings.enableGlobalScriptProtect>good<cfelse>bad</cfif>">
			<td><a href="../settings/server_settings.cfm">Enable Global Script Protection</a></td>
			<td><cfif settings.enableGlobalScriptProtect>Enabled<cfelse>Disabled</cfif></td>
			<td>Enabled</td>
		</tr>		
		<tr class="<cfif settings.maxpostsize lte 20>good<cfelse>bad</cfif>">
			<td><a href="../settings/server_settings.cfm">Maxium size of post data</a></td>
			<td>#settings.maxpostsize# MB</td>
			<td>20 MB</td>
		</tr>		
		<tr class="<cfif len(settings.missingtemplatehandler)>good<cfelse>bad</cfif>">
			<td><a href="../settings/server_settings.cfm">Missing Template Error Handler</a></td>
			<td>#settings.missingtemplatehandler#</td>
			<td>Anything</td>
		</tr>		
		<tr class="<cfif len(settings.siteerrorhandler)>good<cfelse>bad</cfif>">
			<td><a href="../settings/server_settings.cfm">Site Error Handler</a></td>
			<td>#settings.siteerrorhandler#</td>
			<td>Anything</td>
		</tr>		
		<tr class="<cfif len(settings.requestQueueTimeoutPage)>good<cfelse>bad</cfif>">
			<td><a href="../settings/limits.cfm">Request Queue Timeout Page</a></td>
			<td>#settings.requestQueueTimeoutPage#</td>
			<td>Anything</td>
		</tr>	
		<tr class="<cfif settings.cookietimeout lte 1440>good<cfelse>bad</cfif>">
			<td><a href="../settings/memoryvariables.cfm">Cookie Timeout</a></td>
			<td>#settings.cookietimeout# minutes</td>
			<td>1440 minutes</td>
		</tr>	
		<tr class="<cfif settings.disableUpdateInternalCookies>good<cfelse>bad</cfif>">
			<td><a href="../settings/memoryvariables.cfm">Disable updating of ColdFusion internal cookies</a></td>
			<td><cfif settings.disableUpdateInternalCookies>Enabled<cfelse>Disabled</cfif></td>
			<td>Enabled</td>
		</tr>
		<!--- The complex one --->
		<tr valign="top" class="<cfif structIsEmpty(settings.baddsns)>good<cfelse>bad</cfif>">
			<td><a href="../datasources/index.cfm">Disable create, drop, alter, grant, revoke, stored procedures for DSNs</a></td>
			<td colspan="2">
			<cfif structIsEmpty(settings.baddsns)>
				All Good!
			<cfelse>
				<p>
				The following table contains DSNs with permissions that should
				be disabled.
				</p>
				<table>
					<thead>
						<tr>
							<th>DSN</th>
							<th>Permissions</th>
						</tr>
					</thead>
					<tbody>
					<cfloop item="d" collection="#settings.baddsns#">
						<tr>
							<td>#d#</td>
							<td>#replace(settings.baddsns[d],",",", ","all")#</td>
						</tr>
					</cfloop>
					</tbody>
				</table>
			</cfif>
			</td>
		</tr> 	
		<tr class="<cfif !settings.enableRobustExceptions>good<cfelse>bad</cfif>">
			<td><a href="../debugging/index.cfm">Enable Robust Exception Information</a></td>
			<td><cfif settings.enableRobustExceptions>Enabled<cfelse>Disabled</cfif></td>
			<td>Disabled</td>
		</tr>		
		<tr class="<cfif !settings.enableCFSTAT>good<cfelse>bad</cfif>">
			<td><a href="../debugging/index.cfm">Enable CFSTAT</a></td>
			<td><cfif settings.enableCFSTAT>Enabled<cfelse>Disabled</cfif></td>
			<td>Disabled</td>
		</tr>
		<tr class="<cfif !settings.badLoginRequirements>good<cfelse>bad</cfif>">
			<td><a href="../security/cfadminpassword.cfm">Require both a username and password for the Administrator</a></td>
			<td>
				Require Password: <cfif security.getUseAdminPassword()>Enabled<cfelse>Disabled</cfif><br/>
				Require Username: <cfif security.isLoginUserIdRequired()>Enabled<cfelse>Disabled</cfif>
			</td>
			<td>
				Require Password: Enabled<br/>
				Require Username: Enabled
			</td>
		</tr>
		<tr class="<cfif !settings.rdsEnabled>good<cfelse>bad</cfif>">
			<td><a href="../security/cfrdspasswordcfm">Enable RDS</a></td>
			<td><cfif settings.rdsEnabled>Enabled<cfelse>Disabled</cfif></td>
			<td>Disabled</td>
		</tr>	
		<tr class="<cfif !settings.rdsEnabled || !settings.badRDSRequirements>good<cfelse>bad</cfif>">
			<td><a href="../security/cfrdspassword.cfm">Require both a username and password for RDS</a></td>
			<cfif !settings.rdsEnabled>
				<td>RDS Disabled</td>
				<td>RDS Disabled</td>
			<cfelse>
				<td>
					Require Password: <cfif security.getUseRDSPassword()>Enabled<cfelse>Disabled</cfif><br/>
					Require Username: <cfif !security.getUseSingleRDSPassword()>Enabled<cfelse>Disabled</cfif>
				</td>
				<td>
					Require Password: Enabled<br/>
					Require Username: Enabled
				</td>
			</cfif>
		</tr>
		<tr class="<cfif settings.enableSandboxSecurity>good<cfelse>bad</cfif>">
			<td><a href="../security/index.cfm">Enable Sandbox Security</a></td>
			<td><cfif settings.enableSandboxSecurity>Enabled<cfelse>Disabled</cfif></td>
			<td>Enabled</td>
		</tr>
		<tr class="<cfif len(settings.allowedIps)>good<cfelse>bad</cfif>">
			<td><a href="../security/allowedipaddress.cfm">Allowed IP Addresses</a></td>
			<td>#settings.allowedIps#</td>
			<td>At least one</td>
		</tr>
	</tbody>
	</cfoutput>
</table>

<cfinclude template="../footer.cfm">