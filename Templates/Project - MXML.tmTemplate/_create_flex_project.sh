#!/bin/bash

#-------------------------------------------------------------------------
#
# New Flex Project 
# Version 3
#
# Switched from copying a directory structure to a flat 
# Hierarchy as TM doesn't support Template duplication 
# properly when a directory is present.
# 
# The created project should be fine to import into Flex Builder 2,
# although there appear to be problems with the way Flex Builder
# treats the deploy folder.
#
#-------------------------------------------------------------------------

defaultProjectName="FlexProject.tmproj";
defaultClassPath="uk.co.client";

fullProjectPath=$(CocoaDialog filesave \
			--text "Please name your project and select a folder to save it into" \
			--title "Create New Project" \
			--with-extensions .tmproj \
			--with-file "$defaultProjectName");

if [ -n "$fullProjectPath" ]; then

	fullProjectPath=$(tail -n1 <<<"$fullProjectPath");
	projectName=`basename "$fullProjectPath" ".tmproj"`;
	projectPath=`dirname "$fullProjectPath"`;

	# now ask them what they want the class path to be, this will be used to create default directories
	fullClassPath=$(CocoaDialog standard-inputbox \
				--title "Project Class Path" \
				--text "$defaultClassPath.$projectName" \
				--informative-text "Enter the project class path:");

	if [ -n "$fullClassPath" ]; then
		classPath=$(tail -n1 <<<"$fullClassPath");
		classPath=`echo $classPath | tr '.' '/'`;
		classPathDirectory="$projectPath/$projectName/src/$classPath/";

		#Create our project directory structure.
		mkdir -p "$projectPath/$projectName/build";
		mkdir -p "$projectPath/$projectName/deploy/_assets/html";
		mkdir -p "$projectPath/$projectName/deploy/_assets/images";	
		mkdir -p "$projectPath/$projectName/deploy/_assets/js";
		mkdir -p "$projectPath/$projectName/deploy/_assets/swf";
		mkdir -p "$projectPath/$projectName/deploy/_assets/xml";
		mkdir -p "$projectPath/$projectName/html-template/_assets/html";
		mkdir -p "$projectPath/$projectName/html-template/_assets/js";
		mkdir -p "$projectPath/$projectName/html-template/_assets/swf";	
		mkdir -p "$projectPath/$projectName/library/css";
		mkdir -p "$projectPath/$projectName/library/fonts";
		mkdir -p "$projectPath/$projectName/library/images";
		mkdir -p "$projectPath/$projectName/.settings";
		mkdir -p "$projectPath/$projectName/src";		

		# this recursively creates all source code folders, creating any missing directories along the way
		mkdir -p "$classPathDirectory/core";
		mkdir -p "$classPathDirectory/controls";
		mkdir -p "$classPathDirectory/data";
		mkdir -p "$classPathDirectory/net";
		mkdir -p "$classPathDirectory/views";

		#Gather variables to be substituted.
		TM_NEW_FILE_BASENAME="$projectName";

		export TM_YEAR=`date "+%Y"`;
		export TM_DATE=`date "+%d.%m.%Y"`;

		# Customise file variables for the new project and rename files to match the project name
		perl -pe 's/\%\{([^}]*)\}/$ENV{$1}/g' < "actionScriptProperties.xml" > "$projectPath/$projectName/.actionScriptProperties";
		perl -pe 's/\%\{([^}]*)\}/$ENV{$1}/g' < "build.xml" > "$projectPath/$projectName/build/build.xml";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "compile.sh" > "$projectPath/$projectName/build/compile.sh";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "index.html" > "$projectPath/$projectName/deploy/index.html";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "index-debug.html" > "$projectPath/$projectName/bin/$projectName-debug.html";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "Project-config.xml" > "$projectPath/$projectName/src/$projectName-config.xml";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "Project.mxml" > "$projectPath/$projectName/src/$projectName.mxml";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "Project.tmproj.xml" > "$projectPath/$projectName/$projectName.tmproj";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "project.xml" > "$projectPath/$projectName/.project";
		perl -pe 's/\$\{([^}]*)\}/$ENV{$1}/g' < "window_close.js" > "$projectPath/$projectName/deploy/_assets/js/window_close.js";
		
		# cp for run project command compatibility
		cp "$projectPath/$projectName/deploy/index.html" "$projectPath/$projectName/deploy/$projectName.html";

		#Copy static files.
		#cp "asdoc.sh" "$projectPath/$projectName/build/asdoc.sh";
		cp "app_style.css" "$projectPath/$projectName/library/css/app_style.css";
		cp "flexProperties.xml" "$projectPath/$projectName/.flexProperties"
		cp "org.eclipse.core.resources.prefs" "$projectPath/$projectName/.settings/org.eclipse.core.resources.prefs"
		
		cp "AC_OETags.js" "$projectPath/$projectName/deploy/_assets/js/AC_OETags.js";
		cp "history.htm" "$projectPath/$projectName/deploy/_assets/html/history.htm";
		cp "history.js" "$projectPath/$projectName/deploy/_assets/js/history.js";
		cp "history.swf" "$projectPath/$projectName/deploy/_assets/swf/history.swf";
		cp "playerProductInstall.swf" "$projectPath/$projectName/deploy/_assets/swf/playerProductInstall.swf";
		
		cp "AC_OETags.js" "$projectPath/$projectName/html-template/_assets/js/AC_OETags.js";
		cp "history.js" "$projectPath/$projectName/html-template/_assets/js/history.js";
		cp "history.htm" "$projectPath/$projectName/html-template/_assets/html/history.htm";
		cp "history.swf" "$projectPath/$projectName/html-template/_assets/swf/history.swf";
		cp "index.template.html" "$projectPath/$projectName/html-/html-template/index.template.html";
		cp "playerProductInstall.swf" "$projectPath/$projectNametemplate/_assets/swf/playerProductInstall.swf";
		cp "window_close.template.js" "$projectPath/$projectName/html-/html-template/_assets/js/window_close.template.js";
		
		# switch off custom compile.sh (disabled so projects will compile independently of a .tmproj file as these are ignored by svn).
		#mv "$projectPath/$projectName/build/compile.sh" "$projectPath/$projectName/build/compile(rename_to_enable).sh";
		
		# Open the project in TextMate
		open -a "TextMate.app" "$projectPath/$projectName/$projectName.tmproj";
		
	fi
fi
