# Archetype
Archetype is a **general-purpose parameterized project initialization tool** for OS X. It creates configured instances of a particular kind of project from an archetypical example of that type of project – usually a Git repository.

Archetype lets you set up a software project exactly how you want it *once* and then easily create new instances of it, configured and ready to go.

# Sounds familiar
Archetype shares similar aims with Maven archetypes, Ruby on Rails, Play! Framework, and other platforms that do templated project initialization to get you started faster.

Unlike those projects, Archetype is both **general-purpose** and **simple**. It doesn't care what kind of project it's used for and it requires very little configuration or formality.

# Try it out
If you aren't interested in making changes, the easiest way to install Archetype is using Homebrew:

	$ brew install https://raw.github.com/bww/Archetype/master/formulae/archetype.rb

Then try it out on the example project:

	$ archetype https://github.com/bww/ArchetypeExample.git ./MyExample
		
# Creating template projects
You can use any Git repository (or a local directory) as an example project. The only requirement is that an Archetype configuration file, named `archetype.json`, must be at the root of the project.

In `archetype.json` you can define the parameters used in your project, and throughout your project you can use those parameters to configure the project.

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
You can use the parameters defined in the Archetype configuration anywhere you like in your template project. When Archetype creates an instance of that project it copies over the files in the template project with parameters substituted with user-provided values.

Parameters are defined using variable expressions of the form `${ paramter_name }`, where `parameter_name` refers to a parameter `id` in your `archetype.json` file. Whitespace surrounding the parameter identifier is ignored: `${name}` is the same as `${  name  }`.

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

## Variable expressions in filenames
You can use variable expression in filenames the same way you can in the content of files. For example, you might create a file in your template named `${SHORT_NAME}.conf` and it would be renamed as `example_project.conf`.

