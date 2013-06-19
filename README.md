# Archetype
Archetype is a **general-purpose parameterized project initialization tool** for OS X. It generates configured instances of a particular kind of project from an archetypical example of that type of project – usually in the form of a Git repository.

Archetype lets you set up a software project exactly how you want it *once* and then easily create new instances of it, configured and ready to go.

## Sounds familiar
Archetype shares similar aims with Maven archetypes, Ruby on Rails, Play! Framework, and other platforms that do templated project initialization to get you started faster.

Unlike those projects, Archetype is both **general-purpose** and **simple**. It doesn't care what kind of project it's used for and it requires very little configuration or formality.

## Try it out
If you aren't interested in making changes, the easiest way to install Archetype is using Homebrew:

	$ brew install https://raw.github.com/bww/Archetype/master/formulae/archetype.rb

Then try it out on the Archetype example project:

	$ archetype https://github.com/bww/ArchetypeExample.git ./MyExample
		
# Generating projects
When you want to create a new instance of a project you can point Archetype at a Git repository for a project template and Archetype will do several things:

 1. Clone the project template repository in a temporary directory
 2. Ask you to provide values for the parameters used by the project template
 3. For text files, substitue the parameter values you provided for any variables
 4. Copy each file from the project template into the directory you specify

When it's done, you'll have a new project configured, ready for you to start working.

# Creating project templates
You can use any Git repository (or a local directory) as a project template. A project template is essentially just an actual project which uses some configuration variables. The only requirement is that an Archetype configuration file, named `archetype.json`, must be at the root of the project. This file is used only by Archetype and is excluded from the generated project.

In `archetype.json` you can define the parameters used in your project, and throughout your template you can use those parameters in variable expressions.

## archetype.json
An example Archetype configuration file might look like this:

	{
	  "name": "Example Archetype Project",
	  "parameters": [
	    {
	      "id": "SHORT_NAME",
	      "name": "Project short name (e.g., 'example_project')"
	    },
	    {
	      "id": "FULL_NAME",
	      "name": "Project full name (e.g., 'My Great Project')"
	    }
	    /* ... and so on */ 
	  ]
	}

## Using parameters
You can use the parameters defined in the Archetype configuration anywhere you like in your template project by using a variable expression. When Archetype encounters a variable expression in a text-base file it is substituted with the corresponding parameter value.

Variable expressions are defined using the following form:

	${paramter_name}
	
... where `parameter_name` refers to a parameter `id` in your `archetype.json` file. Whitespace surrounding the parameter identifier is ignored: `${name}` is the same as `${  name  }`.

For example, maybe your project needs to configure a database, you might have a file like this:

	# Example database configuration for ${FULL_NAME}.
	
	database_name     = '${SHORT_NAME}_db'
	database_username = '${DB_USERNAME}'
	database_password = '${DB_PASSWORD}'

... and Archetype will generate something like

	# Example database configuration for My Great Project
	
	database_name     = 'example_project_db'
	database_username = 'joe'
	database_password = 'secret'

## Escaping variable expressions
If, for some reason, you need to use the literal string `${...}` in your project, you can escape it with `\` and Archetype will leave it alone.

	Literal variable expression \${ parameter_name }

Or, if you need a literal `\` before a substituted variable, you can do:

	Substitued variable with literal backslash \\${ parameter_name }

And so on...

	Literal variable expression with literal backslash \\\${ parameter_name }

Note that **Archetype does not treat the `\` character specially anywhere else in your files**, only when it a sequence of backslashes immediately precede a variable expression.

## Which files get variable substitution?
Since only text files can be scanned for variable substituion, not all files are filtered. Out of the box, Archetype will scan for variable expressions in files with a [UTI](http://en.wikipedia.org/wiki/Uniform_Type_Identifier) that conforms to any of the following:

 * `public.text`
 * `public.plain-text`
 * `public.source-code`
 * `public.script`
 * `public.shell-script`
 * `public.xml`

This set should covers most common textual filetypes. Refer to the list of Apple-defined UTIs at the [System-Declared Uniform Type Identifiers Reference](https://developer.apple.com/library/mac/#documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html) for details.

## I have a weird file...
If you have files with uncommon extensions or that otherwise aren't matched by the standard set of UTIs, you can add them explicitly in your `archetype.json` configuration. The following example will add the extensions `abc` and `xyz` to the types of files that are filtered for variable substitution.

	{
	  "name": "Example Archetype Project",
	  "parameters": [ /* ... */ ],
	  "filter-file-types": [
	    {
	      "extensions": [ "abc", "xyz" ]
	    }
	  ]
	}

## Variable expressions in filenames
You can use variable expression in filenames the same way you can in the content of files. For example, you might create a file in your template named `${SHORT_NAME}.conf` and it would be renamed as `example_project.conf`. Variable expressions in filenames are always substituted.