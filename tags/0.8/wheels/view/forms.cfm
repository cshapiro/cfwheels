<cffunction name="startFormTag" returntype="any" access="public" output="false">
	<cfargument name="link" type="any" required="false" default="">
	<cfargument name="method" type="any" required="false" default="post">
	<cfargument name="multipart" type="any" required="false" default="false">
	<cfargument name="spamProtection" type="any" required="false" default="false">
	<!--- Accepts URLFor arguments --->
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "link,method,multipart,spamProtection,controller,action,id,anchor,onlyPath,host,protocol,params">
	<cfif StructKeyExists(arguments, "id") AND NOT isNumeric(arguments.id)>
		<!--- Since a non-numeric id was passed in we assume it is meant as a HTML attribute and therefore remove it from the named arguments list so that it will be set in the attributes --->
		<cfset arguments.$namedArguments = listDeleteAt(arguments.$namedArguments, listFindNoCase(arguments.$namedArguments, "id"))>
	</cfif>
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>
	<cfif StructKeyExists(arguments, "id") AND NOT isNumeric(arguments.id)>
		<cfset StructDelete(arguments, "id")>
	</cfif>

	<cfset request.wheels.currentFormMethod = arguments.method>

	<cfif Len(arguments.link) IS NOT 0>
		<cfset loc.url = arguments.link>
	<cfelse>
		<cfset loc.url = URLFor(argumentCollection=arguments)>
	</cfif>
	<cfset loc.url = HTMLEditFormat(loc.url)>

	<cfif arguments.spamProtection>
		<cfset loc.onsubmit = "this.action='#Left(loc.url, int((Len(loc.url)/2)))#'+'#Right(loc.url, ceiling((Len(loc.url)/2)))#';">
		<cfset loc.url = "">
	</cfif>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			<form action="#loc.url#" method="#arguments.method#"<cfif arguments.multipart> enctype="multipart/form-data"</cfif><cfif StructKeyExists(loc, "onsubmit")> onsubmit="#loc.onsubmit#"</cfif>#loc.attributes#>
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="formRemoteTag" returntype="any" access="public" output="false">
	<cfargument name="link" type="any" required="false" default="">
	<cfargument name="method" type="any" required="false" default="post">
	<cfargument name="spamProtection" type="any" required="false" default="false">
	<cfargument name="update" type="any" required="false" default="">
	<cfargument name="insertion" type="any" required="false" default="">
	<cfargument name="serialize" type="any" required="false" default="false">
	<cfargument name="onLoading" type="any" required="false" default="">
	<cfargument name="onComplete" type="any" required="false" default="">
	<cfargument name="onSuccess" type="any" required="false" default="">
	<cfargument name="onFailure" type="any" required="false" default="">
	<!--- Accepts URLFor arguments --->
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "link,method,spamProtection,update,insertion,serialize,onLoading,onComplete,onSuccess,onFailure,controller,action,id,anchor,onlyPath,host,protocol,params">
	<cfif StructKeyExists(arguments, "id") AND NOT isNumeric(arguments.id)>
		<!--- Since a non-numeric id was passed in we assume it is meant as a HTML attribute and therefore remove it from the named arguments list so that it will be set in the attributes --->
		<cfset arguments.$namedArguments = listDeleteAt(arguments.$namedArguments, listFindNoCase(arguments.$namedArguments, "id"))>
	</cfif>
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>
	<cfif StructKeyExists(arguments, "id") AND NOT isNumeric(arguments.id)>
		<cfset StructDelete(arguments, "id")>
	</cfif>

	<cfif Len(arguments.link) IS NOT 0>
		<cfset loc.url = arguments.link>
	<cfelse>
		<cfset loc.url = URLFor(argumentCollection=arguments)>
	</cfif>

	<cfset loc.ajaxCall = "new Ajax.">

	<!--- Figure out the parameters for the Ajax call --->
	<cfif Len(arguments.update) IS NOT 0>
		<cfset loc.ajaxCall = loc.ajaxCall & "Updater('#arguments.update#',">
	<cfelse>
		<cfset loc.ajaxCall = loc.ajaxCall & "Request(">
	</cfif>

	<cfset loc.ajaxCall = loc.ajaxCall & "'#loc.url#', { asynchronous:true">

	<cfif Len(arguments.insertion) IS NOT 0>
		<cfset loc.ajaxCall = loc.ajaxCall & ",insertion:Insertion.#arguments.insertion#">
	</cfif>

	<cfif arguments.serialize>
		<cfset loc.ajaxCall = loc.ajaxCall & ",parameters:Form.serialize(this)">
	</cfif>

	<cfif Len(arguments.onLoading) IS NOT 0>
		<cfset loc.ajaxCall = loc.ajaxCall & ",onLoading:#arguments.onLoading#">
	</cfif>

	<cfif Len(arguments.onComplete) IS NOT 0>
		<cfset loc.ajaxCall = loc.ajaxCall & ",onComplete:#arguments.onComplete#">
	</cfif>

	<cfif Len(arguments.onSuccess) IS NOT 0>
		<cfset loc.ajaxCall = loc.ajaxCall & ",onSuccess:#arguments.onSuccess#">
	</cfif>

	<cfif Len(arguments.onFailure) IS NOT 0>
		<cfset loc.ajaxCall = loc.ajaxCall & ",onFailure:#arguments.onFailure#">
	</cfif>

	<cfset loc.ajaxCall = loc.ajaxCall & "});">

	<cfif arguments.spamProtection>
		<cfset loc.url = "">
	</cfif>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			<form action="#loc.url#" method="#arguments.method#" onsubmit="#loc.ajaxCall# return false;"#loc.attributes#>
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="endFormTag" returntype="any" access="public" output="false">
	<cfif StructKeyExists(request.wheels, "currentFormMethod")>
		<cfset StructDelete(request.wheels, "currentFormMethod")>
	</cfif>
	<cfreturn "</form>">
</cffunction>

<cffunction name="submitTag" returntype="any" access="public" output="false">
	<cfargument name="value" type="any" required="false" default="Save changes">
	<cfargument name="image" type="string" required="false" default="">
	<cfargument name="disable" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "value,image,disable">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfif Len(arguments.disable) IS NOT 0>
		<cfset loc.onclick = "this.disabled=true;">
		<cfif Len(arguments.image) IS 0 AND NOT IsBoolean(arguments.disable)>
			<cfset loc.onclick = loc.onclick & "this.value='#arguments.disable#';">
		</cfif>
		<cfset loc.onclick = loc.onclick & "this.form.submit();">
	</cfif>

	<cfif Len(arguments.image) IS NOT 0>
		<cfset loc.source = "#application.wheels.webPath##application.wheels.imagePath#/#arguments.image#">
	</cfif>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			<input value="#arguments.value#"<cfif Len(arguments.image) IS 0> type="submit"<cfelse> type="image" src="#loc.source#"</cfif><cfif Len(arguments.disable) IS NOT 0> onclick="#loc.onclick#"</cfif>#loc.attributes# />
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="textField" returntype="any" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfargument name="errorElement" type="any" required="false" default="div">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "objectName,property,label,wrapLabel,prepend,append,prependToLabel,appendToLabel,errorElement">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input type="text" name="#listLast(arguments.objectName,".")#[#arguments.property#]" id="#listLast(arguments.objectName,".")#-#arguments.property#" value="#HTMLEditFormat($formValue(argumentCollection=arguments))#"#loc.attributes# />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="radioButton" returntype="any" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="any" required="true">
	<cfargument name="tagValue" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfargument name="errorElement" type="any" required="false" default="div">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "objectName,property,tagValue,label,wrapLabel,prepend,append,prependToLabel,appendToLabel,errorElement">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input type="radio" name="#listLast(arguments.objectName,".")#[#arguments.property#]" id="#listLast(arguments.objectName,".")#-#arguments.property#" value="#arguments.tagValue#"<cfif arguments.tagValue IS $formValue(argumentCollection=arguments)> checked="checked"</cfif>#loc.attributes# />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="checkBox" returntype="any" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="any" required="true">
	<cfargument name="checkedValue" type="any" required="false" default="1">
	<cfargument name="uncheckedValue" type="any" required="false" default="0">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfargument name="errorElement" type="any" required="false" default="div">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "objectName,property,checkedValue,uncheckedValue,label,wrapLabel,prepend,append,prependToLabel,appendToLabel,errorElement">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfset loc.value = $formValue(argumentCollection=arguments)>
	<cfif (IsBoolean(loc.value) AND loc.value) OR (isNumeric(loc.value) AND loc.value GTE 1)>
		<cfset loc.checked = true>
	<cfelse>
		<cfset loc.checked = false>
	</cfif>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input type="checkbox" name="#listLast(arguments.objectName,".")#[#arguments.property#]" id="#listLast(arguments.objectName,".")#-#arguments.property#" value="#arguments.checkedValue#"<cfif loc.checked> checked="checked"</cfif>#loc.attributes# />
	    <input name="#listLast(arguments.objectName,".")#[#arguments.property#]($checkbox)" type="hidden" value="#arguments.uncheckedValue#" />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="passwordField" returntype="any" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfargument name="errorElement" type="any" required="false" default="div">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "objectName,property,label,wrapLabel,prepend,append,prependToLabel,appendToLabel,errorElement">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input type="password" name="#listLast(arguments.objectName,".")#[#arguments.property#]" id="#listLast(arguments.objectName,".")#-#arguments.property#" value="#HTMLEditFormat($formValue(argumentCollection=arguments))#"#loc.attributes# />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="hiddenField" returntype="any" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="any" required="true">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "objectName,property">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfset loc.value = $formValue(argumentCollection=arguments)>
	<cfif application.settings.obfuscateURLs AND StructKeyExists(request.wheels, "currentFormMethod") AND request.wheels.currentFormMethod IS "get">
		<cfset loc.value = obfuscateParam(loc.value)>
	</cfif>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			<input type="hidden" name="#listLast(arguments.objectName,".")#[#arguments.property#]" id="#listLast(arguments.objectName,".")#-#arguments.property#" value="#HTMLEditFormat(loc.value)#"#loc.attributes# />
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="textArea" returntype="any" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfargument name="errorElement" type="any" required="false" default="div">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "objectName,property,label,wrapLabel,prepend,append,prependToLabel,appendToLabel,errorElement">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfset loc.output = "">
	<cfset loc.output = loc.output & $formBeforeElement(argumentCollection=arguments)>
	<cfset loc.output = loc.output & "<textarea name=""#listLast(arguments.objectName, '.')#[#arguments.property#]"" id=""#listLast(arguments.objectName, '.')#-#arguments.property#""#loc.attributes#>">
	<cfset loc.output = loc.output & $formValue(argumentCollection=arguments)>
	<cfset loc.output = loc.output & "</textarea>">
	<cfset loc.output = loc.output & $formAfterElement(argumentCollection=arguments)>

	<cfreturn loc.output>
</cffunction>

<cffunction name="fileField" returntype="any" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="any" required="true">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfargument name="errorElement" type="any" required="false" default="div">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "objectName,property,label,wrapLabel,prepend,append,prependToLabel,appendToLabel,errorElement">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input type="file" name="#listLast(arguments.objectName,".")#[#arguments.property#]" id="#listLast(arguments.objectName,".")#-#arguments.property#" value=""#loc.attributes# />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="select" returntype="any" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="any" required="true">
	<cfargument name="options" type="any" required="true">
	<cfargument name="includeBlank" type="any" required="false" default="false">
	<cfargument name="multiple" type="any" required="false" default="false">
	<cfargument name="valueField" type="any" required="false" default="id">
	<cfargument name="textField" type="any" required="false" default="name">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfargument name="errorElement" type="any" required="false" default="div">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "objectName,property,options,includeBlank,multiple,valueField,textField,label,wrapLabel,prepend,append,prependToLabel,appendToLabel,errorElement">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfset loc.output = "">
	<cfset loc.output = loc.output & $formBeforeElement(argumentCollection=arguments)>
	<cfset loc.output = loc.output & "<select name=""#listLast(arguments.objectName,'.')#[#arguments.property#]"" id=""#listLast(arguments.objectName,'.')#-#arguments.property#"">">
	<cfif arguments.multiple>
		<cfset loc.output = loc.output & " multiple">
	</cfif>
	<cfset loc.output = loc.output & loc.attributes>
	<cfif NOT IsBoolean(arguments.includeBlank) OR arguments.includeBlank>
		<cfif NOT IsBoolean(arguments.includeBlank)>
			<cfset loc.text = arguments.includeBlank>
		<cfelse>
			<cfset loc.text = "">
		</cfif>
		<cfset loc.output = loc.output & "<option value="""">#loc.text#</option>">
	</cfif>
	<cfset loc.output = loc.output & $optionsForSelect(argumentCollection=arguments)>
	<cfset loc.output = loc.output & "</select>">
	<cfset loc.output = loc.output & $formAfterElement(argumentCollection=arguments)>

	<cfreturn loc.output>
</cffunction>

<cffunction name="textFieldTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "name,value,label,wrapLabel,prepend,append,prependToLabel,appendToLabel">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input name="#arguments.name#" id="#arguments.name#" type="text" value="#HTMLEditFormat($formValue(argumentCollection=arguments))#"#loc.attributes# />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="radioButtonTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="checked" type="any" required="false" default="false">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "name,value,checked,label,wrapLabel,prepend,append,prependToLabel,appendToLabel">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input name="#arguments.name#" id="#arguments.name#" type="radio" value="#$formValue(argumentCollection=arguments)#"<cfif arguments.checked> checked="checked"</cfif>#loc.attributes# />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="checkBoxTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="1">
	<cfargument name="checked" type="any" required="false" default="false">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "name,value,checked,label,wrapLabel,prepend,append,prependToLabel,appendToLabel">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input name="#arguments.name#" id="#arguments.name#" type="checkbox" value="#arguments.value#"<cfif arguments.checked> checked="checked"</cfif>#loc.attributes# />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="passwordFieldTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "name,value,label,wrapLabel,prepend,append,prependToLabel,appendToLabel">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input name="#arguments.name#" id="#arguments.name#" type="password" value="#HTMLEditFormat($formValue(argumentCollection=arguments))#"#loc.attributes# />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="hiddenFieldTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "name,value">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfset loc.value = $formValue(argumentCollection=arguments)>
	<cfif application.settings.obfuscateURLs AND StructKeyExists(request.wheels, "currentFormMethod") AND request.wheels.currentFormMethod IS "get">
		<cfset loc.value = obfuscateParam(loc.value)>
	</cfif>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			<input name="#arguments.name#" id="#arguments.name#" type="hidden" value="#HTMLEditFormat(loc.value)#"#loc.attributes# />
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="textAreaTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "name,value,label,wrapLabel,prepend,append,prependToLabel,appendToLabel">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfset loc.output = "">
	<cfset loc.output = loc.output & $formBeforeElement(argumentCollection=arguments)>
	<cfset loc.output = loc.output & "<textarea name=""#arguments.name#"" id=""#arguments.name#""#loc.attributes#>">
	<cfset loc.output = loc.output & $formValue(argumentCollection=arguments)>
	<cfset loc.output = loc.output & "</textarea>">
	<cfset loc.output = loc.output & $formAfterElement(argumentCollection=arguments)>

	<cfreturn loc.output>
</cffunction>

<cffunction name="fileFieldTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "name,value,label,wrapLabel,prepend,append,prependToLabel,appendToLabel">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<input type="file" name="#arguments.name#" id="#arguments.name#" value="#HTMLEditFormat($formValue(argumentCollection=arguments))#"#loc.attributes# />
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="selectTag" returntype="any" access="public" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="options" type="any" required="true">
	<cfargument name="includeBlank" type="any" required="false" default="false">
	<cfargument name="multiple" type="any" required="false" default="false">
	<cfargument name="valueField" type="any" required="false" default="id">
	<cfargument name="textField" type="any" required="false" default="name">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "name,value,options,includeBlank,multiple,valueField,textField,label,wrapLabel,prepend,append,prependToLabel,appendToLabel">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfsavecontent variable="loc.output">
		<cfoutput>
			#$formBeforeElement(argumentCollection=arguments)#
			<select name="#arguments.name#" id="#arguments.name#"<cfif arguments.multiple> multiple</cfif>#loc.attributes#>
			<cfif NOT IsBoolean(arguments.includeBlank) OR arguments.includeBlank>
				<cfif NOT IsBoolean(arguments.includeBlank)>
					<cfset loc.text = arguments.includeBlank>
				<cfelse>
					<cfset loc.text = "">
				</cfif>
				<option value="">#loc.text#</option>
			</cfif>
			#$optionsForSelect(argumentCollection=arguments)#
			</select>
			#$formAfterElement(argumentCollection=arguments)#
		</cfoutput>
	</cfsavecontent>

	<cfreturn $trimHTML(loc.output)>
</cffunction>

<cffunction name="yearSelectTag" returntype="any" access="public" output="false" hint="Returns a HTML select tag with years as options">
	<cfargument name="startYear" type="any" required="false" default="#year(now())-5#" hint="First year in select list">
	<cfargument name="endYear" type="any" required="false" default="#year(now())+5#" hint="Last year in select list">
	<!---
		DETAILS:
		By default the option tags will include 11 years, 5 on each side of the current year.
		You can change this by passing in startYear and endYear.
		EXAMPLES:
		#yearSelectTag()#
		#yearSelectTag(startYear=1900, endYear=year(now()))#
	--->
	<cfset arguments.$loopFrom = arguments.startYear>
	<cfset arguments.$loopTo = arguments.endYear>
	<cfset arguments.$type = "year">
	<cfset arguments.$step = 1>
	<cfset StructDelete(arguments, "startYear")>
	<cfset StructDelete(arguments, "endYear")>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="monthSelectTag" returntype="any" access="public" output="false" hint="Returns a HTML select tag with months as options">
	<cfargument name="monthDisplay" type="any" required="false" default="names" hint="pass in 'names', 'numbers' or 'abbreviations' to control display">
	<!---
		DETAILS:
		You can use the monthDisplay argument to control the display of the option tags.
		By default the full month names will be used but you can change to show abbreviations or just month numbers.
		EXAMPLES:
		#monthSelectTag()#
		#monthSelectTag(monthDisplay="abbreviations")#
	--->
	<cfset arguments.$loopFrom = 1>
	<cfset arguments.$loopTo = 12>
	<cfset arguments.$type = "month">
	<cfset arguments.$step = 1>
	<cfif arguments.monthDisplay IS "abbreviations">
		<cfset arguments.$optionNames = "Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec">
	<cfelseif arguments.monthDisplay IS "names">
		<cfset arguments.$optionNames = "January,February,March,April,May,June,July,August,September,October,November,December">
	</cfif>
	<cfset StructDelete(arguments, "monthDisplay")>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="daySelectTag" returntype="any" access="public" output="false" hint="Returns a HTML select tag with days as options">
	<!---
		DETAILS:
		This method returns days 1-31.
		EXAMPLES:
		#daySelectTag()#
	--->
	<cfset arguments.$loopFrom = 1>
	<cfset arguments.$loopTo = 31>
	<cfset arguments.$type = "day">
	<cfset arguments.$step = 1>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="hourSelectTag" returntype="any" access="public" output="false" hint="Returns a HTML select tag with days as options">
	<!---
		DETAILS:
		This method returns hours from 0-23.
		EXAMPLES:
		#hourSelectTag()#
	--->
	<cfset arguments.$loopFrom = 0>
	<cfset arguments.$loopTo = 23>
	<cfset arguments.$type = "hour">
	<cfset arguments.$step = 1>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="minuteSelectTag" returntype="any" access="public" output="false" hint="Returns a HTML select tag with minutes as options">
	<cfargument name="minuteStep" type="any" required="false" default="1">
	<!---
		DETAILS:
		This method returns minutes from 0 to 59.
		If you don't want every minute between 0 and 59 included in the drop-down you can limit it by using the minuteStep argument.
		If you for example pass in minuteStep=15 you will get 00,15,30 and 45 as options.
		EXAMPLES:
		#minuteSelectTag()#
		#minuteSelectTag(minuteStep=10)#
	--->
	<cfset arguments.$loopFrom = 0>
	<cfset arguments.$loopTo = 59>
	<cfset arguments.$type = "minute">
	<cfset arguments.$step = arguments.minuteStep>
	<cfset StructDelete(arguments, "minuteStep")>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="secondSelectTag" returntype="any" access="public" output="false" hint="Returns a HTML select tag with seconds as options">
	<!---
		DETAILS:
		This method returns seconds from 0 to 59.
		EXAMPLES:
		#secondSelectTag()#
	--->
	<cfset arguments.$loopFrom = 0>
	<cfset arguments.$loopTo = 59>
	<cfset arguments.$type = "second">
	<cfset arguments.$step = 1>
	<cfreturn $yearMonthHourMinuteSecondSelectTag(argumentCollection=arguments)>
</cffunction>

<cffunction name="dateTimeSelect" returntype="any" access="public" output="false">
	<cfset arguments.$functionName = "dateTimeSelect">
	<cfreturn $dateTimeSelect(argumentCollection=arguments)>
</cffunction>

<cffunction name="dateTimeSelectTag" returntype="any" access="public" output="false" hint="Returns HTML select tags for choosing year, month, day, hour, minute and second">
	<!---
		DETAILS:
		You can pass in a different order to change the order in which the select tags appear on the page.
		You can also exclude one select tag completely by specifying an order with only one or two items.
		You can also change the separator character that goes between the select tags and the character that goes between the entire set of select tags (after the first three date select tags but before the last three time select tags).
		EXAMPLES:
		#dateTimeSelectTag(dateOrder="year,month,day", monthDisplay="abbreviations")#
	--->
	<cfset arguments.$functionName = "dateTimeSelectTag">
	<cfreturn $dateTimeSelect(argumentCollection=arguments)>
</cffunction>

<cffunction name="dateSelect" returntype="any" access="public" output="false">
	<cfargument name="order" type="any" required="false" default="month,day,year">
	<cfargument name="separator" type="any" required="false" default=" ">
	<cfset arguments.$functionName = "dateSelect">
	<cfreturn $dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>

<cffunction name="dateSelectTag" returntype="any" access="public" output="false" hint="Returns HTML select tags for choosing year, month and day">
	<cfargument name="order" type="any" required="false" default="month,day,year" hint="Use to change the order of or exclude select tags">
	<cfargument name="separator" type="any" required="false" default=" " hint="Use to change the character that is displayed between the select tags">
	<!---
		DETAILS:
		You can pass in a different order to change the order in which the select tags appear on the page.
		You can also exclude one select tag completely by specifying an order with only one or two items.
		You can also change the separator character that goes between the select tags.
		EXAMPLES:
		#dateSelectTag(order="year,month,day")#
	--->
	<cfset arguments.$functionName = "dateSelectTag">
	<cfreturn $dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>

<cffunction name="timeSelect" returntype="any" access="public" output="false">
	<cfargument name="order" type="any" required="false" default="hour,minute,second">
	<cfargument name="separator" type="any" required="false" default=":">
	<cfset arguments.$functionName = "timeSelect">
	<cfreturn $dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>

<cffunction name="timeSelectTag" returntype="any" access="public" output="false" hint="Returns HTML select tags for choosing hour, minute and second">
	<cfargument name="order" type="any" required="false" default="hour,minute,second" hint="Use to change the order of or exclude select tags">
	<cfargument name="separator" type="any" required="false" default=":" hint="Use to change the character that is displayed between the select tags">
	<!---
		DETAILS:
		You can pass in a different order to change the order in which the select tags appear on the page.
		You can also exclude one select tag completely by specifying an order with only one or two items.
		You can also change the separator character that goes between the select tags.
		EXAMPLES:
		#timeSelectTag(order="hour,minute", separator=" - ")#
	--->
	<cfset arguments.$functionName = "timeSelectTag">
	<cfreturn $dateOrTimeSelect(argumentCollection=arguments)>
</cffunction>

<cffunction name="$dateTimeSelect" returntype="any" access="public" output="false">
	<cfargument name="dateOrder" type="any" required="false" default="month,day,year" hint="Use to change the order of or exclude date select tags">
	<cfargument name="timeOrder" type="any" required="false" default="hour,minute,second" hint="Use to change the order of or exclude time select tags ">
	<cfargument name="dateSeparator" type="any" required="false" default=" " hint="Use to change the character that is displayed between the date select tags ">
	<cfargument name="timeSeparator" type="any" required="false" default=":" hint="Use to change the character that is displayed between the time select tags ">
	<cfargument name="separator" type="any" required="false" default=" - " hint="Use to change the character that is displayed between the first and second set of select tags ">
	<cfargument name="$functionName" type="any" required="true">
	<cfset var loc = {}>

	<cfset loc.html = "">
	<cfset loc.separator = arguments.separator>

	<cfset arguments.order = arguments.dateOrder>
	<cfset arguments.separator = arguments.dateSeparator>
	<cfif arguments.$functionName IS "dateTimeSelect">
		<cfset loc.html = loc.html & dateSelect(argumentCollection=arguments)>
	<cfelseif arguments.$functionName IS "dateTimeSelectTag">
		<cfset loc.html = loc.html & dateSelectTag(argumentCollection=arguments)>
	</cfif>
	<cfset loc.html = loc.html & loc.separator>
	<cfset arguments.order = arguments.timeOrder>
	<cfset arguments.separator = arguments.timeSeparator>
	<cfif arguments.$functionName IS "dateTimeSelect">
		<cfset loc.html = loc.html & timeSelect(argumentCollection=arguments)>
	<cfelseif arguments.$functionName IS "dateTimeSelectTag">
		<cfset loc.html = loc.html & timeSelectTag(argumentCollection=arguments)>
	</cfif>

	<cfreturn loc.html>
</cffunction>

<cffunction name="$dateOrTimeSelect" returntype="any" access="private" output="false">
	<cfargument name="name" type="any" required="false" default="">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="objectName" type="any" required="false" default="">
	<cfargument name="property" type="any" required="false" default="">
	<cfargument name="$functionName" type="any" required="true">
	<cfset var loc = {}>

	<cfif Len(arguments.objectName) IS NOT 0>
		<cfset loc.name = "#listLast(arguments.objectName,".")#[#arguments.property#]">
		<cfset arguments.$id = "#listLast(arguments.objectName,".")#-#arguments.property#">
		<cfset loc.value = $formValue(argumentCollection=arguments)>
	<cfelse>
		<cfset loc.name = arguments.name>
		<cfset arguments.$id = arguments.name>
		<cfset loc.value = arguments.value>
	</cfif>

	<cfset loc.html = "">
	<cfset loc.firstDone = false>
	<cfloop list="#arguments.order#" index="loc.i">
		<cfset arguments.name = loc.name & "($" & loc.i & ")">
		<cfif loc.value IS NOT "">
			<cfset arguments.value = evaluate("#loc.i#(loc.value)")>
		<cfelse>
			<cfset arguments.value = "">
		</cfif>
		<cfif loc.firstDone>
			<cfset loc.html = loc.html & arguments.separator>
		</cfif>
		<cfset loc.html = loc.html & evaluate("#loc.i#SelectTag(argumentCollection=arguments)")>
		<cfset loc.firstDone = true>
	</cfloop>

	<cfreturn loc.html>
</cffunction>

<cffunction name="$yearMonthHourMinuteSecondSelectTag" returntype="any" access="private" output="false">
	<cfargument name="name" type="any" required="true">
	<cfargument name="value" type="any" required="false" default="">
	<cfargument name="includeBlank" type="any" required="false" default="false">
	<cfargument name="label" type="any" required="false" default="">
	<cfargument name="wrapLabel" type="any" required="false" default="true">
	<cfargument name="prepend" type="any" required="false" default="">
	<cfargument name="append" type="any" required="false" default="">
	<cfargument name="prependToLabel" type="any" required="false" default="">
	<cfargument name="appendToLabel" type="any" required="false" default="">
	<cfargument name="$type" type="any" required="true" default="">
	<cfargument name="$loopFrom" type="any" required="true" default="">
	<cfargument name="$loopTo" type="any" required="true" default="">
	<cfargument name="$id" type="any" required="false" default="#arguments.name#">
	<cfargument name="$optionNames" type="any" required="false" default="">
	<cfargument name="$step" type="any" required="false" default="">
	<cfset var loc = {}>
	<cfset arguments.$namedArguments = "name,value,includeBlank,label,wrapLabel,prepend,append,prependToLabel,appendToLabel,$type,$loopFrom,$loopTo,$id,$optionNames,$step">
	<cfset loc.attributes = $getAttributes(argumentCollection=arguments)>

	<cfif arguments.value IS "" AND NOT arguments.includeBlank>
		<cfset arguments.value = evaluate("#arguments.$type#(now())")>
	</cfif>

	<cfset loc.html = "">
	<cfset loc.html = loc.html & $formBeforeElement(argumentCollection=arguments)>
	<cfset loc.html = loc.html & "<select name=""#arguments.name#"" id=""#arguments.$id#""#loc.attributes#>">
	<cfif NOT IsBoolean(arguments.includeBlank) OR arguments.includeBlank>
		<cfif NOT IsBoolean(arguments.includeBlank)>
			<cfset loc.text = arguments.includeBlank>
		<cfelse>
			<cfset loc.text = "">
		</cfif>
		<cfset loc.html = loc.html & "<option value="""">#loc.text#</option>">
	</cfif>
	<cfloop from="#arguments.$loopFrom#" to="#arguments.$loopTo#" index="loc.i" step="#arguments.$step#">
		<cfif arguments.value IS loc.i>
			<cfset loc.selected = " selected=""selected""">
		<cfelse>
			<cfset loc.selected = "">
		</cfif>
		<cfif arguments.$optionNames IS NOT "">
			<cfset loc.optionName = listGetAt(arguments.$optionNames, loc.i)>
		<cfelse>
			<cfset loc.optionName = loc.i>
		</cfif>
		<cfif arguments.$type IS "minute" OR arguments.$type IS "second">
			<cfset loc.optionName = numberFormat(loc.optionName, "09")>
		</cfif>
		<cfset loc.html = loc.html & "<option value=""#loc.i#""#loc.selected#>#loc.optionName#</option>">
	</cfloop>
	<cfset loc.html = loc.html & "</select>">
	<cfset loc.html = loc.html & $formAfterElement(argumentCollection=arguments)>

	<cfreturn loc.html>
</cffunction>